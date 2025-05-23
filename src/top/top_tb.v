
module tb_i2c_master;

    reg clk = 0;
    reg rst;
    reg start;
    reg [6:0]slave_addr = 7'b1010000;  
    reg [7:0] data;        
    wire sda;
    always #5 clk = ~clk;
    wire[7:0] filtered_out;
    wire done;
    reg[7:0] d1[49:0];
    integer i;
    i2c_master uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .slave_addr(slave_addr),
        .data(data),
        .sda(sda),
        .filtered_out(filtered_out),
        .done(done)
    );
    
    initial begin
        $dumpfile("i2c_send_10101100.vcd");
        $dumpvars(0, tb_i2c_master);

        rst = 1;
        //sda=1;
        start = 0;
        #5;

        rst = 0;
        #20;

        // Begin I2C 
        start = 1;
        #10;
        start = 0;
        
        for (i = 0; i < 25; i = i + 1) begin
             d1[i] = 100+$random % 10;
        end
        for(i=25;i<50;i=i+1) begin
         d1[i] = 50+$random % 10;
        end

        for(i=0;i<50;i=i+1) begin
               data=d1[i];

     @(negedge done);

    @(posedge done);
        data=d1[i];
  
        end

        $finish;
    end

endmodule
