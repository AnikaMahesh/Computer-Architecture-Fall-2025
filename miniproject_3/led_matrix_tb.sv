`timescale 10ns/10ns
`include "top.sv"

module led_matrix_tb;

    logic clk = 0;
    logic SW = 1'b1;
    logic BOOT = 1'b1;
    logic _48b, _45a;
    logic [7:0] red_data_out;
    logic [7:0] green_data_out;
    logic [7:0] blue_data_out;
    logic [5:0] pixel_out;
    logic [10:0] address_out;
    logic [23:0] shift_reg_out;

    top u0 (
        .clk            (clk), 
        .SW             (SW), 
        .BOOT           (BOOT), 
        ._48b           (_48b), 
        ._45a           (_45a),
        .red_data_out   (red_data_out),
        .blue_data_out   (blue_data_out),
        .green_data_out   (green_data_out),
        .address_out        (address_out),
        .pixel_out          (pixel_out),
        .shift_reg_out      (shift_reg_out)
    );

    initial begin
        $dumpfile("led_matrix.vcd");
        $dumpvars(0, led_matrix_tb);
        #500000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

