module data_memory_accel #(
    parameter VECTOR_LENGTH_MAX = 16
)(
    input clk,
    input reset,

    input mem_read,
    input mem_write,

    input [31:0] addr,
    input [31:0] write_data,

    output reg [31:0] read_data,

    output [31:0] accel_result,
    output [31:0] accel_cycles,
    output accel_done
);

localparam CTRL_ADDR   = 32'h00000040;
localparam STATUS_ADDR = 32'h00000044;
localparam RESULT_ADDR = 32'h00000048;
localparam CYCLES_ADDR = 32'h0000004C;
localparam VLEN_ADDR   = 32'h00000050;

localparam X_BASE_ADDR = 32'h00000080;
localparam W_BASE_ADDR = 32'h000000C0;

reg [31:0] ram [0:15];

reg [15:0] x_mem [0:VECTOR_LENGTH_MAX-1];
reg [15:0] w_mem [0:VECTOR_LENGTH_MAX-1];

reg [4:0] index;
reg [4:0] vector_length;

reg running;
reg done;

reg [31:0] result;
reg [31:0] cycle_count;

wire [31:0] product;

assign product = x_mem[index] * w_mem[index];

assign accel_result = result;
assign accel_cycles = cycle_count;
assign accel_done   = done;

integer i;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        for(i = 0; i < 16; i = i + 1)
        begin
            ram[i] <= 32'd0;
        end

        for(i = 0; i < VECTOR_LENGTH_MAX; i = i + 1)
        begin
            x_mem[i] <= 16'd0;
            w_mem[i] <= 16'd0;
        end

        index <= 0;
        vector_length <= 4;

        running <= 0;
        done <= 0;

        result <= 0;
        cycle_count <= 0;
    end
    else
    begin
        // Memory-mapped writes
        if(mem_write)
        begin
            if(addr == CTRL_ADDR)
            begin
                if(write_data[0] && !running)
                begin
                    running <= 1;
                    done <= 0;
                    index <= 0;
                    result <= 0;
                    cycle_count <= 0;
                end
            end
            else if(addr == VLEN_ADDR)
            begin
                if(write_data[4:0] == 0)
                    vector_length <= 1;
                else if(write_data[4:0] > VECTOR_LENGTH_MAX)
                    vector_length <= VECTOR_LENGTH_MAX;
                else
                    vector_length <= write_data[4:0];
            end
            else if((addr >= X_BASE_ADDR) && (addr < X_BASE_ADDR + (VECTOR_LENGTH_MAX * 4)))
            begin
                x_mem[(addr - X_BASE_ADDR) >> 2] <= write_data[15:0];
            end
            else if((addr >= W_BASE_ADDR) && (addr < W_BASE_ADDR + (VECTOR_LENGTH_MAX * 4)))
            begin
                w_mem[(addr - W_BASE_ADDR) >> 2] <= write_data[15:0];
            end
            else if(addr < 32'h00000040)
            begin
                ram[addr[5:2]] <= write_data;
            end
        end

        // Sequential dot-product operation
        if(running)
        begin
            result <= result + product;
            cycle_count <= cycle_count + 1;

            if(index == vector_length - 1)
            begin
                running <= 0;
                done <= 1;
            end
            else
            begin
                index <= index + 1;
            end
        end
    end
end

always @(*)
begin
    read_data = 32'd0;

    if(mem_read)
    begin
        if(addr == STATUS_ADDR)
            read_data = {31'd0, done};
        else if(addr == RESULT_ADDR)
            read_data = result;
        else if(addr == CYCLES_ADDR)
            read_data = cycle_count;
        else if(addr == VLEN_ADDR)
            read_data = {27'd0, vector_length};
        else if((addr >= X_BASE_ADDR) && (addr < X_BASE_ADDR + (VECTOR_LENGTH_MAX * 4)))
            read_data = {16'd0, x_mem[(addr - X_BASE_ADDR) >> 2]};
        else if((addr >= W_BASE_ADDR) && (addr < W_BASE_ADDR + (VECTOR_LENGTH_MAX * 4)))
            read_data = {16'd0, w_mem[(addr - W_BASE_ADDR) >> 2]};
        else if(addr < 32'h00000040)
            read_data = ram[addr[5:2]];
        else
            read_data = 32'd0;
    end
end

endmodule