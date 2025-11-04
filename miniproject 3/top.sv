`include "game_of_life.sv"
`include "ws2812b.sv"
`include "controller.sv"

// led_matrix top level module

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT,
    output logic    _48b, 
    output logic    _45a,
    output logic [99:0] current_state_r_out, // debug signal for simulator(comment out if you need to run on FPGA)
    output logic [99:0] current_state_b_out, // debug signal for simulator(comment out if you need to run on FPGA)
    output logic [99:0] current_state_g_out, // debug signal for simulator(comment out if you need to run on FPGA)
    output logic [4:0] column_out_r, // debug signal for simulator(comment out if you need to run on FPGA)
    output logic [4:0] column_out_b, // debug signal for simulator(comment out if you need to run on FPGA)
    output logic [4:0] column_out_g, // debug signal for simulator(comment out if you need to run on FPGA)
    output logic [5:0] pixel_out  // debug signal for simulator(comment out if you need to run on FPGA)

);
    logic [4:0] column_r;
    logic [4:0] column_b;
    logic [4:0] column_g;

    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data; 

    logic [5:0] pixel;
    logic [4:0] frame;
    logic [10:0] address;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    logic [99:0] current_state_r = 100'd0;
    logic [99:0] intermediate_state_r = 100'd0;
    logic [99:0] next_state_r;
    logic init_copied_r = 1'b0;

    logic [99:0] current_state_b = 100'd0;
    logic [99:0] intermediate_state_b = 100'd0;
    logic [99:0] next_state_b;
    
    logic [99:0] current_state_g = 100'd0;
    logic [99:0] intermediate_state_g = 100'd0;
    logic [99:0] next_state_g;

    assign address = { frame, pixel };


    // Instance game_of_life for red channel
    game_of_life #(
        .INIT_FILE      ("red.txt")
    ) u1 (
        .clk            (clk), 
        .read_address   (address), 
        .read_data      (red_data),
        .current_state  (current_state_r),
        .intermediate_state (intermediate_state_r),
        .next_state     (next_state_r),
        .pixel          (pixel),
        .column_out     (column_r)
    );

    // Instance game_of_life for green channel
    game_of_life #(
        .INIT_FILE      ("green.txt")
    ) u2 (
        .clk            (clk), 
        .read_address   (address), 
        .read_data      (green_data),
        .current_state  (current_state_g),
        .intermediate_state (intermediate_state_g),
        .next_state     (next_state_g),
        .pixel          (pixel),
        .column_out     (column_g)
    );

    // Instance game_of_life for blue channel
    game_of_life #(
        .INIT_FILE      ("blue.txt")
    ) u3 (
        .clk            (clk), 
        .read_address   (address), 
        .read_data      (blue_data),
        .current_state  (current_state_b),
        .intermediate_state (intermediate_state_b),
        .next_state     (next_state_b),
        .pixel          (pixel),
        .column_out     (column_b)
    );

    // Instance the WS2812B output driver
    ws2812b u4 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller u5 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          (frame)
    );

    always_ff @(posedge clk) begin
        // On the first full pixel pass, copy next_state into current_state once
        if (!init_copied_r && (pixel == 6'd63)) begin
            current_state_r <= next_state_r;
            current_state_g <= next_state_g;
            current_state_b <= next_state_b;
            init_copied_r <= 1'b1;
        end

        if (load_sreg) begin
            if (pixel == 6'd63) begin            
                current_state_r = next_state_r;
                current_state_g = next_state_g;
                current_state_b = next_state_b;
            end

            unique case ({ SW, BOOT })
                2'b00:
                    shift_reg <= { green_data, 16'd0 };
                2'b01:
                    shift_reg <= { 8'd0, red_data, 8'd0 };
                2'b10:
                    shift_reg <= { 16'd0, blue_data };
                2'b11:
                    shift_reg <= { green_data, red_data, blue_data };
            endcase
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
   end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

    // debug signals for simulator comment out all of the lines below before endmodule if you need to run on FPGA)
    assign shift_reg_out = shift_reg;
    assign column_out_g = column_g;
    assign column_out_b = column_b;
    assign column_out_r = column_r;
    assign current_state_r_out = current_state_r;
    assign current_state_g_out = current_state_b;
    assign current_state_b_out = current_state_g;
    assign pixel_out = pixel;
endmodule
