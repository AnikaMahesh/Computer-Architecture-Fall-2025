`timescale 10ns/10ns
`include "top.sv"

module cycle_tb;
    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_R, RGB_G, RGB_B;

    top #(.PWM_INTERVAL(PWM_INTERVAL)) u0 (
        .clk(clk),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );

    initial begin
        $dumpfile("cycle.vcd");
        $dumpvars(0, cycle_tb);
        #200000000;
        $finish;
    end

    always #4 clk = ~clk;
endmodule