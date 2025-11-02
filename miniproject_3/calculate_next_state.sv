module calculate_next_state (
    input  logic        clk,
    input  logic [99:0] current_state,
    input  logic [5:0] pixel,
    input  logic load_sreg,
    output logic [99:0] next_state,
    output logic [7:0]  pixel_val
);

    // Registered inputs (timing-friendly)
    logic [99:0] current_state_r;
    logic [5:0] pixel_r;

    // Intermediates declared at module scope
    integer pixel1;
    logic n0, n1, n2, n3, n4, n5, n6, n7;
    logic [2:0] s01, s23, s45, s67;
    logic [3:0] s0123, s4567;
    logic [4:0] neighbors;  // 0..8

    always_ff @(posedge clk) begin
        pixel_r <= pixel;  // Register pixel for timing
    end

    always_comb begin
        if (load_sreg) begin
            next_state = current_state;
            pixel_val = 8'h00;
            pixel1 = 0;
        end else begin
            // Use current_state directly (not registered) so all pixels see same frame state
            pixel1 = (10*pixel_r)/8 + 11 + (pixel_r % 8);

            // Default passthrough - use current_state directly
            next_state = current_state;
            pixel_val = 8'h00;

            // Neighbor bits (add your edge/bounds guards if needed)
            n0 = current_state[pixel1 - 10];
            n1 = current_state[pixel1 + 10];
            n2 = current_state[pixel1 - 11];
            n3 = current_state[pixel1 + 11];
            n4 = current_state[pixel1 - 1];
            n5 = current_state[pixel1 + 1];
            n6 = current_state[pixel1 - 9];
            n7 = current_state[pixel1 + 9];

            // Pairwise adder tree
            s01 = n0 + n1;
            s23 = n2 + n3;
            s45 = n4 + n5;
            s67 = n6 + n7;

            s0123 = s01 + s23;
            s4567 = s45 + s67;

            neighbors = s0123 + s4567;

            // Use pixel1 (10x10 grid index) for state array indexing - must match neighbor calculations
            if (current_state[pixel1]) begin
                if (neighbors < 2 || neighbors > 3) begin
                    next_state[pixel1] = 1'b0;
                    pixel_val = 8'h11;
                end else begin
                    next_state[pixel1] = 1'b1;
                    pixel_val = 8'h4F;
                end
            end else begin
                if (neighbors == 3) begin
                    next_state[pixel1] = 1'b1;
                    pixel_val = 8'h4F;
                end else begin
                    next_state[pixel1] = 1'b0;
                    pixel_val = 8'h11;
                end
            end
        end
    end
endmodule