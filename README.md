# P6-CPU设计文档

## 流水线架构

```markdown
- mips.v
	- IF.v #取指阶段
		- pc.v
		- im.v
	- IF_ID.v #IF与ID之间的寄存器
	- ID.v #译码阶段
		- ctrl.v #采用分布式译码
		- grf.v # 寄存器堆
		- ext.v # 立即数扩展
		- cmp.v # 比较2个数
		- npc.v # 为B类/J计算下条地址
	- ID_EX.v #ID与EX之间的寄存器
	- EX.v  #执行阶段
		- ctrl.v #采用分布式译码
		- alu.v
	- EX_MEM.v #EX与MEM之间的寄存器
	- MEM.v #存储阶段
		- ctrl.v #采用分布式译码
		- dm.v
	- MEM_WB.v #MEM与WB之间的寄存器
	- HAZARD_CTRL.v #冒险控制模块
	
```

### IF

#### 顶层

> Instruction Fetch阶段,从指令寄存器中读取指令

| 端口     | In/Out? | 位宽   | 功能       |
| -------- | ------- | ------ | ---------- |
| clk      | in      |        | 时钟信号   |
| reset    | in      |        | 重置信号   |
| enablePC | in      |        | 使能信号   |
| NPC      | in      | [31:0] | PC地址输入 |
| IF_PC    | out     | [31:0] | 输出PC地址 |

#### PC部件

| 端口   | In/Out? | 位宽   | 功能       |
| ------ | ------- | ------ | ---------- |
| clk    | in      |        | 时钟信号   |
| reset  | in      |        | 重置信号   |
| enable | in      |        | 使能信号   |
| NPC    | in      | [31:0] | PC地址输入 |
| PC     | out     | [31:0] | 输出PC地址 |

### IF_ID

> 在时钟上升沿将IF_PC,IF_instr的值传递给ID_PC,ID_instr

| 端口     | In/Out? | 位宽   | 功能         |
| -------- | ------- | ------ | ------------ |
| clk      | in      |        |              |
| reset    | in      |        |              |
| enable   | in      |        |              |
| IF_PC    | in      | [31:0] | IF传入PC地址 |
| IF_instr | in      | [31:0] | IF传入指令   |
| ID_PC    | out     | [31:0] | ID接收PC地址 |
| ID_instr | out     | [31:0] | IF接收指令   |



### ID

> Instruction Decode阶段

#### 顶层

| 端口           | In/Out? | 位宽   | 功能                                                        |
| -------------- | ------- | ------ | ----------------------------------------------------------- |
| clk            | in      |        |                                                             |
| reset          | in      |        |                                                             |
| IF_PC          | in      | [31:0] | IF区的PC,用于正常的地址+4操作                               |
| ID_PC          | in      | [31:0] | ID区的PC                                                    |
| ID_instr       | in      | [31:0] | ID区的指令                                                  |
| ID_RD1_forward | in      | [31:0] | 转发的Data1                                                 |
| ID_RD2_forward | in      | [31:0] | 转发的Data2                                                 |
| WB_WD          | in      | [31:0] | 写入数据,来自于WB阶段                                       |
| WB_A3          | in      | [31:0] | 写入寄存器地址,来自于WB阶段                                 |
| WB_PC          | in      | [31:0] | 写入数据对应PC地址,传递给$display语句,作为显示,来自于WB阶段 |
| ID_RD1         | out     | [31:0] | ID输出rs寄存器读出值                                        |
| ID_RD2         | out     | [31:0] | ID输出rt寄存器读出值                                        |
| ID_IMM32       | out     | [31:0] | ID输出经过位扩展的立即数                                    |
| ID_A3          | out     | [4:0]  | ID阶段的A3,向后传递用                                       |
| ID_WD          | out     | [31:0] | ID阶段的写入数据,向后传递                                   |
| NPC            | out     | [31:0] | ID阶段(内部NPC模块)计算的下一个地址                         |
| ID_A1_USE      | out     | [1:0]  | ID阶段rs寄存器的$T_{USE}$                                   |
| ID_A2_USE      | out     | [1:0]  | ID阶段rt寄存器的$T_{USE}$                                   |
| ID_MD          | out     |        | ID区当前是否在处理乘除相关指令                              |

#### EXT部件

> 立即数扩展

| 端口       | In/Out? | 位宽   | 功能                       |
| ---------- | ------- | ------ | -------------------------- |
| imm16      | in      | [15:0] | 输入的16位立即数           |
| ExtControl | in      |        | 决定零扩展还是符号扩展     |
| imm32      | out     | [31:0] | 输出的为扩展后的32位立即数 |

