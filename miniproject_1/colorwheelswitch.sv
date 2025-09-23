// Color Wheel Switch

module top(
    input logic     clk, 
    output logic    RGB_G,
    output logic    RGB_B,
    output logic    RGB_R
);

    // CLK frequency is 12MHz, so 12,000,000 cycles is 1s
    parameter BLINK_INTERVAL = 12000000;
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;
    logic[4:0] iteration = 0;

    initial begin
        RGB_G = ~1'b0;
        RGB_B = 1'b0;
        RGB_R = 1'b0;
    end

    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;
            iteration <= iteration + 1;
        end else begin
            count <= count + 1;
        end
        if (iteration == 6) begin
            iteration <= 0;
        end
    end

    always_comb begin
        if (iteration % 6 == 0) begin            // red  RGB values are 1 0 0
            RGB_R = 1'b0;
            RGB_G = ~1'b0;
            RGB_B = ~1'b0;
        end else if (iteration % 6 == 1) begin   // yellow   RGB values are 1 1 0
            RGB_R = 1'b0;
            RGB_G = 1'b0;
            RGB_B = ~1'b0;
        end else if (iteration % 6 == 2) begin  // green   RGB values are 0 1 0
            RGB_R = ~1'b0;
            RGB_G = 1'b0;
            RGB_B = ~1'b0;
        end else if (iteration % 6 == 3) begin  // cyan    RGB values are 0 1 1
            RGB_R = ~1'b0;
            RGB_G = 1'b0;
            RGB_B = 1'b0;
        end else if (iteration % 6 == 4) begin  // blue   RGB values are 0 0 1 
            RGB_R = ~1'b0;
            RGB_G = ~1'b0;
            RGB_B = 1'b0;
        end else begin                          // magenta  RGB values are 1 0 1
            RGB_R = 1'b0;
            RGB_G = ~1'b0;
            RGB_B = 1'b0;
        end
    end

endmodule
