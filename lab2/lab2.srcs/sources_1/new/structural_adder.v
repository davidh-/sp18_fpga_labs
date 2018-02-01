module structural_adder (
    input [13:0] A,
    input [13:0] B,
    output [14:0] SUM
);

    wire [14:0] C;
    genvar i;
    generate
        for(i=0; i<14; i=i+1) begin:bit
            full_adder add(.a(A[i]), .b(B[i]), .cin(C[i]), .s(SUM[i]), .cout(C[i+1]));
        end
    endgenerate
    
    assign C[0] = 1'b0;
    assign SUM[14] = C[14];
endmodule