#### CMP部件

> 判断两个输入(从寄存器取出来的两个值)是否相等,输出zero,用于处理beq信号通路

| 端口       | In/Out? | 位宽   | 功能                                      |
| ---------- | ------- | ------ | ----------------------------------------- |
| A          | in      | [31:0] | 输入数据,接收的是转发的Data1(RD1_forward) |
| B          | in      | [31:0] | 输入数据,接收的是转发的Data2(RD2_forward) |
| CMPControl | in      | [3:0]  | CMP部件控制信号(选择比较方式)             |
| zero       | out     |        | 若相等则输出1,否则输出0                   |

#### CMPControl信号表

| 指令 | CMPControl |
| ---- | ---------- |
| beq  | 4'b0000    |
| bgez | 4'b0001    |
| bgtz | 4'b0010    |
| blez | 4'b0011    |
| bltz | 4'b0100    |
| bne  | 4'b0101    |

#### NPC部件

> 计算下一个PC地址

| 端口        | In/Out? | 位宽   | 功能                |
| ----------- | ------- | ------ | ------------------- |
| IF_PC       | in      | [31:0] | IF输出的PC          |
| ID_PC       | in      | [31:0] |                     |
| ID_imm26    | in      | [25:0] |                     |
| Jr_Reg_Data | in      | [31:0] | Jr指定的寄存器的值  |
| Branch      | in      |        | Branch信号(beq激活) |
| Jal         | in      |        | Jal信号(jal激活)    |
| Jr          | in      |        | Jr信号(jr激活)      |
| NPC         | out     | [31:0] | 下一个PC地址        |

#### Control部件(共用)

> 控制信号生成部件,这里我们采用的是分布式译码,这里展示的共用Control部件在ID阶段被使用的端口

| 端口       | In/Out? | 位宽   | 功能                                                         |
| :--------- | ------- | ------ | ------------------------------------------------------------ |
| instr      | in      | [31:0] | 输入的指令                                                   |
| zero       | in      |        | ID_RD1_forward与ID_RD2_forward是否相等                       |
| Branch     | out     |        | Branch信号(beq激活)                                          |
| Jal        | out     |        | Jal信号(jal激活)                                             |
| Jr         | out     |        | Jr信号(jr激活)                                               |
| ExtControl | out     |        | 控制ext部件的信号                                            |
| Sel_ID_WD  | out     |        | 与jal相关,若执行jal指令则为1,该信号为1时将Write Data(写入寄存器)指定为ID_PC+8 |
| ID_A3      | out     | [4:0]  | 解码阶段输出的写入寄存器地址                                 |
| ID_A1_USE  | out     | [1:0]  | rs的$T_{USE}$                                                |
| ID_A2_USE  | out     | [1:0]  | rt的$T_{USE}$                                                |
| CMPControl | out     | [3:0]  | CMP部件控制信号(选择比较方式)                                |
| ID_MD      | out     |        | ID区当前是否在处理乘除相关指令                               |

#### ID控制信号表

| 指令/信号 | ExtControl                  | Sel_ID_WD   | ID_A3 | Branch                | Jal  | Jr   |
| --------- | --------------------------- | ----------- | ----- | --------------------- | ---- | ---- |
| ori       | 1(立即数零扩展)             | 0           | rt    |                       |      |      |
| add       | \                           | 0           | rd    |                       |      |      |
| sub       | \                           | 0           | rd    |                       |      |      |
| lw        | 0(立即数符号扩展)           | 0           | rt    |                       |      |      |
| sw        | 0(立即数符号扩展)           | 0           | $0    |                       |      |      |
| beq       | 0(立即数符号扩展)           | 0           | $0    | 1 if zero == 1 else 0 |      |      |
| lui       | 0(立即数符号扩展)(其实随意) | 0           | rt    |                       |      |      |
| jal       | \                           | 1(选择PC+8) | $31   |                       | 1    |      |
| jr        | \                           | 0           | \     |                       |      | 1    |
| swc       | \                           | 0           | rd    |                       |      |      |
| bonall    | 0(立即数符号扩展)           | 1           | 31    |                       |      |      |
| lh        | 0                           | 0           | rt    |                       |      |      |
| sh        | 0                           | 0           | \     |                       |      |      |
| lb        | 0                           | 0           | rt    |                       |      |      |
| sb        | 0                           | 0           | \     |                       |      |      |
| and       | \                           | 0           | rd    |                       |      |      |
| or        | \                           | 0           | rd    |                       |      |      |
| slt       | \                           | 0           | rd    |                       |      |      |
| sltu      | \                           | 0           | rd    |                       |      |      |
| addi      | 0                           | 0           | rt    |                       |      |      |
| andi      | 0                           | 0           | rt    |                       |      |      |
| mult      | \                           | 0           | $0    |                       |      |      |
| multu     | \                           | 0           | $0    |                       |      |      |
| div       | \                           | 0           | $0    |                       |      |      |
| divu      | \                           | 0           | $0    |                       |      |      |
| mflo      | \                           | 0           | rd    |                       |      |      |
| mfhi      | \                           | 0           | rd    |                       |      |      |
| mtlo      | \                           | 0           | $0    |                       |      |      |
| mthi      | \                           | 0           | $0    |                       |      |      |

