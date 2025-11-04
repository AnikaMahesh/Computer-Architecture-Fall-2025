`timescale 10ns/10ns
`include "top.sv"

module led_matrix_tb;

    logic clk = 0;
    logic SW = 1'b1;
    logic BOOT = 1'b1;
    logic _48b, _45a;
    logic [99:0] current_state_r_out;
    logic [99:0] current_state_b_out;
    logic [99:0] current_state_g_out;
    logic [4:0] column_out_r;
    logic [4:0] column_out_b;
    logic [4:0] column_out_g;
    logic [5:0] pixel_out;

    top u0 (
        .clk            (clk), 
        .SW             (SW), 
        .BOOT           (BOOT), 
        ._48b           (_48b), 
        ._45a           (_45a),
        .current_state_r_out      (current_state_r_out),
        .current_state_b_out      (current_state_b_out),
        .current_state_g_out      (current_state_g_out),
        .column_out_r  (column_out_r),
        .column_out_b  (column_out_b),  
        .column_out_g  (column_out_g),
        .pixel_out     (pixel_out)
    );

    initial begin
        $dumpfile("game_of_life.vcd");
        $dumpvars(0, led_matrix_tb);
        #500000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

