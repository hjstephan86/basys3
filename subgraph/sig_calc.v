// ============================================================
// sig_calc.v  –  Spalten-Signatur-Berechnung
//
// Für N=4 Knoten, Spalte j:
//   sigma_j = SUM(A[i][j] * 2^i, i=0..3) + j * 2^4
//
// Die "Zeilenkomponente" (row_sig) ist:
//   row_j = SUM(A[i][j] * 2^i, i=0..3)
//
// Ports:
//   col      [3:0]  – Spaltenwert (A[0][j], A[1][j], A[2][j], A[3][j])
//   col_idx  [1:0]  – Spaltenindex j (0..3)
//   sigma    [7:0]  – vollständige Signatur
//   row_sig  [3:0]  – Zeilenkomponente (ohne Spaltengewichtung)
// ============================================================

module sig_calc (
    input  wire [3:0] col,        // Spaltenvektor [A[3][j]..A[0][j]]
    input  wire [1:0] col_idx,    // j = 0..3
    output wire [7:0] sigma,      // sigma_j = row + j*16
    output wire [3:0] row_sig     // nur Zeilenkomponente
);
    // row_sig = col selbst (da col[i] = A[i][j] = A[i][j]*2^i mit Basis-2)
    assign row_sig = col;
    // sigma = row_sig + j * 2^N = col + col_idx * 16
    assign sigma   = {2'b00, col} + {col_idx, 4'b0000};
endmodule