#### $T_{USE}$表

|        | ID_A1_USE | ID_A2_USE |
| ------ | --------- | --------- |
| add    | 1         | 1         |
| sub    | 1         | 1         |
| ori    | 1         | 3(z)      |
| lw     | 1         | 3(z)      |
| sw     | 1         | 2         |
| beq    | 0         | 0         |
| lui    | 3(z)      | 3(z)      |
| jal    | 3(z)      | 3(z)      |
| jr     | 0         | 3(z)      |
| swc    | 1         | 1         |
| bonall | 0         | 0         |
| lb     | 1         | 3(z)      |
| sb     | 1         | 2         |
| lh     | 1         | 3(z)      |
| sh     | 1         | 2         |
| and    | 1         | 1         |
| or     | 1         | 1         |
| slt    | 1         | 1         |
| sltu   | 1         | 1         |
| addi   | 1         | 0         |
| andi   | 1         | 0         |
| mult   | 1         | 1         |
| div    | 1         | 1         |
| multu  | 1         | 1         |
| divu   | 1         | 1         |
| mflo   | 3(z)      | 3         |
| mfhi   | 3         | 3         |
| mtlo   | 1         | 3         |
| mthi   | 1         | 3         |

#### GRF部件

> 32个32bit寄存器组成的寄存器堆

| 端口  | In/Out? | 位宽   | 功能                |
| ----- | ------- | ------ | ------------------- |
| clk   | in      |        |                     |
| reset | in      |        |                     |
| A1    | in      | [4:0]  | A1读出寄存器地址    |
| A2    | in      | [4:0]  | A2读出寄存器地址    |
| A3    | in      | [4:0]  | A3写入寄存器地址    |
| WD    | in      | [31:0] | 写入数据            |
| PC    | in      | [31:0] | 当前PC(\$display用) |
| RD1   | out     | [31:0] | A1寄存器读出值      |
| RD2   | out     | [31:0] | A2寄存器读出值      |



### ID_EX

| 端口     | In/Out? | 位宽   | 功能                     |
| -------- | ------- | ------ | ------------------------ |
| clk      | in      |        |                          |
| reset    | in      |        |                          |
| enable   | in      |        | 使能信号                 |
| flush    | in      |        | 冲洗信号,和reset作用相同 |
| ID_PC    | in      | [31:0] |                          |
| ID_instr | in      | [31:0] |                          |
| ID_RD1   | in      | [31:0] |                          |
| ID_RD2   | in      | [31:0] |                          |
| ID_imm32 | in      | [31:0] |                          |
| ID_A3    | in      | [4:0]  |                          |
| ID_WD    | in      | [31:0] |                          |
| EX_PC    | out     | [31:0] |                          |
| EX_instr | out     | [31:0] |                          |
| EX_RD1   | out     | [31:0] |                          |
| EX_RD2   | out     | [31:0] |                          |
| EX_imm32 | out     | [31:0] |                          |
| EX_A3    | out     | [4:0]  |                          |
| EX_WD    | out     | [31:0] |                          |



### EX

#### 顶层

| 端口           | In/Out? | 位宽   | 功能                                                |
| -------------- | ------- | ------ | --------------------------------------------------- |
| clk            | in      |        |                                                     |
| reset          | in      |        |                                                     |
| EX_instr       | in      | [31:0] | EX阶段的指令                                        |
| EX_imm32       | in      | [31:0] | 32位扩展的立即数                                    |
| EX_WD          | in      | [31:0] | EX阶段接收的写入寄存器堆的数据                      |
| EX_RD1_forward | in      | [31:0] | 接收hazard ctrl部件向EX阶段传递的转发数据寄存器A1值 |
| EX_RD2_forward | in      | [31:0] | 接收hazard ctrl部件向EX阶段传递的转发数据寄存器A2值 |
| EX_MEM_RES     | out     | [31:0] | 传递ALU计算结果                                     |
| EX_MEM_WD      | out     | [31:0] | 传递给EX_MEM流水寄存器的Write Data                  |
| EX_MEM_RD2     | out     | [31:0] | 传递给EX_MEM流水寄存器的Read Data2                  |
| EX_NEW         | out     | [1:0]  | EX阶段的$T_{NEW}$                                   |

