class environment;

    localparam DELAY = `DELAY;

    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
  
    mailbox #(transaction) gen2drv;
    mailbox #(transaction) mon2scb;
  
    virtual intf vif;
  
    function new (virtual intf vif);
        this.vif = vif;
        gen2drv = new();
        mon2scb = new();
        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);
        gen.gen_next =  drv.drvdone; 
    endfunction
  
    task test_run();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any
    endtask
  
  
    task post_test();
        wait(gen.done.triggered);
        repeat(2) #DELAY;
        $display("-------- Simulation Over, Correct Matches : %f ------------", scb.correct);
        $finish;
    endtask
  
  
    task run();
        test_run();
        post_test();
    endtask

endclass