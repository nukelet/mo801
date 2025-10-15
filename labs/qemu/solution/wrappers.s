.global bitcnt_wrapper
bitcnt_wrapper:
        .word 0xFEA5F533 # bitcnt a0, a0, a1
        #1111111 01010 01011 111 01010 0110011
        #1111 1110 1010 0101 1111 0101 0011 0011
        ret

.global multmod_wrapper
multmod_wrapper:
        # multmod rd, rs1, rs2 -> rd = (rd * rs1) % rs2
        # 1111111 01100 01011 110 01010 0110011
        # 1111 1110 1100 0101 1110 0101 0011 0011
        .word 0xFEC5E533    # multmod a0, a1, a2
        ret

.global bitrev_wrapper
bitrev_wrapper:
        # 00000000.0000 0101.0 000 0101.0 1111111
        .word 0x0005057F
        ret

.global cclz_wrapper
cclz_wrapper:
        # 00000000.0000 0101.0 001 0101.0 1111111
        .word 0x0005157F
        ret

.global cctz_wrapper
cctz_wrapper:
        # 00000000.0000 0101.0 010 0101.0 1111111
        .word 0x0005257F
        ret
