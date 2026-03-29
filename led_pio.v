// 10 LED's
module led_pio (
    input wire clk,
    input wire resetn,

    input wire led_sel,
    input wire [31:0] mem_wdata,
    input wire [3:0] mem_wstrb,

    output wire [9:0] ledg
);

  reg [31:0] ledr = 32'h0;

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      ledr <= 32'h0;
    end else if (led_sel && (|mem_wstrb)) begin
      ledr <= mem_wdata;
    end
  end

  assign ledg = ledr[9:0];

endmodule
