# RV32I Core — VHDL/Verilog Implementation

![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![ISA](https://img.shields.io/badge/ISA-RISC--V%20RV32I-blue)
![Pipeline](https://img.shields.io/badge/Pipeline-5%20Stages-green)
![License](https://img.shields.io/badge/License-MIT-orange)

A fully custom, industrial-grade 32-bit RISC-V (RV32I) processor core implemented from scratch in VHDL and Verilog, with formal verification in SystemVerilog and VHDL.

---

## Architecture Overview

5-stage in-order pipeline with full forwarding and hazard detection.

```
IF → ID → EX → MEM → WB
```

### Pipeline Stages

| Stage | Description |
|---|---|
| **IF** — Instruction Fetch | Fetches 32-bit instruction from external instruction memory via PC |
| **ID** — Instruction Decode | Decodes instruction, reads Register File, generates control signals, extracts immediate |
| **EX** — Execute | ALU computation, branch condition evaluation, branch target calculation |
| **MEM** — Memory Access | Read/Write to external data memory |
| **WB** — Write Back | Selects result source and writes back to Register File |

### Key Microarchitectural Features

- **Full forwarding** — EX→EX and MEM→EX data forwarding paths
- **Load-use hazard detection** — automatic 1-cycle stall insertion
- **Control hazard handling** — flush on taken branch (predict not-taken)
- **Separate branch adder** — parallel branch target computation in EX stage
- **3-source Write Back MUX** — ALU result, memory data, PC+4

---

## Block Diagram

```
                        ┌─────────────────────────────────────────────────────┐
                        │                  HAZARD DETECTION UNIT              │
                        │           stall ──────────────────────────────────► │
                        └──────────────────────────────────────────────────── ┘
                                           │ flush
                                           ▼
  ┌──────┐  ┌───────┐  ┌───────┐  ┌──────────┐  ┌───────┐  ┌──────────┐  ┌──────┐
  │  IF  │─►│IF/ID  │─►│  ID  │─►│  ID/EX  │─►│  EX  │─►│ EX/MEM  │─►│ MEM  │
  └──────┘  └───────┘  └───────┘  └──────────┘  └───────┘  └──────────┘  └──────┘
                                       │                          │
                                  Control Unit            Forwarding Unit
                                                                  │
                                                           ┌──────────┐  ┌──────┐
                                                           │ MEM/WB  │─►│  WB  │
                                                           └──────────┘  └──────┘
```

---

## Supported Instructions — RV32I (40 instructions)

| Category | Instructions |
|---|---|
| Integer Register-Register | ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND |
| Integer Register-Immediate | ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI |
| Load | LB, LH, LW, LBU, LHU |
| Store | SB, SH, SW |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jump | JAL, JALR |
| Upper Immediate | LUI, AUIPC |
| System | ECALL, EBREAK, FENCE |

---

## Project Structure

```
rv32i_core/
├── rtl/
│   ├── vhdl/
│   │   ├── pkg/
│   │   │   └── rv32i_pkg.vhd          # Types, constants, records
│   │   ├── core/
│   │   │   ├── if_stage.vhd           # Instruction Fetch
│   │   │   ├── id_stage.vhd           # Instruction Decode
│   │   │   ├── ex_stage.vhd           # Execute
│   │   │   ├── mem_stage.vhd          # Memory Access
│   │   │   ├── wb_stage.vhd           # Write Back
│   │   │   ├── register_file.vhd      # 32x32 Register File
│   │   │   ├── alu.vhd                # Arithmetic Logic Unit
│   │   │   ├── imm_extractor.vhd      # Immediate Extractor
│   │   │   ├── control_unit.vhd       # Main Control Unit
│   │   │   ├── forwarding_unit.vhd    # Data Forwarding Unit
│   │   │   └── hazard_detection.vhd   # Hazard Detection Unit
│   │   └── top/
│   │       └── rv32i_core_top.vhd     # Top Level
│   └── verilog/
│       └── (mirror of vhdl/)
├── verif/
│   ├── formal/
│   │   ├── sva/                       # SystemVerilog Assertions
│   │   └── psl/                       # PSL Properties
│   ├── sim/
│   │   ├── tb_rv32i_core.vhd          # VHDL Testbench
│   │   └── tb_rv32i_core.sv           # SystemVerilog Testbench
│   └── tests/
│       └── asm/                       # Assembly test programs
├── docs/
│   └── uarch_spec.md                  # Microarchitecture Specification
├── scripts/
│   ├── sim/
│   │   └── Makefile
│   └── formal/
│       └── Makefile
└── README.md
```

---

## External Memory Interface

The core does not include instruction or data memory. It exposes the following ports:

```vhdl
-- Clock & Reset
clk         : in  std_logic;
rst         : in  std_logic;

-- Instruction Memory Interface
pc_o        : out std_logic_vector(31 downto 0);
instr_i     : in  std_logic_vector(31 downto 0);

-- Data Memory Interface
dm_addr_o   : out std_logic_vector(31 downto 0);
dm_wdata_o  : out std_logic_vector(31 downto 0);
dm_rdata_i  : in  std_logic_vector(31 downto 0);
dm_we_o     : out std_logic;
dm_re_o     : out std_logic;
```

---

## Development Roadmap

- [ ] **Phase 1** — Package & Types (`rv32i_pkg.vhd`)
- [ ] **Phase 2** — Individual blocks (ALU, Register File, Imm Extractor, Control Unit)
- [ ] **Phase 3** — Single-cycle implementation (golden model)
- [ ] **Phase 4** — Pipeline registers
- [ ] **Phase 5** — Forwarding Unit
- [ ] **Phase 6** — Hazard Detection Unit
- [ ] **Phase 7** — Full pipeline integration
- [ ] **Phase 8** — Formal verification (RVFI interface)
- [ ] **Phase 9** — FPGA synthesis & timing closure

---

## Tools

| Tool | Purpose |
|---|---|
| GHDL | VHDL simulation |
| Verilator / Icarus | Verilog simulation |
| Yosys | Synthesis |
| SymbiYosys | Formal verification |
| GTKWave | Waveform viewer |

---

## Reference

- [RISC-V Unprivileged ISA Specification](https://riscv.org/technical/specifications/) — Volume I, RV32I Chapter 2
- [RISC-V ABI Specification](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)

---

## Author

> Project developed from scratch as an industrial-grade learning exercise.
> No shortcuts. No copy-paste. Every line understood before written.