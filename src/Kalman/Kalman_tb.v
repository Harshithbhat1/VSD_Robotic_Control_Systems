module tb_kalman_filter;

    reg clk = 0;
    reg rst;
    reg valid;
    reg [7:0] measurement;
    wire [15:0] filtered_out;
    wire ready;

    kalman_filter uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .measurement(measurement),
        .filtered_out(filtered_out),
        .ready(ready)
    );

    always #5 clk = ~clk;

    reg [7:0] data_series[0:9];
    integer i;

    initial begin
        $dumpfile("kalman_filter.vcd");
        $dumpvars(0, tb_kalman_filter);

        rst = 1;
        valid = 0;
        measurement = 0;
        #20 rst = 0;

        data_series[0] = 8'd50;
        data_series[1] = 8'd52;
        data_series[2] = 8'd49;
        data_series[3] = 8'd53;
        data_series[4] = 8'd55;
        data_series[5] = 8'd58;
        data_series[6] = 8'd56;
        data_series[7] = 8'd60;
        data_series[8] = 8'd59;
        data_series[9] = 8'd61;

        for (i = 0; i < 10; i = i + 1) begin
            measurement = data_series[i];
            valid = 1;
            #10;
            valid = 0;

            wait (ready);
            #10;
        end

        #100 $finish;
    end

endmodule

