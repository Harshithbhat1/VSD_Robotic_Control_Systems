module i2c_master (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [6:0] slave_addr,
    input wire [7:0] data,
    output reg scl,
    inout wire sda,
    output reg busy,
    output reg done
);

    reg [3:0] bit_cnt;
    reg [7:0] tx_byte;
    reg sda_out;
    reg sda_oe;  // output enable

    assign sda = sda_oe ? sda_out : 1'bz;

    reg [3:0] state;

    localparam IDLE = 0,
               START = 1,
               ADDR = 2,
               ACK1 = 3,
               DATA = 4,
               ACK2 = 5,
               STOP = 6,
               DONE = 7;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scl <= 1;
            sda_out <= 1;
            sda_oe <= 1;
            bit_cnt <= 0;
            busy <= 0;
            done <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        tx_byte <= {slave_addr, 1'b0}; 
                        busy <= 1;
                        state <= START;
                    end
                end
                START: begin
                    sda_out <= 0;
                    sda_oe <= 1;
                    scl <= 1;
                    state <= ADDR;
                    bit_cnt <= 7;
                end
                ADDR: begin
                    scl <= 0;
                    sda_out <= tx_byte[bit_cnt];
                    scl <= 1;
                    if (bit_cnt == 0)
                        state <= ACK1;
                    else
                        bit_cnt <= bit_cnt - 1;
                end
                ACK1: begin
                    scl <= 0;
                    sda_oe <= 0; 
                    scl <= 1;
                    state <= DATA;
                    tx_byte <= data;
                    bit_cnt <= 7;
                    sda_oe <= 1;
                end
                DATA: begin
                    scl <= 0;
                    sda_out <= tx_byte[bit_cnt];
                    scl <= 1;
                    if (bit_cnt == 0)
                        state <= ACK2;
                    else
                        bit_cnt <= bit_cnt - 1;
                end
                ACK2: begin
                    scl <= 0;
                    sda_oe <= 1;
                    scl <= 1;
                    state <= STOP;
                end
                STOP: begin
                    scl <= 0;
                    sda_oe <= 1;
                    sda_out <= 0;
                    scl <= 1;
                    sda_out <= 1;
                    state <= DONE;
                end
                DONE: begin
                    busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
