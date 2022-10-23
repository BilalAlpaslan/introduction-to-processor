// module N_encoder #(
   TODO: one encoder module for all size
// )


module Encoder_4 (
    input [3:0] in,
    output reg [1:0] out
  );
  initial begin
    out <= 0;
  end

  always @(in) begin
    case (in)
      4'b1xxx : out = 3;
      4'b01xx : out = 2;
      4'b001x : out = 1;
      4'b0001 : out = 0;
      4'b0000 : out = 0;
    endcase
  end
endmodule