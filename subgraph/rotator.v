// ============================================================
// rotator.v  –  Zyklische Rotation eines 4-Element-Arrays
//
// Für Rotation r (0..3):
//   rotated[k] = original[(k + r) mod 4]
//
// Eingabe:  s0..s3      – Signatur-Array (Zeilenkomponenten)
//           rot [1:0]   – Rotationsbetrag (0..3)
// Ausgabe:  r0..r3      – rotiertes Array
// ============================================================

module rotator (
    input  wire [3:0] s0, s1, s2, s3,
    input  wire [1:0] rot,
    output reg  [3:0] r0, r1, r2, r3
);
    always @(*) begin
        case (rot)
            2'd0: begin r0=s0; r1=s1; r2=s2; r3=s3; end
            2'd1: begin r0=s1; r1=s2; r2=s3; r3=s0; end
            2'd2: begin r0=s2; r1=s3; r2=s0; r3=s1; end
            2'd3: begin r0=s3; r1=s0; r2=s1; r3=s2; end
        endcase
    end
endmodule
