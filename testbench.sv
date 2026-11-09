`include "interface.sv"
`include "include_package.sv"

`timescale 1ns/1ps

import include_package::*;

module testbench;
    intf pif();
    environment env;

    localparam K_SIZE   = `K_SIZE;
    localparam K_DWIDTH = `K_DWIDTH;
    localparam I_DWIDTH = `I_DWIDTH;
    localparam IL_IDX   = `IL_IDX;

    dspmac #(.K_SIZE(K_SIZE), .K_DWIDTH(K_DWIDTH), .I_DWIDTH(I_DWIDTH), .IL_IDX(IL_IDX)) dut (
        .kernel(pif.kernel),
        .iData(pif.iData),
        .pRes(pif.pRes),
        .oRes(pif.oRes)
    );
  
  
    initial begin
        env = new(pif);
        env.run();
    end

    initial begin
//        $dumpfile("dump.vcd");
//        $dumpvars;
    end

    // string  kernel_display = "[TB]";
    // bit signed [K_DWIDTH-1 : 0] k [K_SIZE];
    // bit signed [((K_DWIDTH + I_DWIDTH) + IL_IDX)-1 : 0] pR [K_SIZE];    
    // bit signed [((K_DWIDTH + I_DWIDTH) + IL_IDX + 1)-1 : 0] o [K_SIZE];
    // 
    // initial begin
        // for (int i = 0; i<K_SIZE; i++) begin
            // k[i]  = kernel[i*K_DWIDTH +: K_DWIDTH];
            // pR[i] = pRes[i*((K_DWIDTH + I_DWIDTH) + IL_IDX) +: ((K_DWIDTH + I_DWIDTH) + IL_IDX)];
            // o[i]  = oRes[i*((K_DWIDTH + I_DWIDTH) + IL_IDX + 1) +: ((K_DWIDTH + I_DWIDTH) + IL_IDX + 1)];
        // end
// 
        // for (int j = 0 ; j < K_SIZE  ; j++) begin
            // kernel_display += $sformatf("\tKernel %0d : %0d | ", j, k[j]);
        // end
// 
        // kernel_display += $sformatf("\tInput Data : %0d | ",iData);
// 
        // for (int k = 0 ; k < K_SIZE  ; k++) begin
            // kernel_display += $sformatf("\tPrev Res %0d : %0d | ", k, pR[k]);
        // end
// 
        // for (int l = 0 ; l < K_SIZE  ; l++) begin
            // kernel_display += $sformatf("\nObtained  Result %0d : %0d | ", l, o[l]);
        // end
        // 
        // $monitor("%s --->>> @ %0t\n",kernel_display, $time);
    // end

endmodule