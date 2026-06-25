// ============================================================
// seg7_mux.v  –  4-stelliger 7-Segment-Multiplexer
//
// Basys 3: gemeinsame Anode, alle Signale aktiv LOW
//
// XDC-Pinbelegung (Basys 3 Schematic):
//   seg[6]=CA=a, seg[5]=CB=b, seg[4]=CC=c, seg[3]=CD=d,
//   seg[2]=CE=e, seg[1]=CF=f, seg[0]=CG=g
//
// Bit-Reihenfolge im case: {a,b,c,d,e,f,g} → seg[6:0]
//
// Refresh-Rate: 100 MHz / 2^18 ≈ 381 Hz pro Digit
//               → 4 Digits ≈ 95 Hz Gesamt-Refresh (flimmerfrei)
// ============================================================

module seg7_mux (
    input  wire        clk,
    input  wire [3:0]  digit3,   // ganz links  (AN[3])
    input  wire [3:0]  digit2,
    input  wire [3:0]  digit1,
    input  wire [3:0]  digit0,   // ganz rechts (AN[0])
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);

    // ----------------------------------------------------------
    // Refresh-Zähler  (18 Bit → obere 2 Bit wählen Digit)
    // ----------------------------------------------------------
    reg [17:0] refresh_cnt = 18'b0;

    always @(posedge clk)
        refresh_cnt <= refresh_cnt + 1'b1;

    wire [1:0] sel = refresh_cnt[17:16];

    // ----------------------------------------------------------
    // Digit-MUX
    // ----------------------------------------------------------
    reg [3:0] current_digit;

    always @(*) begin
        case (sel)
            2'b00: begin an = 4'b1110; current_digit = digit0; end
            2'b01: begin an = 4'b1101; current_digit = digit1; end
            2'b10: begin an = 4'b1011; current_digit = digit2; end
            2'b11: begin an = 4'b0111; current_digit = digit3; end
        endcase
    end

    // ----------------------------------------------------------
    // Hex → 7-Segment-Decoder  (aktiv LOW)
    //
    //     aaa
    //    f   b
    //    f   b
    //     ggg
    //    e   c
    //    e   c
    //     ddd
    //
    // seg[6]=a  seg[5]=b  seg[4]=c  seg[3]=d
    // seg[2]=e  seg[1]=f  seg[0]=g
    //
    // Encoding: {a,b,c,d,e,f,g}  0=AN, 1=AUS
    // ----------------------------------------------------------
    always @(*) begin
        case (current_digit)
            //               abcdefg
            4'h0: seg = 7'b0000001;  // 0  – nur g aus
            4'h1: seg = 7'b1001111;  // 1  – nur b,c an
            4'h2: seg = 7'b0010010;  // 2
            4'h3: seg = 7'b0000110;  // 3
            4'h4: seg = 7'b1001100;  // 4
            4'h5: seg = 7'b0100100;  // 5
            4'h6: seg = 7'b0100000;  // 6
            4'h7: seg = 7'b0001111;  // 7
            4'h8: seg = 7'b0000000;  // 8  – alle an
            4'h9: seg = 7'b0000100;  // 9
            4'hA: seg = 7'b0001000;  // A
            4'hB: seg = 7'b1100000;  // b
            4'hC: seg = 7'b0110001;  // C
            4'hD: seg = 7'b1000010;  // d
            4'hE: seg = 7'b0110000;  // E
            4'hF: seg = 7'b0111000;  // F
            default: seg = 7'b1111111; // aus
        endcase
    end

endmodule
