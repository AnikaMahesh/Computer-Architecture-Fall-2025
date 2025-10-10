`include "cycle.sv"
`include "pwm.sv"

module top #(
    parameter PWM_INTERVAL = 1200
)(
    input  logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    logic [2:0] RGB;
    assign {RGB_G, RGB_B, RGB_R} = RGB;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;
    logic pwm_out;
    logic [1:0] state;
    
    initial RGB = 3'b100;

    cycle #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) u1 (
        .clk       (clk),
        .pwm_value (pwm_value),
        .state     (state)
    );

    pwm #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) u2 (
        .clk       (clk),
        .pwm_value (pwm_value),
        .pwm_out   (pwm_out)
    );
    always_ff @(posedge clk) begin
        RGB <= RGB;
        case (state)
            0: RGB[0] <= ~pwm_out;
            1: RGB[1] <= ~pwm_out;
            2: RGB[2] <= ~pwm_out;
        endcase
    end
endmodule