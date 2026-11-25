.PHONY: rtl

rtl:
		vcs -full64 -sverilog \
			-cm line+cond+tgl+branch \
			-debug_access+all \
			rtl/keccak_theta.sv \
			-o simv
sim :
		./simv

keccak_round :
		vcs -full64 -sverilog \
		+define+DEBUG \
		rtl/keccak_round.sv \
		rtl/package.sv  \
		-o simv ; ./simv

clean : 
	  rm -rf *.vcd *.log simv *.key csrc *.daidir simv.vdb vcs

keccak_sponge :
		vcs -full64 -sverilog \
		+define+keccak_sponge \
		rtl/keccak_sponge.sv \
		rtl/package.sv  \
		-o simv ; ./simv