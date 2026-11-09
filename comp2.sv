module comp2 #(
    parameter DWIDTH = 10
)(
    input [DWIDTH-1:0] din,
    output logic [DWIDTH-1:0] dout
);

    assign dout = ~din + 1'b1;

endmodule // comp2