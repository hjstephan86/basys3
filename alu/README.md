# Basys 3 ALU – 7-Segment-Anzeige
## Vivado 2019.2 | XC7A35T-1CPG236C

---

## Projektstruktur

```
basys3alu/
├── top.v            Top-Level-Modul
├── alu.v            8-Bit ALU (9 Operationen)
├── seg7_mux.v       7-Segment-Multiplexer (4-stellig)
├── tb_top.v         Testbench (Behavioral Simulation)
└── basys3_alu.xdc   Pin-Constraints für Basys 3
```

---

## Kippschalter-Belegung

| Schalter   | Bedeutung                    |
|------------|------------------------------|
| SW[3:0]    | Zahl A  (0x0 – 0xF)          |
| SW[7:4]    | Zahl B  (0x0 – 0xF)          |
| SW[11:8]   | Operation (siehe Tabelle)    |
| SW[15:12]  | nicht verwendet              |

---

## Operationstabelle

| SW[11:8] | Operation      | Beispiel         |
|----------|----------------|------------------|
| 0000     | A + B          | F + F = 1E       |
| 0001     | A − B          | A − 3 = 07       |
| 0010     | A × B          | F × F = E1       |
| 0011     | A ÷ B          | C ÷ 4 = 03       |
| 0100     | A AND B        | A AND 5 = 00     |
| 0101     | A OR  B        | A OR  5 = 0F     |
| 0110     | A XOR B        | A XOR 5 = 0F     |
| 0111     | A NAND B       | F NAND F = 00    |
| 1000     | A NOR  B       | 0 NOR  0 = 0F    |

> **Sonderfälle:**
> - Subtraktion mit Underflow (A < B) → Ergebnis = 0x00
> - Division durch 0 (B = 0) → Ergebnis = 0xFF (Fehlercode)

---

## 7-Segment-Anzeige

```
  [DIG3]  [DIG2]  [DIG1]  [DIG0]
    A       B      Res-H   Res-L
  (AN[3]) (AN[2]) (AN[1]) (AN[0])
```

Beispiel: A=F, B=F, Op=× (0010) → Anzeige: **F F E 1**

---

## Vivado-Projekt anlegen

1. **Neues Projekt** in Vivado 2019.2 erstellen  
   `File → Project → New`

2. **Part:** `xc7a35tcpg236-1`

3. **Quelldateien hinzufügen:**  
   `Add Sources → Add or create design sources`  
   → `top.v`, `alu.v`, `seg7_mux.v`

4. **Constraints hinzufügen:**  
   `Add Sources → Add or create constraints`  
   → `basys3_alu.xdc`

5. **Top-Modul setzen:**  
   `top` als Top-Level (wird automatisch erkannt)

6. **Simulation (optional):**  
   `Add Sources → Add or create simulation sources`  
   → `tb_top.v`  
   `Flow → Run Simulation → Run Behavioral Simulation`

7. **Synthesize → Implement → Generate Bitstream**

8. **Programmieren:**  
   `Open Hardware Manager → Program Device`

---

## Segment-Encoding (aktiv LOW, Basys 3)

```
Segment:  a  b  c  d  e  f  g
Index:   [6][5][4][3][2][1][0]

    aaa
   f   b
   f   b
    ggg
   e   c
   e   c
    ddd
```

Bit-Reihenfolge: **{a, b, c, d, e, f, g}** → `seg[6:0]`  
0 = Segment AN, 1 = Segment AUS

| Zeichen | seg[6:0] (abcdefg) |
|---------|---------------------|
| 0       | 0000001             |
| 1       | 1001111             |
| 2       | 0010010             |
| 3       | 0000110             |
| 4       | 1001100             |
| 5       | 0100100             |
| 6       | 0100000             |
| 7       | 0001111             |
| 8       | 0000000             |
| 9       | 0000100             |
| A       | 0001000             |
| b       | 1100000             |
| C       | 0110001             |
| d       | 1000010             |
| E       | 0110000             |
| F       | 0111000             |
