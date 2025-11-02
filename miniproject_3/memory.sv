module memory #(
    parameter INIT_FILE = ""
)(
    input  logic        clk,
    input  logic [10:0] read_address,
    input  logic [7:0]  pixel_value,
    output logic [7:0]  read_data
);

    logic [7:0] mem [0:63];

    // Initialize memory from file if provided
    initial if (INIT_FILE != "") begin
        $readmemh(INIT_FILE, mem);
    end 

    always_ff @(posedge clk) begin 
        if (read_address < 63) begin
            read_data <= mem[read_address[5:0]];  // Read initial state from file (frame 0)
        end 
        else begin
            read_data <= pixel_value;  // Use Game of Life output for frame > 0
        end
    end

endmodule