#### MULT_DIV部件

| 端口        | In/Out? | 位宽   | 功能                      |
| ----------- | ------- | ------ | ------------------------- |
| clk         | in      |        | 时钟信号                  |
| reset       | in      |        | 重制信号                  |
| A           | in      | [31:0] | 计算数A                   |
| B           | in      | [31:0] | 计算数B                   |
| start       | in      |        | 有效一个时钟周期,启动信号 |
| MULT_DIV_OP | in      | [2:0]  | 乘除模块计算方式          |
| MFHI        | in      |        | mfhi信号                  |
| MFLO        | in      |        | mflo信号                  |
| busy        | out     |        | 输出延迟信号              |
| HI          | out     | [31:0] | $hi值                     |
| LO          | out     | [31:0] | $lo值                     |

#### 乘除槽相关信号表

| 指令/信号 | MULT_DIV_OP | MULT_DIV_START |
| --------- | ----------- | -------------- |
| mult      | `mult       | 1              |
| multu     | `multu      | 1              |
| div       | `div        | 1              |
| divu      | `divu       | 1              |

#### ALU部件

| 端口   | In/Out? | 位宽   | 功能        |
| ------ | ------- | ------ | ----------- |
| SrcA   | in      | [31:0] | 操作数A     |
| SrcB   | in      | [31:0] | 操作数B     |
| ALUOp  | in      | [3:0]  | 计算方式    |
| ALURes | out     | [31:0] | ALU计算结果 |

#### Control部件(*共用*)

| 端口            | In/Out? | 位宽   | 功能                                        |
| --------------- | ------- | ------ | ------------------------------------------- |
| instr           | in      | [31:0] |                                             |
| ALUOp           | out     | [3:0]  | 选择ALU操作方式                             |
| ALU_A_Sel       | out     |        | 选择                                        |
| ALU_B_Sel       | out     |        | 选择32位立即数或者寄存器rt的值              |
| WD_Sel          | out     |        | 选择Write Data来源(1:ID阶段的PC+8,0:ALURes) |
| EX_NEW          | out     |        | 当前EX阶段$T_{USE}$                         |
| MULT_DIV_OP     | out     |        | 乘除模块计算方式                            |
| MULT_DIV _START | out     |        | 乘除模块开始信号                            |
| MTHI            | out     |        | mthi信号,下同理                             |
| MTLO            | out     |        |                                             |
| MFHI            | out     |        |                                             |
| MFLO            | out     |        |                                             |

#### EX控制信号表

