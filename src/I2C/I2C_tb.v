module tb_i2c;

    reg clk = 0;
    reg rst;
    reg start;
    reg [6:0] slave_addr = 7'b1010000;    
    reg [7:0] data = 8'b10101100;        
    wire scl;
    wire sda;
    wire busy;
    wire done;

    always #5 clk = ~clk;

    i2c_master uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .slave_addr(slave_addr),
        .data(data),
        .scl(scl),
        .sda(sda),
        .busy(busy),
        .done(done)
    );

    initial begin
        $dumpfile("i2c_send_10101100.vcd");
        $dumpvars(0, tb_i2c);

        rst = 1;
        //sda=1;
        start = 0;
        #20;

        rst = 0;
        #20;

        // Begin I2C 
        start = 1;
        #10;
        start = 0;

        // Wait for I2C transaction to complete
        wait (done);
        #50;
        $finish;
    end

endmodule
