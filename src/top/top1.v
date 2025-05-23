module i2c_master (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [6:0] slave_addr,
    input wire [7:0] data,
    inout wire sda,  
    output reg [7:0] filtered_out,
    output reg done
);
     //reg busy;
    reg [7:0]data_out;
    reg [7:0] iteration;
    reg [3:0] bit_cnt;
    reg [7:0] tx_byte;
    reg sda_out;
    reg sda_oe;  // output enable

    assign sda = sda_oe ? sda_out : 1'bz;

    reg [3:0] state;
   reg [7:0] demo_data;

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
            sda_out <= 1;
            sda_oe <= 1;
            bit_cnt <= 0;
           // busy <= 0;
            done <= 0;
            state <= IDLE;
            data_out<=0;
            iteration<=50;
            demo_data<=0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        tx_byte <= {slave_addr, 1'b0}; 
                       // busy <= 1;
                        state <= START;
                    end
                end
                START: begin
                    sda_out <= 0;
                    sda_oe <= 1;
                    state <= ADDR;
                    bit_cnt <= 7;
                end
                ADDR: begin
                    sda_out <= tx_byte[bit_cnt];
                    if (bit_cnt == 0) begin
                        done<=1;
                        state <= ACK1;
                        end
                    else
                        bit_cnt <= bit_cnt - 1;
                end
                ACK1: begin
                    sda_oe <= 0; 
                    state <= DATA;
                    tx_byte <= data;
                    bit_cnt <= 7;
                    sda_oe <= 1;
                    demo_data<=0;
                    done<=0;
                end
                DATA: begin
                    done<=0;
                    sda_out <= tx_byte[bit_cnt];
                   // if(bit_cnt !=7) begin
                    demo_data<={demo_data[6:0],tx_byte[bit_cnt]};// end
                    
                    if (bit_cnt == 0) begin
                    
                        state <= ACK2; end
                        
                    else //begin
                        bit_cnt <= bit_cnt - 1;
                        //data_out<={data_out[6:0],sda_out}; end
                end
                ACK2: begin
                    data_out<=demo_data;
                    sda_oe <= 1;
                    if(iteration==0)
                    state <= STOP;
                    else begin
                    state<=ACK1; 
                    done<=1;
                   // bit_cnt<=7;
                    iteration<=iteration-1;
                    demo_data<=0;
                    end
                end
                STOP: begin
                    sda_oe <= 1;
                    sda_out <= 0;
                    sda_out <= 1;
                    state <= DONE;
                end
                DONE: begin
                   // busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
          
    end
    
     reg[15:0] R = 16'd10240;
    reg[15:0] H = 16'd256;  
    reg[15:0] Q = 16'd2560; 
    reg[15:0] uh = 0;       // estimated value
    reg[15:0] a_q8_8;       

reg[15:0] p,k;
reg ready;
reg[31:0] temp1,temp2,temp3;
    reg[15:0] i;
    always @(posedge done or posedge rst) begin
        if (rst) begin
            p <= 0;
            uh <= 0;
            k <= 0;
            ready <= 0;
            filtered_out <= 0;
        end else  begin
            a_q8_8 = data_out; 
            temp1 = (p*H)>>8;                            // p * H
            temp2 = ((H) * (temp1))>>8 ;                // H*p*H in Q8.8
            temp3 = (temp2 + R);                       // H*p*H + R
            k=(temp1)/(temp3>>8);
            //k = (p * H / ((H * p * H) + R))<<8 ;                // Q8.8 result

            temp1 = (H * (uh))>>8;                          // H*uh
            temp2 = (a_q8_8<<8) - (temp1);                  // a - H*uh
            temp3 = ((k) * temp2)>>8;                // k*(a - H*uh)
            //uh = (uh + (k * (a_q8_8 - (H * uh))))<<8;
            uh=uh+temp3;
            // p = (1 - k*H)*p + q
            temp1 = ((k<<8) * H)>>8 ;                    // k*H
            temp2 = (16'd255 - (temp1))<<8;                   // 1 - k*H in Q8.8
            temp3 = (temp2 * (p>>8))>>8 ;                // (1 - k*H)*p
            p=temp3+Q;
            filtered_out = uh[15:8];
            ready = 1;
        end 
    end
    
endmodule
