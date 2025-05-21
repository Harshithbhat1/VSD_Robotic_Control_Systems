module kalman_filter (
    input wire clk,
    input wire rst,
    input wire valid,
    input wire [7:0] measurement, 
    output reg [7:0] filtered_out, 
    output reg ready
);
    // Constants (Q8.8 fixed point)
    integer R = 40;
    integer H = 1;  
    integer Q = 10; 

    real p = 0;        // error covariance
    real uh = 0;       // estimated value
    real k=5;           // Kalman gain
    real a_q8_8;       

    real temp1, temp2, temp3;
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            p <= 0;
            uh <= 0;
            k <= 0;
            ready <= 0;
            filtered_out <= 0;
        end else if (valid) begin
            a_q8_8 = measurement; 
            temp1 = p * H;                            // p * H
            temp2 = (H * p*H) ;                // H*p*H in Q8.8
            temp2 = (H * p * H) + R;                       // H*p*H + R
           
           
            k = p * H / ((H * p * H) + R) ;                // Q8.8 result

            temp1 = H * uh;                          // H*uh
            temp2 = a_q8_8 - temp1;                  // a - H*uh
            temp3 = (k * temp2);                // k*(a - H*uh)
            uh = uh + (k * (a_q8_8 - (H * uh)));

            // p = (1 - k*H)*p + q
            temp1 = (k * H) ;                    // k*H
            temp2 = (1 - temp1);                   // 1 - k*H in Q8.8
            temp3 = (temp2 * p) ;                // (1 - k*H)*p
            p = (1-k*H)*p + Q;
            i=uh;
            filtered_out = i;
            ready = 1;
        end else begin
            ready = 0;
        end
    end

endmodule
