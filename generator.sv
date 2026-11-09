class generator; 

    transaction t;
    mailbox #(transaction) gen2drv;

    event gen_next;
    event done;

    int num_transactions = `NUM_TRANS;

    function new(mailbox #(transaction) gen2drv);
      t = new();
      this.gen2drv = gen2drv;
    endfunction

    task run();
      for(int i=0; i<num_transactions; i++) begin
        assert(t.randomize()) else $display("Randomization Failed @ %0t",$time);
//        t.display("[GEN]");
        $display("%b")
        gen2drv.put(t.copy);
        @(gen_next); 
      end
      ->done;
    endtask
    
endclass