// bm_host.cpp — AXI latency benchmark host for write_bm_krnl
// Sweeps N values and prints hw-profile counter results.
// Build: see CMakeLists.txt
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <experimental/xrt_bo.h>
#include <experimental/xrt_device.h>
#include <experimental/xrt_kernel.h>
#include <vector>

// hw-profile register offsets
static constexpr uint32_t ADDR_RD_BUSY_LO = 0x90;
static constexpr uint32_t ADDR_RD_BUSY_HI = 0x94;
static constexpr uint32_t ADDR_WR_BUSY_LO = 0x98;
static constexpr uint32_t ADDR_WR_BUSY_HI = 0x9C;
static constexpr uint32_t ADDR_RD_TXN_CNT = 0xA0;
static constexpr uint32_t ADDR_WR_TXN_CNT = 0xA4;

int main(int argc, char* argv[]) {
    const char* xclbin_path = (argc > 1) ? argv[1] : "write_bm_krnl.xclbin";

    auto device = xrt::device(0);
    auto uuid   = device.load_xclbin(xclbin_path);
    auto krnl   = xrt::kernel(device, uuid, "write_bm_krnl", xrt::kernel::cu_access_mode::exclusive);

    std::vector<int> n_list = {1024, 4096, 16384, 65536, 262144, 1048576};

    printf("%-12s  %-12s  %-12s  %-12s  %-12s  %-12s  %-12s\n",
           "N", "kern_ms", "rd_busy", "wr_busy", "rd_txn", "wr_txn",
           "rd_lat/txn");

    for (int n : n_list) {
        size_t n_floats = (size_t)n;

        // Allocate buffers in HBM[0]
        auto buf_input_p0  = xrt::bo(device, n_floats * sizeof(float), 0);
        auto buf_output_p0 = xrt::bo(device, n_floats * sizeof(float), 0);

        // Fill input with 1.0f
        float* inp = buf_input_p0.map<float*>();
        for (size_t i = 0; i < n_floats; i++) inp[i] = 1.0f;
        buf_input_p0.sync(XCL_BO_SYNC_BO_TO_DEVICE);

        // Set registers
        krnl.write_register(0x010,
            (uint32_t)(buf_input_p0.address()  & 0xFFFFFFFF));
        krnl.write_register(0x010,
            (uint32_t)(buf_output_p0.address() & 0xFFFFFFFF));
        krnl.write_register(0x014, (uint32_t)n);

        // Run
        auto t0 = std::chrono::high_resolution_clock::now();
        krnl.write_register(0x00, 0x1);   // ap_start
        while (!(krnl.read_register(0x00) & 0x4)) {}  // wait ap_done (bit2 in translator)
        auto t1 = std::chrono::high_resolution_clock::now();
        double kern_ms = std::chrono::duration<double, std::milli>(t1 - t0).count();

        // Read hw-profile counters
        uint64_t rd_busy = ((uint64_t)krnl.read_register(ADDR_RD_BUSY_HI) << 32)
                         |  (uint64_t)krnl.read_register(ADDR_RD_BUSY_LO);
        uint64_t wr_busy = ((uint64_t)krnl.read_register(ADDR_WR_BUSY_HI) << 32)
                         |  (uint64_t)krnl.read_register(ADDR_WR_BUSY_LO);
        uint32_t rd_txn  = krnl.read_register(ADDR_RD_TXN_CNT);
        uint32_t wr_txn  = krnl.read_register(ADDR_WR_TXN_CNT);

        double rd_lat = (rd_txn > 0) ? (double)rd_busy / rd_txn : 0.0;

        printf("%-12d  %-12.3f  %-12lu  %-12lu  %-12u  %-12u  %-12.2f\n",
               n, kern_ms, rd_busy, wr_busy, rd_txn, wr_txn, rd_lat);
    }
    return 0;
}
