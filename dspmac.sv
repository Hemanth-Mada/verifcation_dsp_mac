`include "defines.svh"

module dspmac #(
    parameter K_SIZE   = 3,
    parameter K_DWIDTH = 8,
    parameter I_DWIDTH = 8,
    parameter IL_IDX    = 1
)(
    // Input Signals
    input [(K_DWIDTH * K_SIZE)-1 : 0] kernel,
    input [I_DWIDTH-1 : 0] iData,
    input [(((K_DWIDTH + I_DWIDTH) + IL_IDX) * K_SIZE)-1 : 0] pRes,

    // Output Signals
    output logic [(((K_DWIDTH + I_DWIDTH) + IL_IDX + 1) * K_SIZE)-1 : 0] oRes
);
    localparam DSP_OP1_DWIDTH = `DSP_OP1_DWIDTH;
    localparam DSP_ACC_DWIDTH = `DSP_ACC_DWIDTH;
    localparam PRES_DWIDTH = I_DWIDTH + K_DWIDTH + IL_IDX;
    localparam OPRES_DWIDTH = K_DWIDTH + I_DWIDTH + IL_IDX + 1;

    // Number of MAC's possible in one DSP
    localparam NUM_MAC_MIN = (DSP_OP1_DWIDTH / (K_DWIDTH + IL_IDX + 2 + I_DWIDTH));
    localparam NUM_MAC_EXTRA = (DSP_OP1_DWIDTH - NUM_MAC_MIN*(K_DWIDTH + IL_IDX + 2 + I_DWIDTH)) > (K_DWIDTH) ? 1 : 0;
    localparam NUM_MAC = NUM_MAC_MIN + NUM_MAC_EXTRA;
    localparam NUM_DSP = (K_SIZE / NUM_MAC) + ((K_SIZE % NUM_MAC) ? 1 : 0);

    logic [(K_SIZE * OPRES_DWIDTH)-1:0] C_j;


    for (genvar i=0; i<K_SIZE; i++) begin : gen_C
        assign C_j[i*OPRES_DWIDTH +: OPRES_DWIDTH] = {1'b0,pRes[i*PRES_DWIDTH +: PRES_DWIDTH]};
    end

    for (genvar j = 0; j<NUM_DSP; j++) begin : gen_dsp
        if(j== NUM_DSP-1) begin
            localparam REM = K_SIZE - NUM_MAC*(NUM_DSP-1);
            logic [(REM*OPRES_DWIDTH)-1:0] O_temp;
            logic [DSP_ACC_DWIDTH-1 : 0] C_j_temp;
            logic [(NUM_MAC*K_DWIDTH)- 1 : 0] k_temp;

            assign C_j_temp = {{(DSP_ACC_DWIDTH-(REM*OPRES_DWIDTH)){1'b0}},C_j[j*NUM_MAC*OPRES_DWIDTH +: REM*OPRES_DWIDTH]};
            assign k_temp = {{(NUM_MAC-REM)*(K_DWIDTH){1'b0}}, kernel[j*(NUM_MAC*K_DWIDTH) +: (REM*K_DWIDTH)]};
            dspgen #(
                    .I_DWIDTH(I_DWIDTH),
                    .K_DWIDTH(K_DWIDTH),
                    .IL_IDX(IL_IDX),
                    .NUM_MAC(NUM_MAC)
                ) dsp (
                    .B_i(iData), // This is the image pixel.
                    .A_i(k_temp), // These are the flattened Kernel Values.
                    .C_i(C_j_temp),
                    .oCorrect(O_temp)
            );
            assign oRes[(j*NUM_MAC*OPRES_DWIDTH) +: (REM*OPRES_DWIDTH)] = O_temp;
        end
        else begin
            logic [(NUM_MAC*OPRES_DWIDTH)-1:0] O_temp;
            logic [DSP_ACC_DWIDTH-1 : 0] C_j_temp;
            logic [(NUM_MAC*K_DWIDTH)- 1 : 0] k_temp;

            assign C_j_temp = {{(DSP_ACC_DWIDTH-(NUM_MAC*OPRES_DWIDTH)){1'b0}},C_j[j*NUM_MAC*OPRES_DWIDTH +: NUM_MAC*OPRES_DWIDTH]};
            assign k_temp = kernel[j*(NUM_MAC*K_DWIDTH) +: (NUM_MAC*K_DWIDTH)];
            dspgen #(
                    .I_DWIDTH(I_DWIDTH),
                    .K_DWIDTH(K_DWIDTH),
                    .IL_IDX(IL_IDX),
                    .NUM_MAC(NUM_MAC)
                ) dsp (
                    .B_i(iData), // This is the image pixel.
                    .A_i(k_temp), // These are the flattened Kernel Values.
                    .C_i(C_j_temp),
                    .oCorrect(O_temp)
            );
            assign oRes[(j*NUM_MAC*OPRES_DWIDTH) +: (NUM_MAC*OPRES_DWIDTH)] = O_temp;
        end
    end
endmodule // dspmac

