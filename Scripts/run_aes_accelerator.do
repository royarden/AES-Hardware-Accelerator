# ============================================================
# AES Hardware Accelerator
# ModelSim simulation script
#
# Top-level testbench: AES_Accelerator_tb
# ============================================================

# Close any currently loaded simulation
quit -sim

# Start from a clean work library
if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# ------------------------------------------------------------
# Compile RTL
# ------------------------------------------------------------

vlog ../RTL/Sbox_Enc.v
vlog ../RTL/Sbox_Dec.v

vlog ../RTL/Sub_Bytes_Enc.v
vlog ../RTL/Sub_Bytes_Dec.v

vlog ../RTL/Shift_Rows_Enc.v
vlog ../RTL/Shift_Rows_Dec.v

vlog ../RTL/Mix_One_Column_Enc.v
vlog ../RTL/Mix_One_Column_Dec.v

vlog ../RTL/Mix_Columns_Enc.v
vlog ../RTL/Mix_Columns_Dec.v

vlog ../RTL/Add_Round_Key_Enc.v
vlog ../RTL/Add_Round_Key_Dec.v

vlog ../RTL/Key_Expansion_128_Enc.v
vlog ../RTL/Key_Expansion_192_Enc.v
vlog ../RTL/Key_Expansion_256_Enc.v

vlog ../RTL/Key_Preparation.v

vlog ../RTL/AES_Encryption_Module.v
vlog ../RTL/AES_Decryption_Module.v

vlog ../RTL/AES_Accelerator.v

# ------------------------------------------------------------
# Compile top-level testbench
# ------------------------------------------------------------

vlog ../TB/AES_Accelerator_tb.v

# ------------------------------------------------------------
# Run simulation
# ------------------------------------------------------------

vsim -voptargs=+acc work.AES_Accelerator_tb

run -all