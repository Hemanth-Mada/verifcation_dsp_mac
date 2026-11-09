class monitor;
  
  mailbox #(transaction) mon2scb;
  transaction t;
  virtual intf vif;
  localparam K_DWIDTH = `K_DWIDTH;
  localparam I_DWIDTH = `I_DWIDTH;
  localparam R_IDX = `IL_IDX;
  localparam K_SIZE = `K_SIZE;
  localparam DELAY = `DELAY;
  
  bit [K_DWIDTH - 1 : 0] unpacked_kernel[K_SIZE];
  bit [((K_DWIDTH + I_DWIDTH) + R_IDX) - 1 : 0] unpacked_peRes[K_SIZE];
  
  function new(virtual intf vif, mailbox #(transaction) mon2scb);
  	this.vif = vif;
    this.mon2scb = mon2scb;
    this.t = new();
  endfunction
  
  function void unpack_kernel(bit[(K_SIZE * K_DWIDTH) - 1:0] flat, ref bit [K_DWIDTH - 1 : 0] unpacked_kernel[K_SIZE]);
    for (int i = 0; i < K_SIZE; i++) begin
      unpacked_kernel[i] = (flat[i * K_DWIDTH +: K_DWIDTH]);
    end
  endfunction
  
  function void unpack_peRes(bit[(K_SIZE * ((K_DWIDTH + I_DWIDTH) + R_IDX)) - 1:0] flat, ref bit [((K_DWIDTH + I_DWIDTH) + R_IDX) - 1 : 0] unpacked_peRes[K_SIZE]);
    for (int i = 0; i < K_SIZE; i++) begin
      unpacked_peRes[i] = (flat[i * ((K_DWIDTH + I_DWIDTH) + R_IDX) +: ((K_DWIDTH + I_DWIDTH) + R_IDX)]);
    end
  endfunction

  
  task run();
    forever begin
      #DELAY;
//      $display("[MON] A_i: %0b", vif.A_i);
      unpack_kernel(vif.kernel, this.unpacked_kernel);
      unpack_peRes(vif.pRes, this.unpacked_peRes);
      t.kernel = this.unpacked_kernel;
      t.iData = vif.iData;
      t.pRes = this.unpacked_peRes;
      t.oRes = vif.oRes;
//      $display("--------------------------------");
//      $display("[MON] Prev res Check - %b", t.prev_res);
      mon2scb.put(t.copy);
    end
  endtask
  
  
endclass
