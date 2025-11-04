
module game_of_life #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic [10:0] read_address,
    input  logic [99:0] current_state,
    input logic [99:0] intermediate_state,
    input  logic [5:0] pixel,
    output logic [7:0] read_data,
    output logic [99:0] next_state,
    output logic [4:0] column_out
);

    logic [7:0] mem [0:63];
    logic [1:0] calculate_state = 1'b1;
    logic [6:0] pixel1;
    logic [7:0] pixel_val = 8'h00;
    logic init_state_1;
    logic [99:0] init_mat;
    
    logic n0, n1, n2, n3, n4, n5, n6, n7;
    logic [1:0] s01, s23, s45, s67;     
    logic [2:0] s0123, s4567;      
    logic [3:0] neighbors;           
    logic [1:0] initialized;

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
            init_state_1 = 1'b1;
            next_state = 100'b0;
            initialized = 1'b1;
        end
    end
    
    // row/column indices for 8x8 image traversal (0..7)
    logic [4:0] row = 5'd0;
    logic [4:0] column = 5'd0;

    always_ff @(posedge clk) begin
        // compute pixel1 from row/column
        column_out <= column;
        pixel1 = 10 * row + 11 + column;
        if (init_state_1 == 1'b1) begin
            if (mem[pixel] == 8'hFF) begin
                read_data = 8'hFF;
                next_state[pixel1] = 1'b1;
            end
            else begin
                read_data = 8'h00;
                next_state[pixel1] = 1'b0;
            end
        end
        // start iterations
        else begin
            n0 = current_state[pixel1 - 10];
            n1 = current_state[pixel1 + 10];
            n2 = current_state[pixel1 - 11];
            n3 = current_state[pixel1 + 11];
            n4 = current_state[pixel1 - 1];
            n5 = current_state[pixel1 + 1];
            n6 = current_state[pixel1 - 9];
            n7 = current_state[pixel1 + 9];

            s01 = n0 + n1;
            s23 = n2 + n3;
            s45 = n4 + n5;
            s67 = n6 + n7;

            s0123 = s01 + s23;
            s4567 = s45 + s67;

            neighbors = s0123 + s4567;

            if (current_state[pixel1]) begin
                if (neighbors < 2 || neighbors > 3) begin
                    next_state[pixel1] = 1'b0;
                    read_data = 8'h00;
                end else begin
                    next_state[pixel1] = 1'b1;
                    read_data = 8'h4F;
                end
            end else begin
                if (neighbors == 3) begin
                    next_state[pixel1] = 1'b1;
                    read_data = 8'h4F;
                end else begin
                    next_state[pixel1] = 1'b0;
                    read_data = 8'h00;
                end
            end
        end
        if (pixel == 6'd63) begin
            init_state_1 = 1'b0;
        end        
    end

    logic pixel_d1, pixel_d2;
    wire pixel_posedge =  pixel_d1 & ~pixel_d2;
    wire pixel_negedge = ~pixel_d1 &  pixel_d2;
    wire pixel_edge    = pixel_d1 ^ pixel_d2; 

    always_ff @(posedge clk) begin
        pixel_d1 <= pixel[0];
        pixel_d2 <= pixel_d1;
    end

    always_ff @(posedge clk) begin
        if (pixel_edge) begin
            if (initialized)
                initialized <= 1'b0;
            else begin
                if (column == 5'd7) begin
                    column <= 5'd0;
                    if (row == 5'd7)
                        row <= 5'd0;
                    else
                        row <= row + 1;
                end else begin
                    column <= column + 1;
                end
            end
        end
    end
    
endmodule