| 指令/信号 | ALUOp    | ALU_B_Sel       | WD_Sel                    |
| --------- | -------- | --------------- | ------------------------- |
| ori       | `aluOr   | 1(选择立即数)   | 0(Write Data选择aluRes)   |
| add       | `aluAdd  | 0(选择rt寄存器) | 0                         |
| sub       | `aluSub  | 0(选择rt寄存器) | 0                         |
| beq       | \        | \               | \                         |
| lw        | `aluAdd  | 1(选择立即数)   | 0                         |
| sw        | `aluAdd  | 1(选择立即数)   | 0                         |
| lui       | `aluLui  | 1(选择立即数)   | 0                         |
| jal       | \        | \               | 1(Write Data选择ID传递值) |
| jr        | \        | \               | \                         |
| swc       | `aluSwc  | 0               | 0                         |
| bonall    | \        | \               | 1(Write Data选择ID传递值) |
| and       | `aluAnd  | 0(选择rt寄存器) | 0                         |
| or        | `aluOr   | 0(选择rt寄存器) | 0                         |
| slt       | `aluSlt  | 0               | 0                         |
| sltu      | `aluSltu | 0               | 0                         |
| addi      | `aluAdd  | 1               | 0                         |
| andi      | `aluAnd  | 1               | 0                         |
| mult      | \        | \               | 0                         |
| mflo      | \        | \               | \                         |
| mfhi      | \        | \               | \                         |

#### EX$T_{NEW}$表

|        | EX_NEW |
| ------ | ------ |
| add    | 1      |
| sub    | 1      |
| ori    | 1      |
| lw     | 2      |
| sw     | 0      |
| beq    | 0      |
| lui    | 1      |
| jal    | 0      |
| jr     | 0      |
| swc    | 1      |
| bonall | 0      |
| lb     | 2      |
| sb     | 0      |
| lh     | 2      |
| sh     | 0      |
| and    | 1      |
| or     | 1      |
| slt    | 1      |
| sltu   | 1      |
| addi   | 1      |
| andi   | 1      |
| mflo   | 1      |
| mfhi   | 1      |



### EX_MEM

| 端口      | In/Out? | 位宽   | 功能             |
| --------- | ------- | ------ | ---------------- |
| clk       | in      |        |                  |
| reset     | in      |        |                  |
| flush     | in      |        |                  |
| EX_PC     | in      | [31:0] | EX阶段PC地址     |
| EX_instr  | in      | [31:0] | EX阶段指令       |
| EX_A3     | out     | [4:0]  | EX阶段传递的A3   |
| EX_WD     | out     | [31:0] | EX阶段Write Data |
| EX_RES    | out     | [31:0] | EX阶段ALURes     |
| EX_RD2    | out     | [31:0] | EX阶段Read Data2 |
| MEM_PC    | out     | [31:0] | MEM阶段PC地址    |
| MEM_instr | out     | [31:0] | MEM阶段指令      |
| MEM_A3    | out     | [4:0]  |                  |
| MEM_WD    | out     | [31:0] |                  |
| MEM_RES   | out     | [31:0] |                  |
| MEM_RD2   | out     | [31:0] |                  |

### MEM

#### 顶层

| 端口            | In/Out? | 位宽   | 功能                         |
| --------------- | ------- | ------ | ---------------------------- |
| clk             | in      |        |                              |
| reset           | in      |        |                              |
| MEM_PC          | in      | [31:0] |                              |
| MEM_instr       | in      | [31:0] |                              |
| MEM_WD          | in      | [31:0] |                              |
| MEM_RES         | in      | [31:0] |                              |
| MEM_RD2_forward | in      | [31:0] | WB转发的Read Data2           |
| MEM_A3          | in      | [4:0]  | MEM传递的A3寄存器地址        |
| RD              | in      | [31:0] | 从Memory中读出的数据         |
| MEM_WB_A3       | out     | [4:0]  |                              |
| MEM_WB_WD       | out     | [31:0] |                              |
| MEM_A2_NEW      | out     | [1:0]  | MEM$T_{NEW}$                 |
| MEM_BYTE_EN     | out     | [3:0]  | 写入MEM数据的按字节使能信号  |
| MEM_WRITE_DATA  | out     | [31:0] | 写入MEM,按字节重新排序的数据 |
| MEM_DATA_ADDR   | out     | [31:0] | 写入或读出的Memory地址       |
| MEM_INST_ADDR   | out     | [31:0] | 当load/store指令对应的PC地址 |

#### MEMControl部件(共用)

| 端口            | In/Out? | 位宽  | 功能                                  |
| --------------- | ------- | ----- | ------------------------------------- |
| instr           | in      |       |                                       |
| MEM_WE          | out     |       | 选择是否写入Memory                    |
| MEM_Sel         | out     |       | 选择是否将Memory读出值向后传递(1:yes) |
| MEM_A2_NEW      | out     |       | MEM区$T_{NEW}$                        |
| MEM_PART        | out     | [1:0] | 选择存入/读取Word,Half或者Byte        |
| MEM_EXT_Control | out     | [2:0] | MEM_EXT部件控制信号                   |

#### MEM信号及$T_{NEW}$表

| 指令/信号 | MEM_WE | MEM_Sel | MEM_A2_NEW | MEM_PART | MEM_EXT_Control |
| --------- | ------ | ------- | ---------- | -------- | --------------- |
| sw        | 1      | 0       | 0          | `memWord | 3'bz            |
| sh        | 1      | 0       | 0          | `memHalf | 3'bz            |
| sb        | 1      | 0       | 0          | `memByte | 3'bz            |
| lw        | 0      | 1       | 1          | `memWord | `nonExt         |
| lh        | 0      | 1       | 1          | `memHalf | `signedHalfExt  |
| lb        | 0      | 1       | 1          | `memByte | `signedByteExt  |
| else      | 0      | 0       | 0          | 2'bz     | 3'bz            |

### MEM_WB

