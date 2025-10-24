module top (
    input clk,
    input resetn,

    input  mem_valid,
    input  mem_instr,
    output mem_ready,

    input  [31:0] mem_addr,
    input  [31:0] mem_wdata,
    input  [31:0] mem_wstrb,
    output [31:0] mem_rdata,

    output oc_sel
);

  parameter [0:0] BARREL_SHIFTER = 0;
  parameter [0:0] ENABLE_MUL = 0;
  parameter [0:0] ENABLE_DIV = 0;
  parameter [0:0] ENABLE_FAST_MUL = 0;
  parameter [0:0] ENABLE_IRQ_QREGS = 0;

  parameter integer MEM_WORDS = 8192;  // 32K
  parameter [31:0] STACKADDR = (4 * MEM_WORDS);
  parameter [31:0] PROGADDR_RESET = 32'h0000_0000;
  parameter [31:0] PROGADDR_IRQ = 32'h0000_0000;


  wire mem_valid;
  wire mem_instr;
  wire mem_ready;
  wire [31:0] mem_addr;
  wire [31:0] mem_wdata;
  wire [31:0] mem_wstrb;
  wire [31:0] mem_rdata;

  wire ocram_sel;
  wire ocram_ready;
  wire [31:0] ocram_data_o;

  wire leds_sel;
  wire leds_ready;
  wire [31:0] leds_data_o;

  wire uart_sel;
  wire uart_ready;
  wire [31:0] uart_data_o;

  // Memory Map
  // On-Chip Ram  0x0000_0000 - 0x0000_7FFF   (32K)
  // SRAM         0x0800_0000 - 0x087F_FFFF   (8MB)
  // LED          0x1000_0000
  // UART READ    0x1000_0008                 
  // UART WRITE   0x1000_000C

  assign ocram_sel = mem_valid && (mem_addr < 32'h0000_8000);
  assign sram_sel  = mem_valid && (mem_addr < 32'h8000_2000);
  assign leds_sel  = mem_valid && (mem_addr == 32'h1000_0000);
  assign uart_sel  = mem_valid && ((mem_addr & 32'hFFFF_FFF8) == 32'h1000_0008);

  assign mem_ready = (mem_valid & (ocram_ready | sram_ready | leds_ready | uart_ready));

  picorv32 #(
      .STACKADDR(STACKADDR),
      .PROGADDR_RESET(PROGADDR_RESET),
      .PROGADDR_IRQ(PROGADDR_IRQ),
      .BARREL_SHIFTER(BARREL_SHIFTER),
      .ENABLE_MUL(ENABLE_MUL),
      .ENABLE_DIV(ENABLE_DIV),
      .ENABLE_FAST_MUL(ENABLE_FAST_MUL),
      .ENABLE_DIV(ENABLE_DIV),
      .ENABLE_IRQ_QREGS(ENABLE_IRQ_QREGS)
  ) cpu (
      .clk(clk),
      .resetn(resetn),
      .mem_valid(mem_valid),
      .mem_instr(mem_instr),
      .mem_ready(mem_ready),
      .mem_addr(mem_addr),
      .mem_wdata(mem_wdata),
      .mem_wstrb(mem_wstrb),
      .mem_rdata(mem_rdata)
  );

  ocram_32k ocram (
      // TODO: Map CPU bus signals onto A and B
      .clock(clk),
      .q_a  (ocram_data_o_instr),
      .q_b  (ocram_data_o_data)
  );


endmodule
