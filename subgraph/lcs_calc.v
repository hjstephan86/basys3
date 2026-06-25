// ============================================================
// lcs_calc.v  –  Longest Common Subsequence (LCS) für N=4
//
// Berechnet die Länge der LCS zweier Signatur-Arrays
// mittels dynamischer Programmierung (DP-Tabelle 5x5).
//
// Eingabe:  a[0..3], b[0..3]  – je 4 Signaturwerte (4 Bit)
// Ausgabe:  lcs_len [2:0]     – LCS-Länge (0..4)
//
// DP-Gleichung:
//   dp[i][j] = dp[i-1][j-1] + 1  falls a[i-1] == b[j-1]
//            = max(dp[i-1][j], dp[i][j-1])  sonst
// ============================================================

module lcs_calc (
    input  wire [3:0] a0, a1, a2, a3,   // Signatur-Array A (Zeilenkomponenten)
    input  wire [3:0] b0, b1, b2, b3,   // Signatur-Array B (nach Rotation)
    output reg  [2:0] lcs_len           // LCS-Länge
);

    // DP-Tabelle: dp[i][j] für i,j in 0..4
    // dp[0][j] = 0, dp[i][0] = 0
    reg [2:0] dp [0:4][0:4];

    // Hilfsfunktion: max zweier 3-Bit-Werte
    function [2:0] max3;
        input [2:0] x, y;
        begin
            max3 = (x >= y) ? x : y;
        end
    endfunction

    integer i, j;
    reg [3:0] a_arr [0:3];
    reg [3:0] b_arr [0:3];

    always @(*) begin
        a_arr[0] = a0; a_arr[1] = a1; a_arr[2] = a2; a_arr[3] = a3;
        b_arr[0] = b0; b_arr[1] = b1; b_arr[2] = b2; b_arr[3] = b3;

        // Initialisierung: erste Zeile und Spalte = 0
        for (j = 0; j <= 4; j = j + 1)
            dp[0][j] = 3'd0;
        for (i = 0; i <= 4; i = i + 1)
            dp[i][0] = 3'd0;

        // DP-Berechnung
        for (i = 1; i <= 4; i = i + 1) begin
            for (j = 1; j <= 4; j = j + 1) begin
                if (a_arr[i-1] == b_arr[j-1])
                    dp[i][j] = dp[i-1][j-1] + 3'd1;
                else
                    dp[i][j] = max3(dp[i-1][j], dp[i][j-1]);
            end
        end

        lcs_len = dp[4][4];
    end

endmodule
