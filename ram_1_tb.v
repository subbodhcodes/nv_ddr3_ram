//`timescale 1ns/1ps

module nv_ddre_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [17:0] user_data;
    reg enable;
    reg rd_en;
    reg wr_en;
    reg power_enable;

    // Outputs
    wire [7:0] user_out;

    // Instantiate the Unit Under Test (UUT)
    nv_ddre uut (
        .clk(clk),
        .rst(rst),
        .user_data(user_data),
        .enable(enable),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .power_enable(power_enable),
        .user_out(user_out)
    );

    // Clock generation
    always #5 clk = ~clk;  // Clock period is 10ns

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 0;
        user_data = 0;
        enable = 0;
        rd_en = 0;
        wr_en = 0;
        power_enable = 1;

        // Apply reset
        #10 rst = 1;  // Activate reset
        #20 rst = 0;  // Deactivate reset

        // Write values to memory
        enable = 1;
        wr_en = 1;
        //user_data = 18'b01_0001_0010_00010111;
        #5;  // Write value `23` at row 1, column 2
        user_data = 18'b01_0010_0011_00010111;  // Write value `23` at row 2, column 3
        #10;
        user_data = 18'b01_0011_0011_00110111;
        #10;
        user_data = 18'b01_0000_0011_11010111;
        #10;
        user_data = 18'b01_1001_0011_10010110;

        

        // Read values from memory
        #130
        wr_en = 0;
        rd_en = 1;
        #10
        //user_data = 18'b10_0001_0010_00000000;  // Read from row 1, column 2
        //#10;
        user_data = 18'b10_0010_0011_00000000; // Read from row 2, column 2
        #20;
        user_data = 18'b10_0011_0011_00000000;
        #10;
        user_data = 18'b10_0000_0011_00000000;
        #10;
        user_data = 18'b10_1001_0011_00000000;
        #60;
        rd_en = 0;
        // Trigger Refresh
        power_enable = 0; // Deactivate power
        #20;
        power_enable = 1; // Reactivate power

        // End test
        $stop;
    end
endmodule
