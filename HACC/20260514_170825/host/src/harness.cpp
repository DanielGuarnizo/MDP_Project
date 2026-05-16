// harness.cpp — generic XRT host for any Bambu/HACC accelerator
// Usage:
//   ./bambu_application <xclbin> <accel_config.json> <input_dir> <output_dir>
//
// accel_config.json format:
//   { "kernel_name": "panda",
//     "buffers": [
//       { "name":"dram_in_b0", "size_bytes":288, "direction":"input",  "group_id":0 },
//       { "name":"dram_out_b0","size_bytes":32,  "direction":"output", "group_id":4 }
//     ] }
//
// For every "input"/"inout" buffer:  reads <input_dir>/<name>.bin -> FPGA HBM
// For every "output"/"inout" buffer: FPGA HBM -> writes <output_dir>/<name>.bin

#include <cassert>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include <xrt/xrt_bo.h>
#include <xrt/xrt_device.h>
#include <xrt/xrt_kernel.h>

namespace fs = std::filesystem;

// ──────────────────────────────────────────────────────────────────────────────
// Minimal JSON parser (handles only our fixed accel_config.json schema)
// ──────────────────────────────────────────────────────────────────────────────

struct BufferCfg {
    std::string name;
    size_t      size_bytes = 0;
    std::string direction;  // "input" | "output" | "inout"
    int         group_id   = 0;
    std::string axi_bundle;
};

struct AccelCfg {
    std::string            kernel_name;
    std::vector<BufferCfg> buffers;
};

static std::string json_string(const std::string& src, const std::string& key) {
    auto k = src.find('"' + key + '"');
    if (k == std::string::npos) return "";
    auto c = src.find(':', k);
    auto q1 = src.find('"', c);
    auto q2 = src.find('"', q1 + 1);
    return src.substr(q1 + 1, q2 - q1 - 1);
}

static long json_long(const std::string& src, const std::string& key) {
    auto k = src.find('"' + key + '"');
    if (k == std::string::npos) return 0;
    auto c = src.find(':', k);
    auto v = src.find_first_not_of(" \t\n\r:", c);
    auto e = src.find_first_of(",}\n", v);
    return std::stol(src.substr(v, e - v));
}

static AccelCfg parse_config(const std::string& path) {
    std::ifstream f(path);
    if (!f) throw std::runtime_error("Cannot open: " + path);
    std::string src((std::istreambuf_iterator<char>(f)), {});

    AccelCfg cfg;
    cfg.kernel_name = json_string(src, "kernel_name");

    size_t pos = src.find('"', src.find("\"buffers\""));
    while (pos != std::string::npos) {
        pos = src.find('{', pos);
        if (pos == std::string::npos) break;
        size_t end = src.find('}', pos);
        std::string blk = src.substr(pos, end - pos + 1);
        pos = end + 1;

        BufferCfg bc;
        bc.name       = json_string(blk, "name");
        bc.size_bytes = static_cast<size_t>(json_long(blk, "size_bytes"));
        bc.direction  = json_string(blk, "direction");
        bc.group_id   = static_cast<int>(json_long(blk, "group_id"));
        bc.axi_bundle = json_string(blk, "axi_bundle");
        if (!bc.name.empty()) cfg.buffers.push_back(bc);

        size_t next_obj = src.find('{', pos);
        size_t arr_end  = src.find(']', pos);
        if (next_obj == std::string::npos || next_obj > arr_end) break;
    }
    return cfg;
}

// ──────────────────────────────────────────────────────────────────────────────
// I/O helpers
// ──────────────────────────────────────────────────────────────────────────────

static std::vector<char> read_bin(const std::string& path, size_t expected) {
    std::ifstream f(path, std::ios::binary);
    if (!f) throw std::runtime_error("Cannot open: " + path);
    std::vector<char> buf(expected, 0);
    f.read(buf.data(), static_cast<std::streamsize>(expected));
    std::cout << "    read " << f.gcount() << " / " << expected << " B  <- " << path << "\n";
    return buf;
}

static void write_bin(const std::string& path, const char* data, size_t n) {
    std::ofstream f(path, std::ios::binary);
    if (!f) throw std::runtime_error("Cannot create: " + path);
    f.write(data, static_cast<std::streamsize>(n));
    std::cout << "    wrote " << n << " B  -> " << path << "\n";
}

// ──────────────────────────────────────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    if (argc < 5) {
        std::cerr << "Usage: " << argv[0]
                  << " <xclbin> <accel_config.json> <input_dir> <output_dir>\n";
        return 1;
    }

    const std::string xclbin  = argv[1];
    const std::string cfgpath = argv[2];
    const std::string in_dir  = argv[3];
    const std::string out_dir = argv[4];

    fs::create_directories(out_dir);

    // 1. Parse config
    std::cout << "[1] Config: " << cfgpath << "\n";
    AccelCfg cfg = parse_config(cfgpath);
    std::cout << "    kernel=" << cfg.kernel_name
              << "  buffers=" << cfg.buffers.size() << "\n";

    for (const auto& bc : cfg.buffers) {
        if (bc.size_bytes == 0)
            throw std::runtime_error(
                "Buffer '" + bc.name + "' has size_bytes=0 in config. "
                "Re-run generator on a top_level.v that has --tb-param-size comments.");
    }

    // 2. Open FPGA
    std::cout << "[2] Opening device 0\n";
    auto device = xrt::device(0);
    auto uuid   = device.load_xclbin(xclbin);
    auto krnl   = xrt::kernel(device, uuid, cfg.kernel_name);

    // 3. Allocate buffers
    std::cout << "[3] Allocating " << cfg.buffers.size() << " buffers\n";
    std::vector<xrt::bo> bos;
    bos.reserve(cfg.buffers.size());
    for (const auto& bc : cfg.buffers) {
        bos.emplace_back(device, bc.size_bytes,
                         krnl.group_id(bc.group_id));
        std::cout << "    [" << bc.group_id << "] " << bc.name
                  << "  " << bc.size_bytes << " B  (" << bc.direction << ")\n";
    }

    // 4. Transfer inputs CPU → FPGA HBM
    std::cout << "[4] CPU -> FPGA\n";
    for (size_t i = 0; i < cfg.buffers.size(); ++i) {
        const auto& bc = cfg.buffers[i];
        if (bc.direction == "input" || bc.direction == "inout") {
            auto data = read_bin(in_dir + "/" + bc.name + ".bin", bc.size_bytes);
            bos[i].write(data.data());
            bos[i].sync(XCL_BO_SYNC_BO_TO_DEVICE);
        }
    }

    // 5. Run kernel
    std::cout << "[5] Running kernel '" << cfg.kernel_name << "'\n";
    xrt::run run(krnl);
    for (size_t i = 0; i < cfg.buffers.size(); ++i)
        run.set_arg(cfg.buffers[i].group_id, bos[i]);
    run.start();
    run.wait();
    std::cout << "[6] Kernel done\n";

    // 6. Transfer outputs FPGA HBM → CPU
    std::cout << "[7] FPGA -> CPU\n";
    for (size_t i = 0; i < cfg.buffers.size(); ++i) {
        const auto& bc = cfg.buffers[i];
        if (bc.direction == "output" || bc.direction == "inout") {
            bos[i].sync(XCL_BO_SYNC_BO_FROM_DEVICE);
            std::vector<char> out(bc.size_bytes);
            bos[i].read(out.data());
            write_bin(out_dir + "/" + bc.name + ".bin", out.data(), bc.size_bytes);
        }
    }

    std::cout << "[8] Done.\n";
    return 0;
}
