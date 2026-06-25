# basys3

Verilog-Projekte für das Basys 3 FPGA-Board (XC7A35T-1CPG236C) mit Vivado 2019.2.

---

## Projekte

### alu — 4-Bit ALU mit 7-Segment-Anzeige

Implementierung einer 4-Bit ALU mit 9 Operationen und 4-stelliger 7-Segment-Anzeige.

| Datei | Beschreibung |
|---|---|
| `top.v` | Top-Level-Modul |
| `alu.v` | 8-Bit ALU (9 Operationen) |
| `seg7_mux.v` | 7-Segment-Multiplexer (4-stellig, 95 Hz Refresh) |
| `tb_top.v` | Testbench |
| `basys3_alu.xdc` | Pin-Constraints |
| `top.bit` | Fertige Bitstream-Datei |

**Kippschalter-Belegung:**

| Schalter | Bedeutung |
|---|---|
| SW[3:0] | Zahl A (0–F) |
| SW[7:4] | Zahl B (0–F) |
| SW[11:8] | Operation |

**Operationen (SW[11:8]):**

| Code | Operation |
|---|---|
| 0000 | A + B |
| 0001 | A − B |
| 0010 | A × B |
| 0011 | A ÷ B |
| 0100 | A AND B |
| 0101 | A OR B |
| 0110 | A XOR B |
| 0111 | A NAND B |
| 1000 | A NOR B |

**7-Segment-Anzeige:** `[A] [B] [Ergebnis High] [Ergebnis Low]`

---

### subgraph — Subgraph Algorithmus (Epp 2026)

Hardware-Implementierung des Subgraph Algorithmus für N=4 Knoten.  
Vergleicht zwei Graphen G und G' per Adjazenzmatrix, zyklischer Rotation und LCS.

| Datei | Beschreibung |
|---|---|
| `sig_calc.v` | Spalten-Signaturberechnung |
| `lcs_calc.v` | LCS per dynamischer Programmierung (4×4 DP-Tabelle) |
| `rotator.v` | Zyklische Rotation (4 Elemente) |
| `subgraph_top.v` | Top-Level FSM (5 Zustände) |
| `tb_subgraph.v` | Testbench (10 Testfälle, 10/10 bestanden) |
| `subgraph_basys3.xdc` | Pin-Constraints |

**Ergebnis-LEDs:**

| LED[1:0] | Bedeutung |
|---|---|
| `00` | Keine Subgraph-Beziehung |
| `01` | keep_B: G' ⊇ G |
| `10` | keep_A: G ⊇ G' |
| `11` | Identische Graphen |

**Komplexität:** O(n³), 6 Takte bei 100 MHz = 60 ns pro Berechnung.

---

## Release

| Version | Tag | Beschreibung |
|---|---|---|
| 1.0.0 | v1.0.0 | ALU mit 7-Segment-Anzeige |

---

## Tool-Chain

- **Synthese:** Vivado 2019.2 (WebPACK)
- **Part:** `xc7a35tcpg236-1`
- **Simulation:** Icarus Verilog (`iverilog` / `vvp`)
- **Board:** Digilent Basys 3
