module kalman_filter (
    input wire clk,
    input wire rst,
    input wire valid,
    input wire [7:0] measurement, 
    output reg [15:0] filtered_out, 
    output reg ready
);
    // Constants (Q8.8 fixed point)
    parameter R = 16'd10240;
    parameter H = 16'd256;  
    parameter Q = 16'd2560; 

    reg [15:0] p = 0;        // error covariance
    reg [15:0] uh = 0;       // estimated value
    reg [15:0] k;            // Kalman gain
    reg [15:0] a_q8_8;       

    reg [31:0] temp1, temp2, temp3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            p <= 0;
            uh <= 0;
            k <= 0;
            ready <= 0;
            filtered_out <= 0;
        end else if (valid) begin
            a_q8_8 = {measurement, 8'b0}; 
            temp1 = p * H;                            // p * H
            temp2 = (H * temp1) >> 8;                // H*p*H in Q8.8
            temp2 = temp2 + R;                       // H*p*H + R
            k = temp1 / (temp2 >> 8);                // Q8.8 result

            temp1 = H * uh;                          // H*uh
            temp2 = a_q8_8 - temp1;                  // a - H*uh
            temp3 = (k * temp2) >> 8;                // k*(a - H*uh)
            uh = uh + temp3;

            // p = (1 - k*H)*p + q
            temp1 = (k * H) >> 8;                    // k*H
            temp2 = (256 - temp1);                   // 1 - k*H in Q8.8
            temp3 = (temp2 * p) >> 8;                // (1 - k*H)*p
            p = temp3 + Q;

            filtered_out <= uh;
            ready <= 1;
        end else begin
            ready <= 0;
        end
    end

endmodule
