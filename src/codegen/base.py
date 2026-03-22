from __future__ import annotations
from mapping_types import MappingInfo


class CodeGenBase:
    def __init__(self, info: MappingInfo):
        self.info = info

    def headers_and_defines(self) -> str:
        raise NotImplementedError

    def top_signature(self, out_banks: int) -> str:
        raise NotImplementedError

    def top_pragmas(self, out_banks: int) -> str:
        return ""

    def top_level_body_seq(self) -> str:
        raise NotImplementedError

    def top_level_body_sa(self) -> str:
        raise NotImplementedError