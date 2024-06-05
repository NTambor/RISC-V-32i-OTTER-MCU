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
    input logic reset,
    input logic [31:0] address,
    input logic [31:0] write_data,
    input logic read,
    input logic write,
    input logic [255:0] cache_line_in, // 256-bit input cache line
    output logic [255:0] cache_line_out, // 256-bit output cache line
    output logic [31:0] WBack_data,
    output logic [31:0] Valid,
    output logic [7:0] word_enable // Byte-enable signals for write operation
    );


    // Parameters
    parameter WORDS_PER_LINE = 8;
    parameter WORD_SIZE = 32;

    // Address decoding
    logic [2:0] word_index;
    assign word_index = address[4:2];

    // 256-bit cache line split into 8 32-bit words
    logic [31:0] words [WORDS_PER_LINE-1:0];

    // Split input cache line into words
    always_comb begin
        for (int i = 0; i < WORDS_PER_LINE; i++) begin
            words[i] = cache_line_in[(i*WORD_SIZE) +: WORD_SIZE];
        end
    end

    // Read operation
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            WBack_data <= 32'b0;
        end else if (read) begin
            WBack_data <= words[word_index];
        end
    end

    // Write operation
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < WORDS_PER_LINE; i++) begin
                words[i] <= 32'b0;
            end
        end else if (write) begin
            words[word_index] <= write_data;
        end
    end

    // Combine words into output cache line
    always_comb begin
        cache_line_out = 256'b0;
        for (int i = 0; i < WORDS_PER_LINE; i++) begin
            cache_line_out[(i*WORD_SIZE) +: WORD_SIZE] = words[i];
        end
    
endmodule
