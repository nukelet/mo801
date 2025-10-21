.global fmaddq_stub
fmaddq_stub:
    flq fa0, 0(a1)
    flq fa1, 0(a2)
    flq fa2, 0(a3)
    fmadd.q fa0, fa0, fa1, fa2
    fsq fa0, 0(a0)
    ret
