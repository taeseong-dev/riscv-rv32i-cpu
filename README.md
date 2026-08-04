# RISC-V RV32I CPU Design

Verilog를 사용하여 RV32I 기본 명령어 37개를 지원하는 Single-Cycle CPU를 설계하고, 명령어별 동작을 Simulation으로 검증한 프로젝트입니다.

---

## Project Overview

| 항목 | 내용 |
|:---|:---|
| Language | Verilog |
| Development Environment | Vivado |
| ISA | RISC-V RV32I |
| Architecture | Single-Cycle |
| Instructions | 37 Instructions |
| Verification | Simulation |

---

## Contents

- [RV32I Instruction Set](#rv32i-instruction-set)
  - [Instruction Format](#instruction-format)
- [Single-Cycle CPU](#single-cycle-cpu)
  - [System Architecture](#system-architecture)
  - [Instruction Type별 Datapath](#instruction-type별-datapath)
  - [Simulation Verification](#simulation-verification)

---

## RV32I Instruction Set

`FENCE`, `ECALL`, `EBREAK`를 제외한 RV32I 기본 명령어 37개 설계 및 Type별 동작 검증

| Type | Instruction | 개수 |
|:---|:---|:---:|
| R-Type | ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND | 10 |
| I-Type | ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI | 9 |
| Load | LB, LH, LW, LBU, LHU | 5 |
| Store | SB, SH, SW | 3 |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU | 6 |
| Upper Immediate | LUI, AUIPC | 2 |
| Jump | JAL, JALR | 2 |
| **Total** |  | **37** |

### Instruction Format

RV32I Instruction Type에 따른 Register, Function, Immediate 및 Opcode Field 구성

- `opcode`를 통한 Instruction Type 구분
- `funct3` 및 `funct7`을 통한 세부 연산 구분

<img src="images/rv32i_data_format.png" width="700">

---

## Single-Cycle CPU

Instruction Fetch, Decode, Execute, Memory Access 및 Writeback을 하나의 Clock Cycle에서 수행하는 구조

### System Architecture

<img src="images/rv32i_top.png" width="900">

| Module | Description |
|:---|:---|
| Program Counter | 현재 Instruction Address 저장 및 다음 PC 계산 |
| Instruction Memory | PC에 해당하는 Instruction 출력 |
| Control Unit | Opcode, Funct3 및 Funct7에 따른 Control Signal 생성 |
| Register File | 연산에 사용할 Data Read 및 연산 결과 저장 |
| Immediate Generator | Instruction Type에 따른 Immediate 값 생성 |
| ALU | 산술·논리 연산 및 Branch 조건 비교 |
| Data Memory | Byte, Halfword 및 Word 단위 Load/Store 수행 |

### Instruction Type별 Datapath

Instruction Type에 따라 사용되는 데이터 경로 및 Control Signal 구성

#### R-Type

<img src="images/rv32i_rtype.png" width="900">

Register File에서 읽은 두 값을 ALU 입력으로 사용하고, 연산 결과를 Register File에 저장

#### S-Type (Store)

<img src="images/rv32i_stype.png" width="900">

Register File에서 읽은 값과 Immediate 값을 더하여 Memory Address를 계산하고, Register File의 데이터를 Data Memory에 저장

#### I-Type (Immediate)

<img src="images/rv32i_itype.png" width="900">

- Register File에서 읽은 값과 Immediate 값을 ALU 입력으로 사용
- ALU 연산 결과를 Register File에 저장
- `funct3`에 따른 ALU 연산 구분
- `funct7[5]`를 사용한 SRLI/SRAI 구분

#### I-Type (Load)

<img src="images/rv32i_iltype.png" width="900">

Register File에서 읽은 값과 Immediate 값을 더하여 Memory Address를 계산하고, Data Memory에서 읽은 값을 Register File에 저장

#### B-Type (Branch)

<img src="images/rv32i_btype.png" width="900">

- Register File에서 읽은 두 값의 Branch 조건 비교
- 조건에 따른 다음 PC 값 결정
- 그림은 조건이 참인 경우로, `PC + Immediate`를 다음 PC로 선택

#### U-Type (LUI)

<img src="images/rv32i_lui.png" width="900">

Instruction의 상위 Immediate 값을 Register File에 저장

#### U-Type (AUIPC)

<img src="images/rv32i_auipc.png" width="900">

현재 PC와 Instruction의 상위 Immediate 값을 더한 결과를 Register File에 저장

#### J-Type (JAL)

<img src="images/rv32i_jtype.png" width="900">

- `PC + Immediate`로 Jump
- `PC + 4`를 Register File에 저장

#### I-Type (JALR)

<img src="images/rv32i_jltype.png" width="900">

- Register File에서 읽은 값과 Immediate 값을 더한 주소로 Jump
- `PC + 4`를 Register File에 저장

### Simulation Verification

RV32I 37개 Instruction을 Type별로 Simulation하여 ALU 연산, Memory Access, Register Writeback 및 PC Update 동작 확인

#### R-Type

<img src="images/rv32i_rtype_sim.png" width="900">

- `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` 연산 결과 확인
- Signed 및 Unsigned 비교 연산 결과 확인
- Logical Shift 및 Arithmetic Shift 결과 확인

#### I-Type

<img src="images/rv32i_itype_sim.png" width="900">

- `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI` 연산 결과 확인
- `SLLI`, `SRLI`, `SRAI` Shift 연산 결과 확인
- `funct7[5]`에 따른 `SRLI` 및 `SRAI` 동작 구분 확인

#### S-Type (Store)

<img src="images/rv32i_stype_sim.png" width="900">

- `SB`, `SH`, `SW`의 Byte, Halfword 및 Word 단위 Memory Write 확인
- Address 하위 2-bit에 따른 Data 저장 위치 확인
- 저장 크기에 따라 선택된 Byte 및 Halfword만 변경되는 동작 확인

#### I-Type (Load)

<img src="images/rv32i_iltype_sim.png" width="900">

- `LB`, `LH`, `LW`의 Byte, Halfword 및 Word 단위 Memory Read 확인
- Address 하위 2-bit에 따른 Data 선택 결과 확인
- Memory Read Data의 Register File 저장 확인

<img src="images/rv32i_iltype_sim_u.png" width="900">

- `LBU`, `LHU`의 Byte 및 Halfword 단위 Memory Read 확인
- Unsigned Load Instruction의 Zero Extension 결과 확인
- Zero Extension된 Data의 Register File 저장 확인

#### B-Type (Branch)

<img src="images/rv32i_btype_sim.png" width="900">

- `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`의 Branch 조건 비교 결과 확인
- Branch 조건의 True/False에 따른 PC Update 확인
- Signed 및 Unsigned 비교에 따른 Branch 동작 확인

#### U-Type

<img src="images/rv32i_utype_sim.png" width="900">

- `LUI`의 상위 Immediate 값 저장 결과 확인
- `AUIPC`의 `PC + Immediate` 연산 결과 확인
- 연산 결과의 Register File 저장 확인

#### J-Type (JAL)

<img src="images/rv32i_jtype_sim.png" width="900">

- `PC + Immediate`에 따른 Jump Address 계산 확인
- Jump Address에 따른 PC Update 확인
- `PC + 4`의 Register File 저장 확인

#### I-Type (JALR)

<img src="images/rv32i_jltype_sim.png" width="900">

- Register File의 값과 Immediate를 더한 Jump Address 계산 확인
- Jump Address에 따른 PC Update 확인
- `PC + 4`의 Register File 저장 확인
