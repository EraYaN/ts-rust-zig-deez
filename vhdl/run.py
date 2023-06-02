#!/usr/bin/env python3

"""
VHDL UART
---------

A more realistic test bench of an UART to show VUnit VHDL usage on a
typical module.
"""

from pathlib import Path
from vunit import VUnit

VU = VUnit.from_argv(compile_builtins=False)
VU.add_vhdl_builtins()
VU.add_osvvm()
VU.add_verification_components()


SRC_PATH = Path(__file__).parent / "src"

VU.add_library("lexer_lib").add_source_files(SRC_PATH / "*.vhd")
VU.add_library("tb_lexer_lib").add_source_files(SRC_PATH / "test" / "*.vhd")

VU.main()