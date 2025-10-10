// Fade

module fade #(
    parameter INC_DEC_INTERVAL = 12000,     // 12 MHz -> 1 ms
    parameter INC_DEC_MAX = 200,            // 0.2 s total per fade direction
    parameter PWM_INTERVAL = 1200,          // 100 µs period
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input  logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value,
    output logic [1:0] state
);

    // Define FSM states
    localparam PWM_INC = 1'b0;
    localparam PWM_DEC = 1'b1;

    // Internal variables
    logic current_state = PWM_INC;
    logic next_state;

    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = 0;
        state = 0;
    end

    // FSM state register (clocked by real clock)
    always_ff @(posedge clk) begin
        if (time_to_transition) begin
            current_state <= next_state;
            if (state == 2)
                state <= 0;
            else
                state <= state + 1;
        end
    end

    // FSM next-state logic
    always_comb begin
        case (current_state)
            PWM_INC: next_state = PWM_DEC;
            PWM_DEC: next_state = PWM_INC;
            default: next_state = PWM_INC;
        endcase
    end

    // Count for time_to_inc_dec pulses
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value
    always_ff @(posedge clk) begin
        if (time_to_inc_dec) begin
            case (current_state)
                PWM_INC: pwm_value <= pwm_value + INC_DEC_VAL;
                PWM_DEC: pwm_value <= pwm_value - INC_DEC_VAL;
            endcase
        end
    end

    // Timing for state transitions
    always_ff @(posedge clk) begin
        if (time_to_inc_dec) begin
            if (inc_dec_count == INC_DEC_MAX - 1) begin
                inc_dec_count <= 0;
                time_to_transition <= 1'b1;
            end else begin
                inc_dec_count <= inc_dec_count + 1;
                time_to_transition <= 1'b0;
            end
        end else begin
            time_to_transition <= 1'b0;
        end
    end

endmodule
