# ============================================================
# subgraph_basys3.xdc  –  Constraints für Basys 3 (XC7A35T-1CPG236C)
#
# Belegung:
#   SW[15:0]  → Adjazenzmatrix A (16 Kippschalter)
#   BTNC      → start
#   BTNR      → Eingabe B (simuliert durch zweite Konfiguration)
#   LED[1:0]  → result
#   LED[2]    → done
#   LED[5:3]  → lcs_out
#   LED[7:6]  → best_rot
# ============================================================

# Systemtakt 100 MHz
set_property PACKAGE_PIN W5   [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports clk]

# Reset (BTNU)
set_property PACKAGE_PIN T18  [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Start (BTNC)
set_property PACKAGE_PIN U18  [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]

# Kippschalter SW[0..15] → Matrix A
set_property PACKAGE_PIN V17  [get_ports {A[0]}]
set_property PACKAGE_PIN V16  [get_ports {A[1]}]
set_property PACKAGE_PIN W16  [get_ports {A[2]}]
set_property PACKAGE_PIN W17  [get_ports {A[3]}]
set_property PACKAGE_PIN W15  [get_ports {A[4]}]
set_property PACKAGE_PIN V15  [get_ports {A[5]}]
set_property PACKAGE_PIN W14  [get_ports {A[6]}]
set_property PACKAGE_PIN W13  [get_ports {A[7]}]
set_property PACKAGE_PIN V2   [get_ports {A[8]}]
set_property PACKAGE_PIN T3   [get_ports {A[9]}]
set_property PACKAGE_PIN T2   [get_ports {A[10]}]
set_property PACKAGE_PIN R3   [get_ports {A[11]}]
set_property PACKAGE_PIN W2   [get_ports {A[12]}]
set_property PACKAGE_PIN U1   [get_ports {A[13]}]
set_property PACKAGE_PIN T1   [get_ports {A[14]}]
set_property PACKAGE_PIN R2   [get_ports {A[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {A[*]}]

# LEDs
set_property PACKAGE_PIN U16  [get_ports {result[0]}]
set_property PACKAGE_PIN E19  [get_ports {result[1]}]
set_property PACKAGE_PIN U19  [get_ports done]
set_property PACKAGE_PIN V19  [get_ports {lcs_out[0]}]
set_property PACKAGE_PIN W18  [get_ports {lcs_out[1]}]
set_property PACKAGE_PIN U15  [get_ports {lcs_out[2]}]
set_property PACKAGE_PIN U14  [get_ports {best_rot[0]}]
set_property PACKAGE_PIN V14  [get_ports {best_rot[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {result[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports done]
set_property IOSTANDARD LVCMOS33 [get_ports {lcs_out[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {best_rot[*]}]
