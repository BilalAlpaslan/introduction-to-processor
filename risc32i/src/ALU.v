module ALU(
    input [31:0] X,
    input [31:0] Y,
    input [3:0] OP,

    output reg [31:0] RESULT,
    output isEqual
);

    wire signed [31:0] X_signed = X; // why we need signed version?
    wire signed [31:0] Y_signed = Y;

    assign isEqual = X == Y;

    always @(*) begin
        case (OP)
            0: RESULT <= X + Y;
            1: RESULT <= X - Y;
            2: RESULT <= X & Y;
            3: RESULT <= X | Y;
            4: RESULT <= X ^ Y;
            5: RESULT <= X << Y;
            6: RESULT <= X >> Y;
            7: RESULT <= X_signed >>> Y;
            8: RESULT <= (X_signed < Y_signed ? 1 : 0);
            9: RESULT <= (X < Y ? 1 : 0);
        endcase
    end

endmodule