# Subgraph Algorithmus — Verilog Implementierung
## Basys 3 (XC7A35T-1CPG236C) | Vivado 2019.2

---

## Algorithmus-Überblick

Der Subgraph Algorithmus (Epp 2026) vergleicht zwei Graphen G und G' (je N=4 Knoten)
mittels Adjazenzmatrizen und bestimmt in O(n³), ob G Subgraph von G' ist.

### Schritte:
1. **Signatur-Berechnung:** σ_j = Σ(A[i][j]·2^i) + j·2^N pro Spalte
2. **Zyklische Rotation:** N Rotationen des Signatur-Arrays von B
3. **LCS-Vergleich:** Längste gemeinsame Teilsequenz → Subgraph-Entscheidung

---

## Modulstruktur

```
subgraph_verilog/
├── sig_calc.v          Spalten-Signaturberechnung
├── lcs_calc.v          LCS per dynamischer Programmierung (4×4 DP-Tabelle)
├── rotator.v           Zyklische Rotation (4 Elemente)
├── subgraph_top.v      Top-Level FSM (5 Zustände)
├── tb_subgraph.v       Testbench (10 Testfälle)
└── subgraph_basys3.xdc Pin-Constraints Basys 3
```

---

## Matrixkodierung

Matrix A als 16-Bit-Wort: `A[j*4 + i] = A[i][j]` (Spalte j, Zeile i)

```
A[3:0]   = Spalte 0  (Einträge A[0][0]..A[3][0])
A[7:4]   = Spalte 1
A[11:8]  = Spalte 2
A[15:12] = Spalte 3
```

**Beispiel aus dem Paper:**
```
G  (Pfad 0→1→2→3):     A = 16'b0010_0100_1000_0000 = 0x2480
G' (+ Kante 0→2):      B = 16'b0010_0100_1100_0000 = 0x24C0
Ergebnis: keep_B (01)
```

---

## Ausgabe (result)

| result | Bedeutung |
|--------|-----------|
| `00`   | Keine Subgraph-Beziehung — beide behalten |
| `01`   | keep_B: G' ⊇ G (B enthält A) |
| `10`   | keep_A: G ⊇ G' (A enthält B) |
| `11`   | Identische Graphen |

---

## Simulation (Icarus Verilog)

```bash
iverilog -o sim.out sig_calc.v lcs_calc.v rotator.v subgraph_top.v tb_subgraph.v
vvp sim.out
```

**Simulationsergebnis (10/10 Tests bestanden):**
```
Test  1 [Paper Ex1]: result=01  lcs=3 rot=0  PASS
Test  2 [Reverse  ]: result=10  lcs=3 rot=0  PASS
Test  3 [Identisch]: result=11  lcs=4 rot=0  PASS
Test  4 [Keine Bz.]: result=00  lcs=3 rot=0  PASS
Test  5 [Leer→Voll]: result=01  lcs=0 rot=0  PASS
Test  6 [Zyklus   ]: result=01  lcs=3 rot=0  PASS
Test  7 [Stern    ]: result=01  lcs=3 rot=0  PASS
Test  8 [2 Kanten ]: result=00  lcs=3 rot=2  PASS
Test  9 [K4 ident.]: result=11  lcs=4 rot=0  PASS
Test 10 [Einzel   ]: result=11  lcs=4 rot=0  PASS
Ergebnis: 10/10 Tests bestanden
```

---

## Vivado-Projekt

1. Neues Projekt, Part `xc7a35tcpg236-1`
2. Design Sources: `sig_calc.v`, `lcs_calc.v`, `rotator.v`, `subgraph_top.v`
3. Constraints: `subgraph_basys3.xdc`
4. Simulation: `tb_subgraph.v`
5. Top-Module: `subgraph_top`
6. Synthesize → Implement → Generate Bitstream

---

## Hardware-Belegung (Basys 3)

| Signal | Pins | Beschreibung |
|--------|------|--------------|
| `A[15:0]` | SW[15:0] | Adjazenzmatrix G (16 Kippschalter) |
| `start` | BTNC | Berechnung starten |
| `rst` | BTNU | Reset |
| `result[1:0]` | LED[1:0] | Ergebnis (00/01/10/11) |
| `done` | LED[2] | 1 = Ergebnis gültig |
| `lcs_out[2:0]` | LED[5:3] | Beste LCS-Länge |
| `best_rot[1:0]` | LED[7:6] | Beste Rotation |

**Hinweis:** Matrix B muss per Neuprogrammierung oder zweiten
Schalterblock eingegeben werden. Für vollständige Zwei-Matrix-Eingabe
empfiehlt sich eine UART-Schnittstelle (Erweiterung).

---

## Komplexität

| Schritt | Takte | Komplexität |
|---------|-------|-------------|
| Signatur | 1 | O(n²) kombinatorisch |
| Rotation × LCS | 4 × 1 | O(n³) kombinatorisch |
| Entscheidung | 1 | O(1) |
| **Gesamt** | **6** | **O(n³)** |

Da alle Module kombinatorisch implementiert sind, benötigt die
FSM nur 6 Takte für ein vollständiges Ergebnis bei 100 MHz.
