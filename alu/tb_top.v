// ============================================================
// tb_top.v  –  Testbench für top.v
// Vivado 2019.2 Behavioral Simulation
// ============================================================

`timescale 1ns / 1ps

module tb_top;

    reg         clk = 0;
    reg  [15:0] sw  = 16'b0;
    wire [6:0]  seg;
    wire        dp;
    wire [3:0]  an;

    // DUT
    top uut (
        .clk (clk),
        .sw  (sw),
        .seg (seg),
        .dp  (dp),
        .an  (an)
    );

    // 100 MHz Takt
    always #5 clk = ~clk;

    // Hilfsfunktion: Ergebnis ausgeben
    task show;
        input [3:0] A;
        input [3:0] B;
        input [3:0] op;
        input [7:0] expected;
        begin
            sw = {4'b0000, op, B, A};
            #100;
            $display("A=%0h  B=%0h  op=%0b  result=%0h  (expect %0h) %s",
                     A, B, op, uut.result,
                     expected,
                     (uut.result === expected) ? "OK" : "FAIL");
        end
    endtask

    initial begin
        $display("=== ALU Testbench ===");

        // Addition
        show(4'hA, 4'h5, 4'b0000, 8'h0F);  // A+5 = F
        show(4'hF, 4'hF, 4'b0000, 8'h1E);  // F+F = 1E

        // Subtraktion
        show(4'hA, 4'h3, 4'b0001, 8'h07);  // A-3 = 7
        show(4'h3, 4'hA, 4'b0001, 8'h00);  // Underflow → 0

        // Multiplikation
        show(4'hF, 4'hF, 4'b0010, 8'hE1);  // F*F = E1
        show(4'h3, 4'h4, 4'b0010, 8'h0C);  // 3*4 = C

        // Division
        show(4'hC, 4'h4, 4'b0011, 8'h03);  // C/4 = 3
        show(4'h7, 4'h0, 4'b0011, 8'hFF);  // Div0 → FF

        // Logik
        show(4'hA, 4'h5, 4'b0100, 8'h00);  // A AND 5 = 0
        show(4'hA, 4'h5, 4'b0101, 8'h0F);  // A OR  5 = F
        show(4'hA, 4'h5, 4'b0110, 8'h0F);  // A XOR 5 = F
        show(4'hF, 4'hF, 4'b0111, 8'h00);  // F NAND F = 0 (Nibble, ~1111=0000)
        show(4'h0, 4'h0, 4'b1000, 8'h0F);  // 0 NOR 0 = F

        $display("=== Simulation beendet ===");
        $finish;
    end

endmodule
