module rv32i_single_cycle_mm(
    input clk,
    input reset,

    input [31:0] mem_read_data,

    output mem_read,
    output mem_write,
    output [31:0] mem_addr,
    output [31:0] mem_write_data,

    output [31:0] debug_pc,
    output [31:0] debug_instruction,
    output [31:0] debug_alu_result,
    output [31:0] debug_x5,
    output [31:0] debug_x6
);

wire [31:0] pc;
wire [31:0] next_pc;
wire [31:0] instruction;

wire [31:0] rd1;
wire [31:0] rd2;
wire [31:0] imm;

wire [31:0] alu_b;
wire [31:0] alu_result;
wire zero;

wire reg_write;
wire alu_src;
wire mem_to_reg;
wire branch;
wire lui;

wire [31:0] writeback_data;

assign next_pc = pc + 4;

pc PC(
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .pc(pc)
);

instruction_memory IMEM(
    .addr(pc),
    .instruction(instruction)
);

control_unit CTRL(
    .opcode(instruction[6:0]),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .lui(lui)
);

immediate_generator IMM(
    .instruction(instruction),
    .imm(imm)
);

assign alu_b = (alu_src) ? imm : rd2;

alu ALU(
    .a(rd1),
    .b(alu_b),
    .alu_ctrl(4'b0000),
    .result(alu_result),
    .zero(zero)
);

assign writeback_data = (mem_to_reg) ? mem_read_data :
                        (lui)        ? imm :
                                       alu_result;

register_file RF(
    .clk(clk),
    .we(reg_write),
    .rs1(instruction[19:15]),
    .rs2(instruction[24:20]),
    .rd(instruction[11:7]),
    .wd(writeback_data),
    .rd1(rd1),
    .rd2(rd2),
    .debug_x5(debug_x5),
    .debug_x6(debug_x6)
);

assign mem_addr = alu_result;
assign mem_write_data = rd2;

assign debug_pc = pc;
assign debug_instruction = instruction;
assign debug_alu_result = alu_result;

endmodule