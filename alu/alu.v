// ============================================================
// alu.v  –  8-Bit ALU mit 9 Operationen
// Eingang:  A, B je 4 Bit  (0–15)
// Ausgang:  result 8 Bit   (max. 15*15 = 225 = 0xE1)
//
// op  | Operation
// ----+-----------
// 0000 | A + B
// 0001 | A - B  (Zweierkomplement; Underflow → 0x00)
// 0010 | A * B
// 0011 | A / B  (Division durch 0 → 0xFF als Fehlercode)
// 0100 | A AND B
// 0101 | A OR  B
// 0110 | A XOR B
// 0111 | A NAND B
// 1000 | A NOR  B
// sonst| 0x00
// ============================================================

module alu (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [3:0] op,
    output reg  [7:0] result
);

    wire [7:0] sum   = {4'b0000, A} + {4'b0000, B};
    wire [7:0] diff  = ({4'b0000, A} >= {4'b0000, B}) ?
                           ({4'b0000, A} - {4'b0000, B}) : 8'h00;
    wire [7:0] prod  = A * B;                       // 4×4 → 8 Bit
    wire [7:0] quot  = (B != 4'b0000) ? (A / B) : 8'hFF;
    wire [7:0] band  = {4'b0000, A & B};
    wire [7:0] bor   = {4'b0000, A | B};
    wire [7:0] bxor  = {4'b0000, A ^ B};
    wire [7:0] bnand = {4'b0000, ~(A & B)};
    wire [7:0] bnor  = {4'b0000, ~(A | B)};

    always @(*) begin
        case (op)
            4'b0000: result = sum;
            4'b0001: result = diff;
            4'b0010: result = prod;
            4'b0011: result = quot;
            4'b0100: result = band;
            4'b0101: result = bor;
            4'b0110: result = bxor;
            4'b0111: result = bnand;
            4'b1000: result = bnor;
            default:  result = 8'h00;
        endcase
    end

endmodule