| 端口      | In/Out? | 位宽   | 功能 |
| --------- | ------- | ------ | ---- |
| clk       | in      |        |      |
| reset     | in      |        |      |
| MEM_PC    | in      | [31;0] |      |
| MEM_instr | in      | [31:0] |      |
| MEM_A3    | in      | [4:0]  |      |
| MEM_WD    | in      | [31:0] |      |
| WB_PC     | out     | [31:0] |      |
| WB_instr  | out     | [31:0] |      |
| WB_A3     | out     | [4:0]  |      |
| WB_WD     | out     | [31:0] |      |

### HAZARD_CTRL

| 端口              | In/Out? | 位宽   | 功能                              |
| ----------------- | ------- | ------ | --------------------------------- |
| clk               | in      |        |                                   |
| reset             | in      |        |                                   |
| **ID阶段**        |         |        |                                   |
| ID_A1             | in      | [4:0]  | ID阶段正在使用的A1寄存器          |
| ID_A2             | in      | [4:0]  | ID阶段正在使用的A2寄存器          |
| ID_RD1            | in      | [31:0] | ID阶段寄存器堆读出的A1对应值      |
| ID_RD2            | in      | [31:0] | ID阶段寄存器堆读出的A2对应值      |
| ID_A1_USE         | in      | [1:0]  | $T_{USE}$                         |
| ID_A2_USE         | in      | [1:0]  | $T_{USE}$                         |
| ID_MD             | in      |        | ID区处理指令是否与乘除相关        |
| **EX阶段**        |         |        |                                   |
| EX_A1             | in      | [4:0]  |                                   |
| EX_A2             | in      | [4:0]  |                                   |
| EX_RD1            | in      | [31:0] | IE阶段A2对应值,由ID区的转发值得来 |
| EX_RD2            | in      | [31:0] | IE阶段A2对应值,由ID区的转发值得来 |
| EX_A1_USE         | in      | [1:0]  | $T_{USE}$                         |
| EX_A2_USE         | in      | [1:0]  | $T_{USE}$                         |
| EX_A3             | in      | [4:0]  | EX传递的A3寄存器(rd)              |
| EX_WD             | in      | [31:0] | EX传递的Write Data                |
| MULT_DIV_BUSY     | in      |        | 乘除模块忙碌信号                  |
| MULT_DIV_START    | in      |        | 乘除模块开始信号                  |
| **MEM阶段**       |         |        |                                   |
| MEM_A2            | in      | [4:0]  | MEM正在使用的A2                   |
| MEM_RD2           | in      | [31:0] | MEM的Read Data2,由EX传递而来      |
| MEM_A2_NEW        | in      | [1:0]  | MEM的$T_{NEW}$                    |
| MEM_A3            | in      | [4:0]  | MEM传递A3                         |
| MEM_WD            | in      | [31:0] | MEM传递的Write Data               |
| **WB**            |         |        |                                   |
| WB_A3             | in      | [4:0]  |                                   |
| WB_WD             | in      | [31:0] |                                   |
| **转发FORWARD**   |         |        |                                   |
| ID_RD1_forward    | out     | [31:0] |                                   |
| ID_RD2_forward    | out     | [31:0] |                                   |
| EX_RD1_forward    | out     | [31:0] |                                   |
| EX_RD2_forward    | out     | [31:0] |                                   |
| MEM_RD2_forward   | out     | [31:0] |                                   |
| **暂停信号STALL** |         |        |                                   |
| Enable_PC         | out     |        | PC使能信号                        |
| Enable_IF_ID      | out     |        | IF_ID流水寄存器使能信号           |
| Enable_ID_EX      | out     |        | ID_EX流水寄存器使能信号           |
| Flush_ID_EX       | out     |        | ID_EX流水寄存器刷新信号           |
| Flush_EX_MEM      | out     |        | EX_MEM流水寄存器刷新信号          |



## 阻塞矩阵

| IF/ID当前指令 |          |           | ID/EX                |                         |                        | EX/MEM            |                   |                  | MEM/WB            |                   |                  |
| ------------- | -------- | --------- | -------------------- | ----------------------- | ---------------------- | ----------------- | ----------------- | ---------------- | ----------------- | ----------------- | ---------------- |
| 指令类型      | 源寄存器 | $T_{use}$ | cal_r<br/>1/rd)</br> | cal_i<br />(1/rt)<br /> | load<br />(2/rt)<br /> | cal_r<br />(0/rd) | cal_i<br />(0/rt) | load<br />(1/rt) | cal_r<br />(0/rd) | cal_i<br />(0/rt) | load<br />(0/rt) |
| beq           | rs/rt    | 0         | X                    | X                       | X                      |                   |                   | X                |                   |                   |                  |
| cal_r         | rs_rt    | 1         |                      |                         | X                      |                   |                   |                  |                   |                   |                  |
| cal_i         | rs       | 1         |                      |                         | X                      |                   |                   |                  |                   |                   |                  |
| load          | rs(base) | 1         |                      |                         | X                      |                   |                   |                  |                   |                   |                  |
| store         | rs(base) | 1         |                      |                         | X                      |                   |                   |                  |                   |                   |                  |
| store         | rt       | 2         |                      |                         |                        |                   |                   |                  |                   |                   |                  |



