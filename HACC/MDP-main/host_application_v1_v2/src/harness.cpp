#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>

#include <fcntl.h>
#include <unistd.h>
#include <xrt/xrt_device.h>
#include <xrt/xrt_bo.h>
#include <xrt/xrt_kernel.h>
#include <experimental/xrt_ip.h>

#include "bfs.hpp"
#include "support.hpp"

// -------------------------------------------------------------------
// MAIN
// -------------------------------------------------------------------
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

    // Alloco buffer input
    char* data = (char*)malloc(INPUT_SIZE);
    assert(data != nullptr && "Out of memory");

    std::cout << "[2] Parsing input.data...\n";
    input_to_data(fd, data);
    close(fd);

    // Cast a struct bench_args_t
    bench_args_t* data_v1 = (bench_args_t*)data;

    // Inizializzazione FPGA
    std::cout << "[3] Apertura device 0...\n";
    auto device = xrt::device(0);
    auto uuid   = device.load_xclbin(xclbin_path);
    auto krnl   = xrt::kernel(device, uuid, "panda");

    // Code per queue1/queue2
    node_index_t queue1[N_NODES + 32];
    node_index_t queue2[N_NODES + 32];
    std::memset(queue1, 0, sizeof(queue1));
    std::memset(queue2, 0, sizeof(queue2));

    // ----------------------------------------------------------
    // Allocazione buffer
    // ----------------------------------------------------------
    std::cout << "[4] Allocazione buffer\n";
    auto bo_nodes        = xrt::bo(device, sizeof(data_v1->nodes),        krnl.group_id(0));
    auto bo_edges        = xrt::bo(device, sizeof(data_v1->edges),        krnl.group_id(1));
    auto bo_level        = xrt::bo(device, sizeof(data_v1->level),        krnl.group_id(3));
    auto bo_level_counts = xrt::bo(device, sizeof(data_v1->level_counts), krnl.group_id(4));
    auto bo_queue1       = xrt::bo(device, sizeof(queue1),                krnl.group_id(5));
    auto bo_queue2       = xrt::bo(device, sizeof(queue2),                krnl.group_id(6));
    // ----------------------------------------------------------
    // Copia CPU -> FPGA
    // ----------------------------------------------------------
    std::cout << "[5] Copia dati su FPGA\n";

    bo_nodes.write(data_v1->nodes);
    bo_edges.write(data_v1->edges);
    bo_level.write(data_v1->level);
    bo_level_counts.write(data_v1->level_counts);
    bo_queue1.write(queue1);
    bo_queue2.write(queue2);

    bo_nodes.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    bo_edges.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    bo_level.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    bo_level_counts.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    bo_queue1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    bo_queue2.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    // ----------------------------------------------------------
    // Lancio kernel
    // ----------------------------------------------------------
    std::cout << "[6] Lancio kernel BFS...\n";

    auto run = krnl(
        bo_nodes,
        bo_edges,
        data_v1->starting_node,
        bo_level,
        bo_level_counts,
        bo_queue1,
        bo_queue2
    );

    run.wait();
    std::cout << "[7] Kernel completato.\n";

    // ----------------------------------------------------------
    // Copia FPGA -> CPU
    // ----------------------------------------------------------
    bo_level.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    bo_level_counts.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    bo_level.read(data_v1->level);
    bo_level_counts.read(data_v1->level_counts);

    // ----------------------------------------------------------
    // Scrittura output.data
    // ----------------------------------------------------------
    std::cout << "[8] Scrittura output.data tramite data_to_output...\n";

    int out_fd = open("output.data",
                      O_WRONLY | O_CREAT | O_TRUNC,
                      0666);

    assert(out_fd > 0 && "Couldn't open output.data file");
    data_to_output(out_fd, data);
    close(out_fd);

    std::cout << "[9] Fine esecuzione harness.\n";

    free(data); 
    return 0;
}
