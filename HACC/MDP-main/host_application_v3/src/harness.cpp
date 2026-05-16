#include <cassert>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <iomanip>
#include <iostream>
#include <unistd.h>
#include <vector>
#include <algorithm>

#include <xrt/xrt_bo.h>
#include <xrt/xrt_device.h>
#include <xrt/xrt_kernel.h>
#include <experimental/xrt_ip.h>

#include "bfs.hpp"
#include "support.hpp"

static constexpr std::size_t STRIPE_CHUNK_BYTES = 256;

static inline std::size_t align_up(std::size_t x, std::size_t a)
{
  return (x + (a - 1)) & ~(a - 1);
}

static inline std::size_t bo_alloc_size(std::size_t needed_bytes)
{
  constexpr std::size_t PAGE = 4096;
  return std::max<std::size_t>(PAGE, align_up(needed_bytes, PAGE));
}

static inline void compute_striped_sizes(std::size_t total_bytes,
                                         std::size_t chunk_bytes,
                                         std::size_t& out_b0,
                                         std::size_t& out_b1)
{
  out_b0 = 0;
  out_b1 = 0;
  std::size_t pos = 0;
  std::size_t chunk_idx = 0;
  while (pos < total_bytes) {
    const std::size_t len = std::min(chunk_bytes, total_bytes - pos);
    if ((chunk_idx & 1u) == 0u) out_b0 += len;
    else                       out_b1 += len;
    pos += len;
    ++chunk_idx;
  }
}

// Costruisce due blob contigui (host) con striping 256B: chunk pari -> tmp0, chunk dispari -> tmp1
static inline void stripe_build_blobs_256(const void* src, std::size_t total_bytes,
                                         std::vector<std::uint8_t>& tmp0,
                                         std::vector<std::uint8_t>& tmp1)
{
  std::size_t b0 = 0, b1 = 0;
  compute_striped_sizes(total_bytes, STRIPE_CHUNK_BYTES, b0, b1);

  tmp0.clear(); tmp1.clear();
  tmp0.resize(b0);
  tmp1.resize(b1);

  const auto* in = static_cast<const std::uint8_t*>(src);

  std::size_t pos = 0;
  std::size_t chunk_idx = 0;
  std::size_t off0 = 0, off1 = 0;

  while (pos < total_bytes) {
    const std::size_t len = std::min(STRIPE_CHUNK_BYTES, total_bytes - pos);
    if ((chunk_idx & 1u) == 0u) {
      std::memcpy(tmp0.data() + off0, in + pos, len);
      off0 += len;
    } else {
      std::memcpy(tmp1.data() + off1, in + pos, len);
      off1 += len;
    }
    pos += len;
    ++chunk_idx;
  }

  assert(off0 == tmp0.size());
  assert(off1 == tmp1.size());
}

// Ricompone il blob originale da (tmp0,tmp1) in base allo stesso striping 256B
static inline void unstripe_from_blobs_256(const std::vector<std::uint8_t>& tmp0,
                                           const std::vector<std::uint8_t>& tmp1,
                                           void* dst, std::size_t total_bytes)
{
  auto* out = static_cast<std::uint8_t*>(dst);

  std::size_t pos = 0;
  std::size_t chunk_idx = 0;
  std::size_t off0 = 0, off1 = 0;

  while (pos < total_bytes) {
    const std::size_t len = std::min(STRIPE_CHUNK_BYTES, total_bytes - pos);
    if ((chunk_idx & 1u) == 0u) {
      std::memcpy(out + pos, tmp0.data() + off0, len);
      off0 += len;
    } else {
      std::memcpy(out + pos, tmp1.data() + off1, len);
      off1 += len;
    }
    pos += len;
    ++chunk_idx;
  }

  assert(off0 == tmp0.size());
  assert(off1 == tmp1.size());
}

static inline void stripe_write_one_shot_256(xrt::bo& bo0, xrt::bo& bo1,
                                             const void* src, std::size_t total_bytes,
                                             std::vector<std::uint8_t>& tmp0,
                                             std::vector<std::uint8_t>& tmp1)
{
  stripe_build_blobs_256(src, total_bytes, tmp0, tmp1);

  if (!tmp0.empty()) bo0.write(tmp0.data(), tmp0.size(), 0);
  if (!tmp1.empty()) bo1.write(tmp1.data(), tmp1.size(), 0);
}

