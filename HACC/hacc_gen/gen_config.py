from .models import Interface, infer_direction


def gen_accel_config(iface: Interface, workload: str | None = None, dims: list | None = None) -> dict:
    buffers = []
    for i, arg in enumerate(iface.scalar_args):
        buffers.append({
            "name":       arg,
            "size_bytes": iface.buffer_sizes.get(arg, 0),
            "direction":  infer_direction(arg),
            "group_id":   i,
            "axi_bundle": iface.arg_to_bundle.get(arg, ""),
        })
    cfg: dict = {"kernel_name": "panda", "buffers": buffers}
    if workload and dims:
        if workload == "conv" and len(dims) == 6:
            M, P, Q, C, R, S = dims
            cfg["workload"] = {"type": "conv", "M": M, "P": P, "Q": Q, "C": C, "R": R, "S": S}
        elif workload == "gemm" and len(dims) == 3:
            M, K, N = dims
            cfg["workload"] = {"type": "gemm", "M": M, "K": K, "N": N}
    return cfg
