module rv32i_mm_ai_core(
    input clk,
    input reset,

    input [2:0] debug_select,

    output reg [31:0] debug_out,
    output ai_done
);

wire mem_read;
wire mem_write;

wire [31:0] mem_addr;
wire [31:0] mem_write_data;
wire [31:0] mem_read_data;

wire [31:0] debug_pc;
wire [31:0] debug_instruction;
wire [31:0] debug_alu_result;
wire [31:0] debug_x5;
wire [31:0] debug_x6;

wire [31:0] accel_result;
wire [31:0] accel_cycles;

reg [31:0] debug_mux;

rv32i_single_cycle_mm CPU(
    .clk(clk),
    .reset(reset),

    .mem_read_data(mem_read_data),

    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_addr(mem_addr),
    .mem_write_data(mem_write_data),

    .debug_pc(debug_pc),
    .debug_instruction(debug_instruction),
    .debug_alu_result(debug_alu_result),
    .debug_x5(debug_x5),
    .debug_x6(debug_x6)
);

data_memory_accel #(
    .VECTOR_LENGTH_MAX(16)
) DMEM_ACCEL(
    .clk(clk),
    .reset(reset),

    .mem_read(mem_read),
    .mem_write(mem_write),

    .addr(mem_addr),
    .write_data(mem_write_data),

    .read_data(mem_read_data),

    .accel_result(accel_result),
    .accel_cycles(accel_cycles),
    .accel_done(ai_done)
);

// Combinational debug selection
always @(*)
begin
    case(debug_select)
        3'b000: debug_mux = debug_pc;
        3'b001: debug_mux = debug_instruction;
        3'b010: debug_mux = debug_alu_result;
        3'b011: debug_mux = mem_read_data;
        3'b100: debug_mux = accel_result;
        3'b101: debug_mux = debug_x5;
        3'b110: debug_mux = debug_x6;
        3'b111: debug_mux = accel_cycles;
        default: debug_mux = 32'd0;
    endcase
end

// Registered debug output for timing closure
always @(posedge clk or posedge reset)
begin
    if(reset)
        debug_out <= 32'd0;
    else
        debug_out <= debug_mux;
end

endmodule