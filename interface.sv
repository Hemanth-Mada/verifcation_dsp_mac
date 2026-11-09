interface intf();

    localparam K_SIZE   = `K_SIZE;
    localparam K_DWIDTH = `K_DWIDTH;
    localparam I_DWIDTH = `I_DWIDTH;
    localparam IL_IDX   = `IL_IDX;

    logic [(K_DWIDTH * K_SIZE)-1 : 0] kernel;
    logic [I_DWIDTH-1 : 0] iData;
    logic [(((K_DWIDTH + I_DWIDTH) + IL_IDX) * K_SIZE)-1 : 0] pRes;
    logic [(((K_DWIDTH + I_DWIDTH) + IL_IDX + 1) * K_SIZE)-1 : 0] oRes;

endinterface