module full_adder (
    input a,
    input b,
    input cin,
    output s,
    output cout
);
    // Insert your RTL here to calculate the sum and carry out bits
    // Remove these assign statements once you write your own RTL
    xor(s, a, b, cin);
    
    wire xor_a_b;
    wire cin_and;
    wire and_a_b;
    
    xor(xor_a_b, a, b);
    and(cin_and, cin, xor_a_b);
    and(and_a_b, a, b);
    or(cout, and_a_b, cin_and);
endmodule