## 暂停实现

> 使用课程讲解的AT法,在流水线运行期间,ID区提供$T_{USE}$,EX,MEM区提供$T_{NEW}$,在冒险控制模块中采用以下判断逻辑:
>
> ```verilog
> assign STALL =  (ID_A1 == EX_A3 && ID_A1_USE < EX_NEW && EX_A3 != 0)  
>               || (ID_A2 == EX_A3 && ID_A2_USE < EX_NEW && EX_A3 != 0)
>               || (ID_A1 == MEM_A3 && ID_A1_USE < MEM_A2_NEW && MEM_A3 != 0)
>               || (ID_A2 == MEM_A3 && ID_A2_USE < MEM_A2_NEW && MEM_A3 != 0);
> ```
>
> STALL信号会控制三个行为:
>
> 1. 暂停IF区的PC模块
> 2. 暂停IF_ID间流水寄存器
> 3. 刷新ID_EX间流水寄存器(等同于reset)
>
> ```verilog
> assign Enable_PC = !STALL;
> assign Enable_IF_ID = !STALL;
> assign Flush_ID_EX = STALL;
> ```



## 转发实现

> 转发有五条可能的数据通路:
>
> 1. $EX\_MEM\rightarrow ID$
> 2. $MEM\_WB\rightarrow ID$
> 3. $EX\_MEM\rightarrow EX$
> 4. $MEM\_WB\rightarrow EX$
> 5. $MEM\_WB\rightarrow MEM$
>
> 这里以ID区的RD1转发数据逻辑为例:
>
> ```verilog
> assign ID_RD1_forward = (ID_A1 == 5'b0) ? 0 :
>                         (ID_A1 == MEM_A3) ? MEM_WD :
>                         (ID_A1 == WB_A3) ? WB_WD :
>                         ID_RD1;
> ```



## 寄存器内部转发实现

```Verilog
// 考虑寄存器内部转发
assign RD1 = (A1 == A3 && A1 != 0 && !reset) ? WD : grf[A1]; 
assign RD2 = (A2 == A3 && A2 != 0 && !reset) ? WD : grf[A2];
```



## 测试方案

1. `Python`自动生成测试mips文件
2. `Mars`运行mips文件,生成正确结果和机器码
3. `iverilog`运行CPU文件,生成测试结果
4. `Python`比较两份答案



## 思考题

1、为什么需要有单独的乘除法部件而不是整合进 ALU？为何需要有独立的 HI、LO 寄存器？

> 乘除法的运算速率明显低于其他运算,需要多个时钟周期,将乘除法分离出ALU可以避免乘除指令干扰其他运算指令的进行.
>
> 独立的HI,LO寄存器可以保存乘除法运算的值,若不实现该独立寄存器,要等待运算完成后再将值送回寄存器堆中,严重降低流水线CPU的性能.

2、真实的流水线 CPU 是如何使用实现乘除法的？请查阅相关资料进行简单说明。

> 1. 乘法
>
> CPU会初始化三个通用寄存器,分别存放被乘数,乘数,部分积.部分积寄存器初始化为0.
>
> 判断乘数寄存器的低位是低电平(0)还是高电平(1),如果是0则将乘数寄存器右移一位,同时将部分积寄存器也右移一位
>
> 如果为1,则将部分积寄存器加上被乘数寄存器的值,再进行移位操作
>
> 乘数寄存器低位溢出的一位丢弃,部分寄存器低位溢出的一位填充到乘数寄存器的高位
>
> 处理完毕后,乘数寄存器即`$lo`,部分积寄存器即`$hi`
>
> 2. 除法
>
> 首先CPU会初始化三个寄存器,分别用来存放被除数,除数,部分商.
>
> 余数(被除数与除数比较的结果)放到被除数的有效高位上.
>
> 首先CPU会把被除数bit位与除数bit位对齐,然后在让对齐的被除数与除数比较(双符号位判断).
>
> 双符号位判断： 比如01-10=11(前面的1是符号位) 1-2=-1 计算机通过符号位和后一位的bit位来判断大于和小于，那么01-10=11 就说明01小于10，如果得数为01就代表大于，如果得数为00代表等于。 
>
> 如果得数大于或等于则将比较的结果放到被除数的有效高位上然后在商寄存器上商：1 并向后多看一位 (上商就是将商的最低位左移1位腾出商寄存器最低位上新的商) 
>
> 如果得数小于则上商：0 并向后多看一位 
>
> 循环做以上操作当所有的被除数都处理完后，商做结果被除数里面的值就是余数.

