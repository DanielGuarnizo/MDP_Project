from .models import Interface, infer_direction


def gen_accel_config(iface: Interface) -> dict:
    buffers = []
    for i, arg in enumerate(iface.scalar_args):
        buffers.append({
            "name":       arg,
            "size_bytes": iface.buffer_sizes.get(arg, 0),
            "direction":  infer_direction(arg),
            "group_id":   i,
            "axi_bundle": iface.arg_to_bundle.get(arg, ""),
        })
    return {"kernel_name": "panda", "buffers": buffers}
