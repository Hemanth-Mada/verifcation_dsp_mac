class transaction;

  localparam K_DWIDTH = `K_DWIDTH;
  localparam I_DWIDTH = `I_DWIDTH;
  localparam R_IDX = `IL_IDX;
  localparam K_SIZE = `K_SIZE;
  
  // Create an array to store all those elements
  randc bit [(K_DWIDTH)-1 : 0] kernel [K_SIZE];
  randc bit [I_DWIDTH-1 : 0] iData;
  randc bit [((K_DWIDTH + I_DWIDTH) + R_IDX) - 1 : 0] pRes[K_SIZE];
  bit [(((K_DWIDTH + I_DWIDTH) + R_IDX + 1) * K_SIZE)-1 : 0] oRes;
  
  // Put a constraint on these values
  constraint kernel_constraints {
    foreach (kernel[i]) {
      kernel[i] != {1'b1, {(K_DWIDTH - 1){1'b0}}};
    }
  }
  
  constraint image_constraint {
    iData != {1'b1, {(I_DWIDTH - 1){1'b0}}};
  }
  
  constraint prevRes_constraint {
    foreach (pRes[i]) {
        pRes[i] != {1'b1, {(K_DWIDTH + I_DWIDTH + R_IDX - 1){1'b0}}};
    }
  }
      
  function transaction copy();
    copy = new();
    copy.kernel = this.kernel;
    copy.iData = this.iData;
    copy.pRes = this.pRes;
    copy.oRes = this.oRes;
  endfunction
endclass