3、请结合自己的实现分析，你是如何处理 Busy 信号带来的周期阻塞的？

> ```verilog
> assign STALL =  (ID_A1 == EX_A3 && ID_A1_USE < EX_NEW && EX_A3 != 0)  
>                  || (ID_A2 == EX_A3 && ID_A2_USE < EX_NEW && EX_A3 != 0)
>                  || (ID_A1 == MEM_A3 && ID_A1_USE < MEM_A2_NEW && MEM_A3 != 0)
>                  || (ID_A2 == MEM_A3 && ID_A2_USE < MEM_A2_NEW && MEM_A3 != 0)
>                  || (ID_MD && (MULT_DIV_BUSY || MULT_DIV_START));
> ```
>
> 当`EX`区的乘除部件在计算乘除结果时,`MULT_DIV_BUSY`置1;当ID区遇到乘除相关指令(`ID_MD`=1)时,若`MULT_DIV_BUSY`或`MULT_DIV_START`为1,则周期阻塞.

4、请问采用字节使能信号的方式处理写指令有什么好处？（提示：从清晰性、统一性等角度考虑）

> ```verilog
> assign MEM_BYTE_EN =  (WE == 0) ? 4'b0000 :
>                     (MEM_PART == `memWord) ? 4'b1111 :
>                     (MEM_PART == `memHalf && half == 0) ? 4'b0011 :
>                     (MEM_PART == `memHalf && half == 1) ? 4'b1100 :
>                     (MEM_PART == `memByte && byte == 2'b00) ? 4'b0001 : 
>                     (MEM_PART == `memByte && byte == 2'b01) ? 4'b0010 : 
>                     (MEM_PART == `memByte && byte == 2'b10) ? 4'b0100 : 
>                     (MEM_PART == `memByte && byte == 2'b11) ? 4'b1000 :
>                     4'b0000;
> ```
>
> 使得代码清晰易读,避免了大量的位拼接的情况,可以处理按字,半字,字节读入/写入的操作,统一性好.

5、请思考，我们在按字节读和按字节写时，实际从 DM 获得的数据和向 DM 写入的数据是否是一字节？在什么情况下我们按字节读和按字节写的效率会高于按字读和按字写呢？

> 不是,我们从DM获得的数据和向DM写入的数据都是一字,通过处理后选择其中一个字节执行操作.
>
> 当指令序列有大量涉及`lh,sh,lb,sb`的指令时.

6、为了对抗复杂性你采取了哪些抽象和规范手段？这些手段在译码和处理数据冲突的时候有什么样的特点与帮助？

> 译码:将指令进行分类,降低译码代码复杂度和书写难度
>
> 处理数据冲突:将数据通路的阻塞操作和转发操作分离,各部件的选择信号均由Control部件产生,减少各部件的耦合度

7、在本实验中你遇到了哪些不同指令类型组合产生的冲突？你又是如何解决的？相应的测试样例是什么样的？

> ID区和EX区均在执行乘除类指令:STALL
>
> ```assembly
> ori $1, $0, 0x3456
> ori $2, $0, 0x4675
> ori $3, $0, 0x786922
> multu $1, $2
> mult $2, $3
> mflo $3
> mfhi $4
> ```

8、如果你是手动构造的样例，请说明构造策略，说明你的测试程序如何保证**覆盖**了所有需要测试的情况；如果你是**完全随机**生成的测试样例，请思考完全随机的测试程序有何不足之处；如果你在生成测试样例时采用了**特殊的策略**，比如构造连续数据冒险序列，请你描述一下你使用的策略如何**结合了随机性**达到强测的效果。

> 不足之处:可能会遗漏特殊的阻塞和转发情况
>
> 策略:
>
> 1. 限制使用的寄存器个数,提高数据冲突的可能性
>
> 2. 生成beq,jal等跳转类指令时打印一组语句,指定跳转的寄存器值或`PC+OFFSET`,避免跳转地址不合理

