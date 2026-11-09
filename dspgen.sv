// Code your design here
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/05/2025 10:30:51 AM
// Design Name:
// Module Name: mac_generic
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module dspgen #(
    parameter I_DWIDTH = 4,
    parameter K_DWIDTH = 4,
    parameter IL_IDX = 2,
   	parameter NUM_MAC = 1
)(
    input logic signed [I_DWIDTH - 1 : 0] B_i, // This is the image pixel.
    input logic signed [NUM_MAC * K_DWIDTH - 1 : 0] A_i, // These are the flattened Kernel Values.
    input logic signed [`DSP_ACC_DWIDTH-1 : 0] C_i,

    output logic signed [(NUM_MAC * (K_DWIDTH + I_DWIDTH + IL_IDX + 1))-1:0] oCorrect
);

    localparam DSP_OP1_DWIDTH = `DSP_OP1_DWIDTH;
    localparam DSP_OP2_DWIDTH = `DSP_OP2_DWIDTH;
    localparam DSP_ACC_DWIDTH = `DSP_ACC_DWIDTH;
    localparam PRES_DWIDTH = I_DWIDTH + K_DWIDTH + IL_IDX;
    localparam GUARD_BITS = I_DWIDTH + IL_IDX + 2;
    localparam EXTRA_ZEROS = DSP_OP1_DWIDTH - ((NUM_MAC * (K_DWIDTH - 1)) + ((NUM_MAC - 1) * GUARD_BITS));


    logic [DSP_OP1_DWIDTH-1 : 0] A;
    logic [DSP_OP2_DWIDTH-1 : 0] B;
    logic [DSP_ACC_DWIDTH-1 : 0] C_to_DSP;

    logic [I_DWIDTH-1:0] B_i_temp;
    logic [I_DWIDTH-2:0] B_i_temp_out;
    logic [I_DWIDTH - 2 : 0] B_temp;

    logic [DSP_ACC_DWIDTH-1 : 0] Out_temp;
    logic signI;  // Need to see if we need to take 2s complimenent of image or not.
    logic [I_DWIDTH - 1 : 0] B_comparator;
    logic B_assign_sel;

    logic [NUM_MAC-1 : 0]mulSign;
    logic [NUM_MAC-1 : 0]prevResSign;


    // Now we need to unflatten the Kernel Values and assign them correctly to the DSP operator A

    for (genvar i = 0 ; i < NUM_MAC ; i = i + 1) begin : gen_data

        // VERIFY THIS ASSIGNMENT ONCE MANUALLY !!! (CHECKED)
        // During assignment first check the sign. Then assign accordingly
        logic [K_DWIDTH-1 : 0] A_temp;
        logic [K_DWIDTH-2 : 0] A_temp_out;
        logic [K_DWIDTH-2 : 0] A_data;
        localparam int ZERO_BITS = (i == NUM_MAC - 1) ? EXTRA_ZEROS : GUARD_BITS;

        assign A_temp = A_i[i*K_DWIDTH +: K_DWIDTH];
        comp2 #(.DWIDTH(K_DWIDTH-1)) instA(.din(A_temp[K_DWIDTH-2:0]), .dout(A_temp_out));
        assign A_data = A_temp[K_DWIDTH-1] ? A_temp_out : A_temp[K_DWIDTH-2:0];
        assign A[i * (K_DWIDTH - 1 + GUARD_BITS) +: (K_DWIDTH - 1 + ZERO_BITS)] = {{ZERO_BITS{1'b0}},A_data};
    end


    //  Now is the B operator assignment. This will be same as the previous case which me and Rohit did. (CHECKED)
    assign B_i_temp = B_i;
    assign signI = B_i_temp[I_DWIDTH-1];
    comp2 #(.DWIDTH(I_DWIDTH-1)) instB (.din(B_i_temp[I_DWIDTH-2:0]), .dout(B_i_temp_out));
    assign B_temp = signI ? B_i_temp_out : B_i_temp[I_DWIDTH-2 : 0];
    assign B = {{(DSP_OP2_DWIDTH - I_DWIDTH + 1){1'b0}}, B_temp};

    for (genvar j = 0; j < NUM_MAC; j = j+1) begin : C_assignment_block

        logic signA;
        logic [PRES_DWIDTH : 0] C_temp;
        logic [PRES_DWIDTH : 0] C_comp_temp;
        logic [PRES_DWIDTH-1:0] C_comp_temp_out;

        assign C_comp_temp = C_i[(j*(PRES_DWIDTH+1)) +: (PRES_DWIDTH+1)];
        comp2 #(.DWIDTH(PRES_DWIDTH)) instC(.din(C_comp_temp[PRES_DWIDTH-1 : 0]), .dout(C_comp_temp_out));

        assign signA = A_i[(j + 1)*(K_DWIDTH) - 1];
        assign mulSign[j] = signA ^ signI;
        assign prevResSign[j] = C_comp_temp[PRES_DWIDTH - 1];
        assign C_temp = mulSign[j] ? {C_comp_temp[(j+1)*(PRES_DWIDTH+1)-1],C_comp_temp_out} : C_comp_temp; /// ---> changed
        if (j < (NUM_MAC-1))
            assign C_to_DSP[(j*(PRES_DWIDTH+1)) +: (PRES_DWIDTH+1)] = C_temp;
        else begin
            // This handles the final accumulation because every DSP sees 48 bit C_i as a signed number
            assign C_to_DSP[(j*(PRES_DWIDTH+1)) +: (PRES_DWIDTH+1)] = C_temp;
            assign C_to_DSP[((j+1)*(PRES_DWIDTH+1)) +: (DSP_ACC_DWIDTH - (((j+1)*(PRES_DWIDTH+1))))] = {(DSP_ACC_DWIDTH - (((j+1)*(PRES_DWIDTH+1)))){1'b0}};
        end
    end


    dsp48e2inst dspint ( .A(A), .B(B), .C(C_to_DSP), .P(Out_temp));


    for(genvar k = 0; k < NUM_MAC; k= k+1) begin

        logic [PRES_DWIDTH : 0] C_comp_outWithoutSign;
        logic [PRES_DWIDTH : 0] C_comp_outWithSign;
        logic [PRES_DWIDTH : 0] C_temp_out;
        logic [PRES_DWIDTH : 0] C_temp_out_1;
        localparam int ZERO_EXT_BITS = (k == NUM_MAC - 1) ? (DSP_ACC_DWIDTH - ((k+1) * ((PRES_DWIDTH) + 1)))  : 1;
        assign C_temp_out_1 = Out_temp[k*(PRES_DWIDTH+1) +: (PRES_DWIDTH+1)];


        comp2 #(.DWIDTH(PRES_DWIDTH+1)) instOutWithoutSign (.din(C_temp_out_1), .dout(C_comp_outWithoutSign));
        comp2 #(.DWIDTH(PRES_DWIDTH+1)) instOutWithSign (.din({C_temp_out_1[PRES_DWIDTH - 1], C_temp_out_1[PRES_DWIDTH - 1 : 0]}), .dout(C_comp_outWithSign));
//        logic [PRES_DWIDTH : 0] C_comp_out_sign1;
//        logic [PRES_DWIDTH : 0] C_temp_out_sign1;
//        logic [PRES_DWIDTH : 0] C_temp_out_1_sign1;

//        assign C_temp_out_1_sign1 = Out_temp[k*(PRES_DWIDTH+1) +: (PRES_DWIDTH+1)];


//        comp2 #(.DWIDTH(PRES_DWIDTH)) instOut_sign1 (.din(C_comp_out_sign1), .dout(C_temp_out_1_sign1));

//        assign C_temp_out = (mulSign[k]) ? {C_comp_out[PRES_DWIDTH-1], C_comp_out[PRES_DWIDTH-1:0]} : {C_temp_out_1[PRES_DWIDTH-1], C_temp_out_1[PRES_DWIDTH-1:0]};
        assign C_temp_out = !(mulSign[k] ^ prevResSign[k]) ? ((mulSign[k]) ? C_comp_outWithoutSign : C_temp_out_1) : ((mulSign[k]) ? C_comp_outWithSign : {C_temp_out_1[PRES_DWIDTH - 1], C_temp_out_1[PRES_DWIDTH - 1 : 0]}) ;
        assign oCorrect[k*(PRES_DWIDTH+1) +: (PRES_DWIDTH + 1)] = C_temp_out;
    end
endmodule
