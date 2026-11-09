class scoreboard;
  
    
    transaction t;
    
    mailbox #(transaction) mon2sco;
    longint correct;
    longint ptcorrect;

    localparam K_SIZE   = `K_SIZE;
    localparam K_DWIDTH = `K_DWIDTH;
    localparam I_DWIDTH = `I_DWIDTH;
    localparam IL_IDX   = `IL_IDX;

  
    function new(mailbox #(transaction) mon2sco);
        this.mon2sco = mon2sco;
        this.correct = 0;
    endfunction
  
    function bit signed [((K_DWIDTH + I_DWIDTH) + IL_IDX + 1)-1 : 0] mac(input signed [K_DWIDTH-1:0] a, input signed [I_DWIDTH-1 : 0] b, input signed [((K_DWIDTH + I_DWIDTH) + IL_IDX)-1 : 0] p);
        mac = (a*b) + p ;
    endfunction
  
  
    task run();
        forever begin
            mon2sco.get(t);      
//            t.display("[SCO]");
//            $display("%b, %b, %b",t.kernel, t.pRes, t.oRes);
            ptcorrect = 0;
            for(int i=0 ; i<K_SIZE; i++) begin
                bit signed [K_DWIDTH-1 : 0] a = t.kernel[i];
                bit signed [I_DWIDTH-1 : 0] b = t.iData;
                bit signed [((K_DWIDTH + I_DWIDTH) + IL_IDX)-1 : 0] p = t.pRes[i];
                bit signed [((K_DWIDTH + I_DWIDTH) + IL_IDX + 1)-1 : 0] o = t.oRes[i*((K_DWIDTH + I_DWIDTH) + IL_IDX + 1) +: ((K_DWIDTH + I_DWIDTH) + IL_IDX + 1)];
                bit signed [((K_DWIDTH + I_DWIDTH) + IL_IDX + 1)-1 : 0] macOut = mac(a,b,p);
                assert( o == mac(a,b,p)) begin
                    ptcorrect++;
//                    $display("Golden Value : %d, Obtained Value : %d %d",macOut,o,i);
                end 
                else begin
                    $display("Golden Value : %d, Obtained Value : %d, Error @ %d",macOut,o,i);
                end 
            end
            if(ptcorrect == K_SIZE) correct = correct + 1;
            else begin
                $error("Incorrect Result --->>> @ %0t",$time);
//                t.display("[SCO]");
            end
        end
    endtask
    
endclass