class driver;
  
  mailbox #(transaction) gen2drv;
  transaction t;
  virtual intf vif;
  
  event drvdone;
  
  localparam K_SIZE = `K_SIZE;
  localparam K_DWIDTH = `K_DWIDTH;
  localparam R_IDX = `IL_IDX;
  localparam I_DWIDTH = `I_DWIDTH;
  localparam DELAY = `DELAY;
  
  bit [(K_SIZE * K_DWIDTH) - 1:0] packed_kernel;
  bit [K_DWIDTH - 1 : 0] unpacked_kernel[K_SIZE];
  
  string kernel_display = "";
  
    
  function new(virtual intf vif, mailbox #(transaction) gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
  endfunction
  
  function bit[(K_SIZE * K_DWIDTH) - 1:0] flatten_kernel (bit [K_DWIDTH - 1 : 0] kernel[K_SIZE]);
    bit [(K_SIZE * K_DWIDTH) - 1:0] result;

    for (int i = 0; i < K_SIZE; i++) begin
      result[i * K_DWIDTH +: K_DWIDTH] = kernel[i];
    end

    return result;
  endfunction
  
  function bit[(K_SIZE * K_DWIDTH) - 1:0] flatten_peRes (bit [((K_DWIDTH + I_DWIDTH) + R_IDX) - 1 : 0] peRes[K_SIZE]);
    bit [(((K_DWIDTH + I_DWIDTH) + R_IDX) * K_SIZE)-1 : 0] result;

    for (int i = 0; i < K_SIZE; i++) begin
      result[i * ((K_DWIDTH + I_DWIDTH) + R_IDX) +: ((K_DWIDTH + I_DWIDTH) + R_IDX)] = peRes[i];
    end

    return result;
  endfunction


  
  task run();
    forever begin
      gen2drv.get(t);
//      @(posedge vif.clk or negedge vif.aresetn);
       #DELAY;
       kernel_display = "";
       unpacked_kernel = t.kernel;
       for (int j = 0 ; j < K_SIZE ; j ++) begin
         kernel_display = {kernel_display, $sformatf("Kernel %0d: %0d | ", j, unpacked_kernel[j])};
       end
//       $display("[DRV] Kernel Values: %s Flattened Kernel %b", kernel_display,this.flatten(t.kernel));
//      result = this.flatten(t.kernel);
      vif.kernel <= this.flatten_kernel(t.kernel);
      vif.iData <= t.iData;
      vif.pRes <= this.flatten_peRes(t.pRes);
      ->drvdone;
    end
  endtask
  
  
endclass