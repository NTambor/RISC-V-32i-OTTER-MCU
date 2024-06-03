`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cow Poly
// Engineer: Danny Gutierrez
// 
// Create Date: 04/07/2024 12:16:02 AM
// Design Name: 
// Module Name: CacheLineAdapter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//         This module is responsible for interfacing between the cache and the memory. The middle man if you will.
//         It will be responsible for reading and writing to the memory
//         It will also be responsible for reading and writing to the cache
//         It will be responsible for the cache line size
// 
// Instantiated by:
//      CacheLineAdapter myCacheLineAdapter (
//          .CLK        ()
//      );
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CacheLineAdapter (
    input CLK,
    input reset,
    input [31:0] address,
    input [31:0] write_data,
    input read,
    input write,
    output reg [31:0] read_data,
    output reg hit
    );


    // Define cache parameters
    parameter NUM_SETS = 8;
    parameter WAYS = 2;
    parameter WORDS_PER_LINE = 8;

    // Cache line structure
    typedef struct {
        reg valid;
        reg [31:0] tag;
        reg [31:0] data[WORDS_PER_LINE-1:0];
    } cache_line_t;

    // Cache array
    cache_line_t cache[NUM_SETS-1:0][WAYS-1:0];

    // Index and tag extraction
    wire [2:0] index;
    wire [31:0] tag;
    assign index = address[4:2];
    assign tag = address[31:5];

    // Write data to cache
    integer i, j;
    always @(posedge CLK or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NUM_SETS; i = i + 1) begin
                for (j = 0; j < WAYS; j = j + 1) begin
                    cache[i][j].valid <= 0;
                    cache[i][j].tag <= 0;
                end
            end
            hit <= 0;
            read_data <= 32'b0;
        end else begin
            hit <= 0;
            if (read || write) begin
                for (j = 0; j < WAYS; j = j + 1) begin
                    if (cache[index][j].valid && (cache[index][j].tag == tag)) begin
                        hit <= 1;
                        if (read) begin
                            read_data <= cache[index][j].data[address[4:2]];
                        end
                        if (write) begin
                            cache[index][j].data[address[4:2]] <= write_data;
                        end
                    end
                end
                // Handle cache miss logic here (e.g., replace a cache line)
            end
        end
    end
endmodule