static inline void unstripe_read_one_shot_256(xrt::bo& bo0, xrt::bo& bo1,
                                              void* dst, std::size_t total_bytes,
                                              std::vector<std::uint8_t>& tmp0,
                                              std::vector<std::uint8_t>& tmp1)
{
  // ricrea le size attese
  std::size_t b0 = 0, b1 = 0;
  compute_striped_sizes(total_bytes, STRIPE_CHUNK_BYTES, b0, b1);

  tmp0.clear(); tmp1.clear();
  tmp0.resize(b0);
  tmp1.resize(b1);

  if (!tmp0.empty()) bo0.read(tmp0.data(), tmp0.size(), 0);
  if (!tmp1.empty()) bo1.read(tmp1.data(), tmp1.size(), 0);

  unstripe_from_blobs_256(tmp0, tmp1, dst, total_bytes);
}

int main(int argc, char* argv[])
{
  if (argc < 3) {
    std::cerr << "Uso: ./host kernel.xclbin input.data\n";
    return 1;
  }

  const char* xclbin_path = argv[1];
  const char* input_file  = argv[2];

  std::cout << "[1] Apro " << input_file << "\n";
  int fd = open(input_file, O_RDONLY);
  assert(fd > 0 && "Errore apertura input.data");

  char* data = static_cast<char*>(std::malloc(INPUT_SIZE));
  assert(data && "Out of memory");

  std::cout << "[2] Parsing input.data...\n";
  input_to_data(fd, data);
  close(fd);

  auto* data_v1 = reinterpret_cast<bench_args_t*>(data);
   
  std::cout << "[3] Apertura device 0...\n";
  auto device = xrt::device(0);
  auto uuid   = device.load_xclbin(xclbin_path);
  auto krnl   = xrt::kernel(device, uuid, "panda");

  node_index_t queue1[N_NODES + 32];
  node_index_t queue2[N_NODES + 32];
  std::memset(queue1, 0, sizeof(queue1));
  std::memset(queue2, 0, sizeof(queue2));

  const std::size_t nodes_bytes = sizeof(data_v1->nodes);
  const std::size_t edges_bytes = sizeof(data_v1->edges);
  const std::size_t level_bytes = sizeof(data_v1->level);
  const std::size_t lc_bytes    = sizeof(data_v1->level_counts);
  const std::size_t q1_bytes    = sizeof(queue1);
  const std::size_t q2_bytes    = sizeof(queue2);

  std::size_t nodes_b0=0, nodes_b1=0;
  std::size_t edges_b0=0, edges_b1=0;
  std::size_t level_b0=0, level_b1=0;
  std::size_t lc_b0=0,    lc_b1=0;
  std::size_t q1_b0=0,    q1_b1=0;
  std::size_t q2_b0=0,    q2_b1=0;

  compute_striped_sizes(nodes_bytes, STRIPE_CHUNK_BYTES, nodes_b0, nodes_b1);
  compute_striped_sizes(edges_bytes, STRIPE_CHUNK_BYTES, edges_b0, edges_b1);
  compute_striped_sizes(level_bytes, STRIPE_CHUNK_BYTES, level_b0, level_b1);
  compute_striped_sizes(lc_bytes,    STRIPE_CHUNK_BYTES, lc_b0,    lc_b1);
  compute_striped_sizes(q1_bytes,    STRIPE_CHUNK_BYTES, q1_b0,    q1_b1);
  compute_striped_sizes(q2_bytes,    STRIPE_CHUNK_BYTES, q2_b0,    q2_b1);

  std::cout << "[4] Allocazione buffer\n";

  auto bo_nodes_0 = xrt::bo(device, bo_alloc_size(nodes_b0), krnl.group_id(0));
  auto bo_nodes_1 = xrt::bo(device, bo_alloc_size(nodes_b1), krnl.group_id(7));

  auto bo_edges_0 = xrt::bo(device, bo_alloc_size(edges_b0), krnl.group_id(1));
  auto bo_edges_1 = xrt::bo(device, bo_alloc_size(edges_b1), krnl.group_id(8));

  auto bo_level_0 = xrt::bo(device, bo_alloc_size(level_b0), krnl.group_id(3));
  auto bo_level_1 = xrt::bo(device, bo_alloc_size(level_b1), krnl.group_id(9));

  auto bo_level_counts_0 = xrt::bo(device, bo_alloc_size(lc_b0), krnl.group_id(4));
  auto bo_level_counts_1 = xrt::bo(device, bo_alloc_size(lc_b1), krnl.group_id(10));

  auto bo_queue1_0 = xrt::bo(device, bo_alloc_size(q1_b0), krnl.group_id(5));
  auto bo_queue1_1 = xrt::bo(device, bo_alloc_size(q1_b1), krnl.group_id(11));

  auto bo_queue2_0 = xrt::bo(device, bo_alloc_size(q2_b0), krnl.group_id(6));
  auto bo_queue2_1 = xrt::bo(device, bo_alloc_size(q2_b1), krnl.group_id(12));

  // ----------------------------------------------------------
  // Scrittura: UNA write per argomento per BO0 + UNA write per argomento per BO1
  // ----------------------------------------------------------
  std::vector<std::uint8_t> tmp0, tmp1;

  stripe_write_one_shot_256(bo_nodes_0,        bo_nodes_1,        data_v1->nodes,        nodes_bytes, tmp0, tmp1);
  stripe_write_one_shot_256(bo_edges_0,        bo_edges_1,        data_v1->edges,        edges_bytes, tmp0, tmp1);
  stripe_write_one_shot_256(bo_level_0,        bo_level_1,        data_v1->level,        level_bytes, tmp0, tmp1);
  stripe_write_one_shot_256(bo_level_counts_0, bo_level_counts_1, data_v1->level_counts, lc_bytes,    tmp0, tmp1);
  stripe_write_one_shot_256(bo_queue1_0,       bo_queue1_1,       queue1,               q1_bytes,    tmp0, tmp1);
  stripe_write_one_shot_256(bo_queue2_0,       bo_queue2_1,       queue2,               q2_bytes,    tmp0, tmp1);

  // ----------------------------------------------------------
  // Sync CPU -> FPGA
  // ----------------------------------------------------------
  std::cout << "[5] Sync BO -> DEVICE\n";
  bo_nodes_0.sync(XCL_BO_SYNC_BO_TO_DEVICE);        bo_nodes_1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  bo_edges_0.sync(XCL_BO_SYNC_BO_TO_DEVICE);        bo_edges_1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  bo_level_0.sync(XCL_BO_SYNC_BO_TO_DEVICE);        bo_level_1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  bo_level_counts_0.sync(XCL_BO_SYNC_BO_TO_DEVICE); bo_level_counts_1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  bo_queue1_0.sync(XCL_BO_SYNC_BO_TO_DEVICE);       bo_queue1_1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  bo_queue2_0.sync(XCL_BO_SYNC_BO_TO_DEVICE);       bo_queue2_1.sync(XCL_BO_SYNC_BO_TO_DEVICE);

  // ----------------------------------------------------------
  // Indirizzi x2 come se li aspetta Bambu
  // ----------------------------------------------------------
  const uint64_t nodes_addr_x2        = bo_nodes_0.address()        << 1;
  const uint64_t edges_addr_x2        = bo_edges_0.address()        << 1;
  const uint64_t level_addr_x2        = bo_level_0.address()        << 1;
  const uint64_t level_counts_addr_x2 = bo_level_counts_0.address() << 1;
  const uint64_t queue1_addr_x2       = bo_queue1_0.address()       << 1;
  const uint64_t queue2_addr_x2       = bo_queue2_0.address()       << 1;

  // ----------------------------------------------------------
  // Lancio kernel
  // ----------------------------------------------------------
  std::cout << "[6] Lancio kernel BFS...\n";
  auto run = krnl(
    nodes_addr_x2,
    edges_addr_x2,
    data_v1->starting_node,
    level_addr_x2,
    level_counts_addr_x2,
    queue1_addr_x2,
    queue2_addr_x2,

    bo_nodes_1,
    bo_edges_1,
    bo_level_1,
    bo_level_counts_1,
    bo_queue1_1,
    bo_queue2_1
  );
  run.wait();
  std::cout << "[7] Kernel completato.\n";

  // ----------------------------------------------------------
  // FPGA -> CPU: solo level_counts
  // ----------------------------------------------------------
  bo_level_counts_0.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  bo_level_counts_1.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

  unstripe_read_one_shot_256(bo_level_counts_0, bo_level_counts_1,
                            data_v1->level_counts, lc_bytes,
                            tmp0, tmp1);

  // ----------------------------------------------------------
  // Scrittura output.data
  // ----------------------------------------------------------
  std::cout << "[8] Scrittura output.data tramite data_to_output...\n";
  int out_fd = open("output.data", O_WRONLY | O_CREAT | O_TRUNC, 0666);
  assert(out_fd > 0 && "Couldn't open output.data file");
  data_to_output(out_fd, data);
  close(out_fd);

  std::cout << "[9] Fine esecuzione harness.\n";
  std::free(data);
  return 0;
}
