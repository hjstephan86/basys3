// ============================================================
// top.v  –  Basys 3 ALU mit 7-Segment-Anzeige
// Board  :  XC7A35T-1CPG236C  (Basys 3)
// Tool   :  Vivado 2019.2
//
// sw[3:0]   = Zahl A  (0–F)
// sw[7:4]   = Zahl B  (0–F)
// sw[11:8]  = Operation
//               0000 = Addition     (+)
//               0001 = Subtraktion  (-)
//               0010 = Multiplikation (x)
//               0011 = Division     (/)
//               0100 = AND
//               0101 = OR
//               0110 = XOR
//               0111 = NAND
//               1000 = NOR
//
// 7-Segment (aktive LOW, gemeinsame Anode):
//   AN[0] = Digit 0 (ganz rechts)  → Ergebnis Low-Nibble
//   AN[1] = Digit 1                → Ergebnis High-Nibble
//   AN[2] = Digit 2                → Zahl B
//   AN[3] = Digit 3 (ganz links)   → Zahl A
// ============================================================

module top (
    input  wire        clk,        // 100 MHz Systemtakt
    input  wire [15:0] sw,         // 16 Kippschalter
    output wire [6:0]  seg,        // Segmente a–g (aktive LOW)
    output wire        dp,         // Dezimalpunkt (aktive LOW, hier aus)
    output wire [3:0]  an          // Anoden-Enable (aktive LOW)
);

    // ----------------------------------------------------------
    // 1. ALU
    // ----------------------------------------------------------
    wire [3:0] A    = sw[3:0];
    wire [3:0] B    = sw[7:4];
    wire [3:0] op   = sw[11:8];
    wire [7:0] result;

    alu u_alu (
        .A      (A),
        .B      (B),
        .op     (op),
        .result (result)
    );

    // ----------------------------------------------------------
    // 2. Zuweisung der vier Nibble an die Displays
    //    digit3 = A        (Anzeige ganz links,  AN[3])
    //    digit2 = B        (AN[2])
    //    digit1 = result[7:4]  High-Nibble  (AN[1])
    //    digit0 = result[3:0]  Low-Nibble   (AN[0])
    // ----------------------------------------------------------
    wire [3:0] digit3 = A;
    wire [3:0] digit2 = B;
    wire [3:0] digit1 = result[7:4];
    wire [3:0] digit0 = result[3:0];

    // ----------------------------------------------------------
    // 3. Multiplexer + Treiber
    // ----------------------------------------------------------
    seg7_mux u_mux (
        .clk    (clk),
        .digit3 (digit3),
        .digit2 (digit2),
        .digit1 (digit1),
        .digit0 (digit0),
        .seg    (seg),
        .an     (an)
    );

    assign dp = 1'b1; // Dezimalpunkt aus (aktiv LOW → HIGH = aus)

endmodule
