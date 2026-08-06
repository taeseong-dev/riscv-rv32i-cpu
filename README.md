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

- 산술·논리 및 Shift 연산 결과의 Register File 저장 확인
- `SLT`와 `SLTU`의 Signed/Unsigned 비교 결과 확인
- `SRL`과 `SRA`의 Logical/Arithmetic Shift 결과 확인

#### I-Type

<img src="images/rv32i_itype_sim.png" width="900">

- Immediate를 사용한 산술·논리 연산 결과 확인
- `SLTI`와 `SLTIU`의 Signed/Unsigned 비교 결과 확인
- `SLLI`, `SRLI`, `SRAI`의 Shift 연산 및 `SRLI`/`SRAI` 구분 확인

#### S-Type (Store)

<img src="images/rv32i_stype_sim.png" width="900">

- `SB`, `SH`, `SW`의 Byte, Halfword 및 Word 단위 Memory Write 확인
- Address 하위 2-bit에 따른 Data 저장 위치 확인
- 저장 크기에 따라 선택된 Byte 및 Halfword만 변경되는 동작 확인

#### I-Type (Load)

<img src="images/rv32i_iltype_sim.png" width="900">

- `LB`, `LH`, `LW`의 Byte, Halfword 및 Word 단위 Memory Read 확인
- Address 하위 2-bit에 따른 Byte 및 Halfword 선택 확인
- `LB`, `LH`의 Sign Extension 및 Register File 저장 확인

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

---

---

---

## Multi-Cycle CPU

Single-Cycle CPU의 명령어 실행 과정을 여러 Clock Cycle로 분리한 Multi-Cycle 구조

- `FETCH`, `DECODE`, `EXECUTE`, `MEM`, `WB` State로 명령어 실행 단계 구성
- Decode, Execute 및 Memory Access 결과를 Register에 저장
- Instruction Type에 따라 필요한 State만 수행
- Instruction Memory와 Data Memory를 분리한 Harvard 구조 적용

### System Architecture

<a href="images/rv32i_multicycle_bd.png">
  <img src="images/rv32i_multicycle_bd.png" alt="RV32I Multi-Cycle Architecture">
</a>

각 단계에서 생성된 데이터를 Register에 저장하여 다음 State에서 사용하도록 Datapath 구성

| Register | 저장 값 | 역할 |
|:---|:---|:---|
| `rd1 reg` | Register File의 RS1 Data | ALU 첫 번째 입력 및 JALR Address 계산 |
| `rd2 reg` | Register File의 RS2 Data | ALU 두 번째 입력 및 Store Data 전달 |
| `imm reg` | Immediate | ALU 연산, Memory Address 및 다음 PC 계산 |
| `alu reg` | ALU 연산 결과 | Load/Store의 Data Memory Address 유지 |
| `dwdata reg` | Register File의 RS2 Data | Store Instruction의 Memory Write Data 유지 |
| `next pc reg` | 계산된 다음 PC | 다음 `FETCH` State에서 PC 갱신 |
| `drdata reg` | Data Memory Read Data | Load Instruction의 Writeback Data 유지 |

### State Operation

| State | Operation |
|:---|:---|
| `FETCH` | 계산된 다음 PC를 PC Register에 저장하고 해당 주소의 Instruction 출력 |
| `DECODE` | Register File Data Read, Immediate 생성 및 Decode Register 저장 |
| `EXECUTE` | ALU 연산, Branch 조건 비교, Memory Address 및 다음 PC 계산 |
| `MEM` | Load/Store Instruction의 Data Memory 접근 |
| `WB` | Data Memory에서 읽은 값을 Register File에 저장 |

### Control Unit FSM

<a href="images/rv32i_multicycle_fsm.png">
  <img src="images/rv32i_multicycle_fsm.png" alt="RV32I Multi-Cycle Control Unit FSM" width="500">
</a>

Control Unit의 FSM을 통해 현재 State와 Instruction Type에 따른 Control Signal 생성 및 State 전환

#### R-Type / I-Type / Branch / Upper Immediate / Jump

```text
FETCH → DECODE → EXECUTE → FETCH
```

- R-Type 및 I-Type의 ALU 연산 수행
- Branch 조건 비교 및 다음 PC 결정
- LUI, AUIPC, JAL 및 JALR 결과 처리
- Register Write가 필요한 Instruction은 `EXECUTE` State에서 결과 저장

#### S-Type (Store)

```text
FETCH → DECODE → EXECUTE → MEM → FETCH
```

- `EXECUTE`: `RS1 + Immediate`를 통한 Memory Address 계산
- `MEM`: `dwdata reg`에 저장된 RS2 Data를 Data Memory에 저장

#### I-Type (Load)

```text
FETCH → DECODE → EXECUTE → MEM → WB → FETCH
```

- `EXECUTE`: `RS1 + Immediate`를 통한 Memory Address 계산
- `MEM`: Data Memory Read 및 `drdata reg` 저장
- `WB`: `drdata reg`의 값을 Register File에 저장

> Writeback MUX는 ALU Result, Memory Read Data, Immediate, `PC + Immediate` 및 `PC + 4` 중 Register File에 저장할 값을 선택합니다. FSM의 `WB` State는 Load Instruction의 Memory Read Data를 저장할 때 사용합니다.

### Simulation Verification

Instruction Type에 따른 State 전환과 단계별 Register 저장 동작을 Simulation으로 확인

#### R-Type / I-Type

<img src="images/rv32i_multicycle_ri_sim.png">

- `FETCH → DECODE → EXECUTE → FETCH` State 전환 확인
- Decode 단계에서 RS1, RS2 및 Immediate Data 저장 확인
- Execute 단계에서 ALU 연산 수행 및 Register File Write 확인

#### S-Type (Store)

<img src="images/rv32i_multicycle_store_sim.png">

- `FETCH → DECODE → EXECUTE → MEM → FETCH` State 전환 확인
- Execute 단계에서 Memory Address 계산 확인
- `alu reg`와 `dwdata reg`에 Address 및 Store Data 저장 확인
- MEM 단계에서 Data Memory Write 확인

#### I-Type (Load)

<img src="images/rv32i_multicycle_load_sim.png">

- `FETCH → DECODE → EXECUTE → MEM → WB → FETCH` State 전환 확인
- Execute 단계에서 Memory Address 계산 확인
- MEM 단계에서 Memory Read Data의 `drdata reg` 저장 확인
- WB 단계에서 Load Data의 Register File 저장 확인
