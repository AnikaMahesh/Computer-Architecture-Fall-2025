`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "calculate_next_state.sv"

// led_matrix top level module

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, 
    output logic    _45a,
    output logic [23:0] shift_reg_out,
    output logic [7:0] red_data_out,
    output logic [7:0] green_data_out,
    output logic [7:0] blue_data_out,
    output logic [10:0] address_out,
    output logic [5:0] pixel_out
);

    logic [7:0] red_data;
    logic [7:0] green_data = 8'h00;
    logic [7:0] blue_data = 8'h00;

    logic [5:0] pixel;
    logic [4:0] frame;
    logic [10:0] address;

    logic [23:0] shift_reg = 24'd0;
    // Initialize with a simple stable pattern (block: 4 cells in a 2x2 square)
    // 8x8 grid centered in 10x10 starts at position 11 (row 1, col 1)
    // Center of 8x8 is at rows 4-5, cols 4-5 in 8x8 → rows 5-6, cols 5-6 in 10x10
    // Grid positions: 5*10+5=55, 5*10+6=56, 6*10+5=65, 6*10+6=66
    logic [99:0] current_state_r = (100'b1 << 55) | (100'b1 << 56) | (100'b1 << 65) | (100'b1 << 66);
    logic [99:0] next_state_r;
    logic [99:0] current_state_b = (100'b1 << 55) | (100'b1 << 56) | (100'b1 << 65) | (100'b1 << 66);
    logic [99:0] next_state_b;
    logic [99:0] current_state_g = (100'b1 << 55) | (100'b1 << 56) | (100'b1 << 65) | (100'b1 << 66);
    logic [99:0] next_state_g;
    logic [7:0] red_val;
    logic [7:0] green_val;
    logic [7:0] blue_val;

    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    assign address = { frame, pixel };


    // instance game of life
 //   calculate_next_state u1 (
 //       .clk            (clk),
 //       .current_state  (current_state_b),
 //       .pixel          (pixel),
 //       .load_sreg      (load_sreg),
 //       .next_state     (next_state_b),
 //       .pixel_val      (blue_val)
 //   );

    calculate_next_state u2 (
        .clk            (clk),
        .current_state  (current_state_r),
        .load_sreg      (load_sreg),
        .pixel          (pixel),
        .next_state     (next_state_r),
        .pixel_val      (red_val)
    );

//    calculate_next_state u3 (
//        .clk            (clk),
//        .current_state  (current_state_g),
//        .load_sreg      (load_sreg),
//        .pixel          (pixel),
//        .next_state     (next_state_g),
//        .pixel_val      (green_val)
//    );

    // Instance sample memory for red channel
    memory #(
        .INIT_FILE      ("initial_state/red.txt")
    ) u4 (
        .clk            (clk), 
        .read_address   (address), 
        .pixel_value    (red_val),
        .read_data      (red_data)
    );

    // Instance sample memory for green channel
    memory #(
        .INIT_FILE      ("initial_state/green.txt")
    ) u5 (
        .clk            (clk), 
        .read_address   (address), 
        .pixel_value    (green_val),
        .read_data      (green_data)
    );

    // Instance sample memory for blue channel
    memory #(
        .INIT_FILE      ("initial_state/blue.txt")
    ) u6 (
        .clk            (clk), 
        .read_address   (address), 
        .pixel_value    (blue_val),
        .read_data      (blue_data)
    );

    // Instance the WS2812B output driver
    ws2812b u7 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller u8 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          (frame)
    );

    always_ff @(posedge clk) begin
        // Update entire state from next_state when loading shift register
        // next_state contains full state with current pixel's bit updated
        if (load_sreg) begin
            if (pixel == 0) begin
                current_state_r <= next_state_r;
                current_state_g <= next_state_g;
                current_state_b <= next_state_b;
            end
        end

        if (load_sreg) begin
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
    assign shift_reg_out = shift_reg;
    assign red_data_out = red_data;
    assign green_data_out = green_data;
    assign blue_data_out = blue_data;
    assign address_out = address;
    assign pixel_out = pixel;

endmodule
