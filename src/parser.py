import re

class MappingInfo:
    def __init__(self):
        self.workload_type = None
        self.total_dims = {}
        self.levels = []
        self.tiling = {}
        self.spatial_levels = [] # List of spatial level names

    def get_grid_size(self):
        """Calculates the total grid size from all spatial levels."""
        total_instances = 1
        for level_name in self.spatial_levels:
            if level_name in self.tiling:
                for factor in self.tiling[level_name].values():
                    total_instances *= factor
        # For now, let's assume a 1D array of PEs for simplicity, which is common.
        # A 2D grid would require more sophisticated parsing of X/Y dimensions.
        return total_instances

def parse_ff_output(filepath="FF_output.txt"):
    info = MappingInfo()
    with open(filepath, 'r') as f:
        lines = f.readlines()

    in_mapping_section = False
    for line in lines:
        line = line.strip()

        if line.startswith("Computation:"):
            # This part remains the same
            dims_str = line.split('{')[1].split('}')[0]
            dims = dict(item.split(': ') for item in dims_str.split(', '))
            info.total_dims = {k: int(v) for k, v in dims.items()}
            info.workload_type = 'CONV' if 'P' in info.total_dims else 'GEMM'

        if line.startswith("Mapping:"):
            in_mapping_section = True
            continue

        if in_mapping_section and "-->" in line:
            parts = line.split('-->')
            level_name = parts[0].strip().replace('-', '')
            info.levels.append(level_name)
            info.tiling[level_name] = {}
            
            # Identify spatial levels based on FactorFlow/Timeloop conventions
            # 'SA' for Spatial Array, 'PEs' for Processing Elements, 'Fanout'
            if any(s in level_name for s in ["SA", "PEs", "Fanout", "Distribution"]):
                info.spatial_levels.append(level_name)

            if len(parts[1].strip()) > 0:
                factors_str = parts[1].strip()
                factors = dict(item.split(': ') for item in factors_str.split(', '))
                info.tiling[level_name] = {k: int(v) for k, v in factors.items()}
        elif in_mapping_section and not line:
             in_mapping_section = False

    return info