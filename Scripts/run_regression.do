# ============================================================
# AES Hardware Accelerator
# Full ModelSim Regression Script
#
# Runs all self-checking testbenches.
# ============================================================

# Save the complete regression transcript
transcript file regression.log

# Close any currently loaded simulation
quit -sim

# ------------------------------------------------------------
# Create a clean work library
# ------------------------------------------------------------
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
# Compile all testbenches
# ------------------------------------------------------------
vlog ../TB/Add_Round_Key_tb.v
vlog ../TB/AES_Accelerator_tb.v
vlog ../TB/AES_Decryption_Module_tb.v
vlog ../TB/AES_Encryption_Module_tb.v
vlog ../TB/Key_Expansion_128_Enc_tb.v
vlog ../TB/Key_Expansion_192_Enc_tb.v
vlog ../TB/Key_Expansion_256_Enc_tb.v
vlog ../TB/Key_Preparation_tb.v
vlog ../TB/Mix_Columns_tb.v
vlog ../TB/Mix_One_Column_tb.v
vlog ../TB/Sbox_tb.v
vlog ../TB/Shift_Rows_tb.v
vlog ../TB/Sub_Bytes_tb.v

# ------------------------------------------------------------
# Run regression
# ------------------------------------------------------------

puts ""
puts "============================================================"
puts " AES HARDWARE ACCELERATOR - FULL REGRESSION"
puts "============================================================"

puts ""
puts ">>> Running Sbox_tb"
vsim -voptargs=+acc work.Sbox_tb
run -all
quit -sim

puts ""
puts ">>> Running Sub_Bytes_tb"
vsim -voptargs=+acc work.Sub_Bytes_tb
run -all
quit -sim

puts ""
puts ">>> Running Shift_Rows_tb"
vsim -voptargs=+acc work.Shift_Rows_tb
run -all
quit -sim

puts ""
puts ">>> Running Mix_One_Column_tb"
vsim -voptargs=+acc work.Mix_One_Column_tb
run -all
quit -sim

puts ""
puts ">>> Running Mix_Columns_tb"
vsim -voptargs=+acc work.Mix_Columns_tb
run -all
quit -sim

puts ""
puts ">>> Running Add_Round_Key_tb"
vsim -voptargs=+acc work.Add_Round_Key_tb
run -all
quit -sim

puts ""
puts ">>> Running Key_Expansion_128_Enc_tb"
vsim -voptargs=+acc work.Key_Expansion_128_Enc_tb
run -all
quit -sim

puts ""
puts ">>> Running Key_Expansion_192_Enc_tb"
vsim -voptargs=+acc work.Key_Expansion_192_Enc_tb
run -all
quit -sim

puts ""
puts ">>> Running Key_Expansion_256_Enc_tb"
vsim -voptargs=+acc work.Key_Expansion_256_Enc_tb
run -all
quit -sim

puts ""
puts ">>> Running Key_Preparation_tb"
vsim -voptargs=+acc work.Key_Preparation_tb
run -all
quit -sim

puts ""
puts ">>> Running AES_Encryption_Module_tb"
vsim -voptargs=+acc work.AES_Encryption_Module_tb
run -all
quit -sim

puts ""
puts ">>> Running AES_Decryption_Module_tb"
vsim -voptargs=+acc work.AES_Decryption_Module_tb
run -all
quit -sim

puts ""
puts ">>> Running AES_Accelerator_tb"
vsim -voptargs=+acc work.AES_Accelerator_tb
run -all
quit -sim

puts ""
puts "============================================================"
puts " AES HARDWARE ACCELERATOR - REGRESSION COMPLETE"
puts "============================================================"
puts " 13 testbenches executed."
puts " Review PASS/FAIL messages above for test results."
puts " Complete transcript saved to regression.log"
puts "============================================================"

# Close transcript file
transcript file ""