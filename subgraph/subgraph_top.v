// ============================================================
// subgraph_top.v  –  Subgraph Algorithmus Top-Level
//
// Implementiert den Subgraph Algorithmus für N=4 Knoten.
//
// Eingabe:
//   A [15:0]  – Adjazenzmatrix G  (A[15:0] = Zeilen 0..3, Spalten 0..3)
//   B [15:0]  – Adjazenzmatrix G' (gleiche Kodierung)
//   start     – Puls: startet Berechnung
//   clk, rst
//
// Matrixkodierung: A[j*4 + i] = A[i][j]  (Spalte j, Zeile i)
//   A[3:0]   = Spalte 0  (A[0][0]..A[3][0])
//   A[7:4]   = Spalte 1
//   A[11:8]  = Spalte 2
//   A[15:12] = Spalte 3
//
// Ausgabe:
//   result [1:0]:
//     00 = keine Subgraph-Beziehung (beide behalten)
//     01 = keep_B  (B ⊇ A: G' enthält G)
//     10 = keep_A  (A ⊇ B: G enthält G')
//     11 = identisch
//   done      – 1 wenn Ergebnis gültig
//   lcs_out [2:0]  – beste LCS-Länge (Debug)
//   best_rot [1:0] – beste Rotation   (Debug)
// ============================================================

module subgraph_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [15:0] A,        // Adjazenzmatrix G
    input  wire [15:0] B,        // Adjazenzmatrix G'
    output reg  [1:0]  result,
    output reg         done,
    output reg  [2:0]  lcs_out,
    output reg  [1:0]  best_rot
);

    // ── Zustandsmaschine ──────────────────────────────────────
    localparam S_IDLE     = 3'd0;
    localparam S_SIG      = 3'd1;  // Signaturen berechnen
    localparam S_ROT      = 3'd2;  // Rotation testen
    localparam S_DECIDE   = 3'd3;  // Ergebnis entscheiden
    localparam S_DONE     = 3'd4;

    reg [2:0] state;
    reg [1:0] rot_cnt;             // aktueller Rotationsindex (0..3)

    // ── Spaltenextraktion ─────────────────────────────────────
    wire [3:0] A_col [0:3];
    wire [3:0] B_col [0:3];
    assign A_col[0] = A[3:0];   assign A_col[1] = A[7:4];
    assign A_col[2] = A[11:8];  assign A_col[3] = A[15:12];
    assign B_col[0] = B[3:0];   assign B_col[1] = B[7:4];
    assign B_col[2] = B[11:8];  assign B_col[3] = B[15:12];

    // ── Signatur-Module für A und B ───────────────────────────
    wire [3:0] rowA [0:3];   // Zeilenkomponenten A
    wire [3:0] rowB [0:3];   // Zeilenkomponenten B

    genvar g;
    generate
        for (g = 0; g < 4; g = g + 1) begin : sig_gen
            wire [7:0] sigA_w, sigB_w;
            sig_calc uA (.col(A_col[g]), .col_idx(g[1:0]),
                         .sigma(sigA_w), .row_sig(rowA[g]));
            sig_calc uB (.col(B_col[g]), .col_idx(g[1:0]),
                         .sigma(sigB_w), .row_sig(rowB[g]));
        end
    endgenerate

    // ── Rotations-Modul für B ─────────────────────────────────
    wire [3:0] rB0, rB1, rB2, rB3;

    rotator u_rot (
        .s0(rowB[0]), .s1(rowB[1]), .s2(rowB[2]), .s3(rowB[3]),
        .rot(rot_cnt),
        .r0(rB0), .r1(rB1), .r2(rB2), .r3(rB3)
    );

    // ── LCS-Modul ─────────────────────────────────────────────
    wire [2:0] lcs_result;

    lcs_calc u_lcs (
        .a0(rowA[0]), .a1(rowA[1]), .a2(rowA[2]), .a3(rowA[3]),
        .b0(rB0),     .b1(rB1),     .b2(rB2),     .b3(rB3),
        .lcs_len(lcs_result)
    );

    // ── Subgraph-Prüfung: A ⊆ B ─────────────────────────────
    // A ist Subgraph von B wenn alle Spalten von A in B (nach Rotation) enthalten sind
    // Vereinfachte Prüfung: B[i][j] >= A[i][j] für alle i,j
    // (B hat überall mindestens so viele Kanten wie A)
    wire A_sub_B;   // A ⊆ B?
    wire B_sub_A;   // B ⊆ A?
    assign A_sub_B = ((B & A) == A);   // A ist Teilmenge von B
    assign B_sub_A = ((A & B) == B);   // B ist Teilmenge von A

    // ── Registrierte beste LCS ────────────────────────────────
    reg [2:0] best_lcs;

    // ── Popcount Funktion ─────────────────────────────────────
    function [4:0] popcount16;
        input [15:0] v;
        integer k;
        reg [4:0] cnt;
        begin
            cnt = 0;
            for (k = 0; k < 16; k = k + 1)
                cnt = cnt + v[k];
            popcount16 = cnt;
        end
    endfunction

    // ── FSM ──────────────────────────────────────────────────
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= S_IDLE;
            done     <= 1'b0;
            result   <= 2'b00;
            rot_cnt  <= 2'd0;
            best_lcs <= 3'd0;
            lcs_out  <= 3'd0;
            best_rot <= 2'd0;
        end else begin
            case (state)

                S_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        rot_cnt  <= 2'd0;
                        best_lcs <= 3'd0;
                        best_rot <= 2'd0;
                        state    <= S_SIG;
                    end
                end

                S_SIG: begin
                    // Signaturen sind kombinatorisch — direkt weiter
                    state <= S_ROT;
                end

                S_ROT: begin
                    // LCS mit aktueller Rotation kombinatorisch verfügbar
                    if (lcs_result > best_lcs) begin
                        best_lcs <= lcs_result;
                        best_rot <= rot_cnt;
                    end
                    if (rot_cnt == 2'd3) begin
                        state <= S_DECIDE;
                    end else begin
                        rot_cnt <= rot_cnt + 2'd1;
                    end
                end

                S_DECIDE: begin
                    lcs_out <= best_lcs;
                    // Entscheidung basierend auf Subgraph-Beziehung
                    if (A == B)
                        result <= 2'b11;          // identisch
                    else if (A_sub_B && !B_sub_A)
                        result <= 2'b01;          // keep_B (B ⊇ A)
                    else if (B_sub_A && !A_sub_B)
                        result <= 2'b10;          // keep_A (A ⊇ B)
                    else if (best_lcs >= 3'd2) begin
                        // LCS-basierte Entscheidung:
                        // Mehr Kanten in B → keep_B
                        if (popcount16(B) > popcount16(A))
                            result <= 2'b01;
                        else if (popcount16(A) > popcount16(B))
                            result <= 2'b10;
                        else
                            result <= 2'b00;
                    end else
                        result <= 2'b00;          // keine Beziehung
                    state <= S_DONE;
                end

                S_DONE: begin
                    done  <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
