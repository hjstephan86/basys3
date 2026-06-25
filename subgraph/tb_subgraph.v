// ============================================================
// tb_subgraph.v  –  Testbench für den Subgraph Algorithmus
//
// Testet alle relevanten Fälle aus dem Paper:
//   1. Beispiel aus Paper (A ⊂ B → keep_B)
//   2. Umkehrung (B ⊂ A → keep_A)
//   3. Identische Graphen
//   4. Keine Subgraph-Beziehung
//   5. Leerer Graph vs. vollständiger Graph
//   6. Kettenstruktur (Pfadgraph)
//   7. Zyklusgraph
//   8. Stern-Graph
// ============================================================

`timescale 1ns / 1ps

module tb_subgraph;

    // ── DUT-Signale ──────────────────────────────────────────
    reg        clk, rst, start;
    reg [15:0] A, B;
    wire [1:0] result;
    wire       done;
    wire [2:0] lcs_out;
    wire [1:0] best_rot;

    // ── DUT ──────────────────────────────────────────────────
    subgraph_top dut (
        .clk(clk), .rst(rst), .start(start),
        .A(A), .B(B),
        .result(result), .done(done),
        .lcs_out(lcs_out), .best_rot(best_rot)
    );

    // 100 MHz Takt
    always #5 clk = ~clk;

    // ── Hilfstask: Matrix aus Zeilen aufbauen ─────────────────
    // Matrix-Kodierung: A[j*4+i] = A[i][j]
    // Eingabe als Zeilenformat [row0, row1, row2, row3]
    // row0 = A[0][0..3], row1 = A[1][0..3] usw.
    task build_matrix;
        input [3:0] r0, r1, r2, r3;   // Zeilen der Adjazenzmatrix
        output [15:0] mat;
        integer col, row;
        begin
            mat = 16'b0;
            // Transponieren: mat[col*4+row] = r[row][col]
            mat[0]  = r0[0]; mat[1]  = r1[0]; mat[2]  = r2[0]; mat[3]  = r3[0]; // Spalte 0
            mat[4]  = r0[1]; mat[5]  = r1[1]; mat[6]  = r2[1]; mat[7]  = r3[1]; // Spalte 1
            mat[8]  = r0[2]; mat[9]  = r1[2]; mat[10] = r2[2]; mat[11] = r3[2]; // Spalte 2
            mat[12] = r0[3]; mat[13] = r1[3]; mat[14] = r2[3]; mat[15] = r3[3]; // Spalte 3
        end
    endtask

    // ── Hilfstask: Test ausführen ─────────────────────────────
    integer test_nr;
    integer pass_cnt, fail_cnt;

    task run_test;
        input [79:0]  name;        // 10 Zeichen
        input [15:0]  mat_a;
        input [15:0]  mat_b;
        input [1:0]   expected;
        begin
            A = mat_a; B = mat_b;
            @(posedge clk); #1;
            start = 1;
            @(posedge clk); #1;
            start = 0;
            // Warte auf done (max. 20 Takte)
            repeat(20) @(posedge clk);
            #1;
            test_nr = test_nr + 1;
            $write("Test %0d [%s]: result=%0b lcs=%0d rot=%0d ",
                   test_nr, name, result, lcs_out, best_rot);
            if (result === expected) begin
                $display("PASS (erwartet %0b)", expected);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("FAIL (erwartet %0b)", expected);
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    // ── Testmatrizen ─────────────────────────────────────────
    reg [15:0] mat_A, mat_B;

    initial begin
        clk = 0; rst = 1; start = 0;
        A = 0; B = 0;
        test_nr = 0; pass_cnt = 0; fail_cnt = 0;
        repeat(4) @(posedge clk);
        rst = 0;
        @(posedge clk);

        $display("=================================================");
        $display("  Subgraph Algorithmus — Testbench (N=4)");
        $display("=================================================");
        $display("Matrixkodierung: A[j*4+i] = A[i][j]");
        $display("result: 00=none 01=keep_B 10=keep_A 11=identisch");
        $display("-------------------------------------------------");

        // ── Test 1: Paper-Beispiel ────────────────────────────
        // G  (A): Pfad 0→1→2→3
        //   A = [[0,1,0,0],[0,0,1,0],[0,0,0,1],[0,0,0,0]]
        // G' (B): Pfad + Kante 0→2
        //   B = [[0,1,1,0],[0,0,1,0],[0,0,0,1],[0,0,0,0]]
        // Erwartet: keep_B (01) da B ⊇ A
        build_matrix(4'b0000, 4'b1000, 4'b0100, 4'b0010, mat_A);
        build_matrix(4'b0000, 4'b1000, 4'b1100, 4'b0010, mat_B);
        run_test("Paper Ex1", mat_A, mat_B, 2'b01);

        // ── Test 2: Umkehrung (keep_A) ────────────────────────
        // Jetzt A=B_paper, B=A_paper → keep_A
        run_test("Reverse  ", mat_B, mat_A, 2'b10);

        // ── Test 3: Identische Graphen ────────────────────────
        build_matrix(4'b0000, 4'b1000, 4'b0100, 4'b0010, mat_A);
        run_test("Identisch", mat_A, mat_A, 2'b11);

        // ── Test 4: Keine Beziehung ───────────────────────────
        // A: Kante 0→1
        // B: Kante 2→3  (disjunkt)
        build_matrix(4'b0000, 4'b1000, 4'b0000, 4'b0000, mat_A);
        build_matrix(4'b0000, 4'b0000, 4'b0000, 4'b0100, mat_B);
        run_test("Keine Bz.", mat_A, mat_B, 2'b00);

        // ── Test 5: Leerer Graph vs. vollständiger Graph ──────
        // A: leer (keine Kanten)
        // B: vollständig (alle Kanten außer Diagonale)
        build_matrix(4'b0000, 4'b0000, 4'b0000, 4'b0000, mat_A);
        build_matrix(4'b0000, 4'b1110, 4'b1101, 4'b1011, mat_B);
        // Leerer Graph ⊆ vollständiger Graph → keep_B
        run_test("Leer→Voll", mat_A, mat_B, 2'b01);

        // ── Test 6: Zyklusgraph C4 ────────────────────────────
        // A: 0→1→2→3→0 (Zyklus)
        build_matrix(4'b1000, 4'b0001, 4'b0100, 4'b0010, mat_A);
        // B: Zyklus + Diagonale 0→2
        build_matrix(4'b1000, 4'b0001, 4'b1100, 4'b0010, mat_B);
        run_test("Zyklus   ", mat_A, mat_B, 2'b01);

        // ── Test 7: Stern-Graph ───────────────────────────────
        // A: Stern mit Zentrum 0 (0→1, 0→2, 0→3)
        build_matrix(4'b0000, 4'b1000, 4'b1000, 4'b1000, mat_A);
        // B: Stern + Rückkante 1→0
        build_matrix(4'b0001, 4'b1000, 4'b1000, 4'b1000, mat_B);
        run_test("Stern    ", mat_A, mat_B, 2'b01);

        // ── Test 8: Zwei disjunkte Kanten ────────────────────
        // A: 0→1, 2→3
        // B: 0→2, 1→3  (unterschiedliche Kanten)
        build_matrix(4'b0000, 4'b1000, 4'b0000, 4'b0100, mat_A);
        build_matrix(4'b0000, 4'b0000, 4'b1000, 4'b0010, mat_B);
        run_test("2 Kanten ", mat_A, mat_B, 2'b00);

        // ── Test 9: Vollständiger Graph K4 ───────────────────
        // A = B = K4 → identisch
        build_matrix(4'b0111, 4'b1011, 4'b1101, 4'b1110, mat_A);
        run_test("K4 ident.", mat_A, mat_A, 2'b11);

        // ── Test 10: Einzelkante ─────────────────────────────
        // A: nur 0→1
        // B: nur 0→1  → identisch
        build_matrix(4'b0000, 4'b1000, 4'b0000, 4'b0000, mat_A);
        run_test("Einzel   ", mat_A, mat_A, 2'b11);

        $display("-------------------------------------------------");
        $display("Ergebnis: %0d/%0d Tests bestanden", pass_cnt, test_nr);
        $display("=================================================");
        $finish;
    end

    // Timeout-Schutz
    initial begin
        #5000;
        $display("TIMEOUT nach 5000 ns");
        $finish;
    end

    // Wellenform-Dump
    initial begin
        $dumpfile("subgraph.vcd");
        $dumpvars(0, tb_subgraph);
    end

endmodule
