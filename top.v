module top (
    input clk,
    input resetn,

    output wire [9:0] ledg
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
  wire [3:0] mem_wstrb;
  wire [31:0] mem_rdata;

  wire [31:0] ocram_data_o_instr;
  wire [31:0] ocram_data_o_data;

  wire sram_ready;

  wire leds_sel;
  wire leds_ready;
  wire [31:0] leds_data_o;

  wire uart_sel;
  wire uart_ready;
  wire [31:0] uart_data_o;

  // Memory Map
  // On-Chip Ram  0x0000_0000 - 0x0000_7FFF   (32K)
  // SRAM         0x0800_0000 - 0x087F_FFFF   (8MB) (TODO: Implement this...)
  // LED          0x1000_0000
  // UART READ    0x1000_0008       TODO: Implement Simple UART
  // UART WRITE   0x1000_000C

  assign sram_sel   = mem_valid && (mem_addr >= 32'h0800_0000 && mem_addr < 32'h0880_0000);
  assign leds_sel   = mem_valid && (mem_addr == 32'h1000_0000);
  assign uart_sel   = mem_valid && ((mem_addr & 32'hFFFF_FFF8) == 32'h1000_0008);

  assign sram_ready = 0;
  assign leds_ready = leds_sel;
  assign uart_ready = 0;
  assign mem_ready  = (mem_valid & (ocram_ready | sram_ready | leds_ready | uart_ready));

  picorv32 #(
      .STACKADDR(STACKADDR),
      .PROGADDR_RESET(PROGADDR_RESET),
      .PROGADDR_IRQ(PROGADDR_IRQ),
      .BARREL_SHIFTER(BARREL_SHIFTER),
      .ENABLE_MUL(ENABLE_MUL),
      .ENABLE_DIV(ENABLE_DIV),
      .ENABLE_FAST_MUL(ENABLE_FAST_MUL),
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

  /* Block Ram Signals */
  wire [12:0] address_a;
  wire [12:0] address_b;
  wire [3:0] byteena_a = 4'b1111;  // Instruction read always 32 bits
  wire [3:0] byteena_b;
  wire [31:0] data_a = 32'h0;  // "Tie Off" Port A writes
  // wire [31:0] data_b;
  wire rden_a;
  wire rden_b;
  wire wren_a = 1'b0;  // Instructions read only!
  wire wren_b;
  wire [31:0] q_a;
  wire [31:0] q_b;

  wire ocram_sel;
  wire ocram_ready;

  assign ocram_sel = mem_valid && (mem_addr < 32'h0000_8000);
  assign ocram_ready = ocram_sel;

  assign rden_a = ocram_sel && mem_instr;
  assign address_a = mem_addr[12:0];

  assign rden_b = ocram_sel && !mem_instr && !(|mem_wstrb);
  assign wren_b = ocram_sel && (|mem_wstrb);
  assign byteena_b = rden_b ? 4'b1111 : mem_wstrb;
  assign address_b = mem_addr[12:0];

  // "On Chip" Dual Port Block RAM.
  // Port A: Instruction Fetch
  // Port B: Read / Write Data
  ocram_32k ocram (
      .address_a(address_a),
      .address_b(address_b),
      .byteena_a(byteena_a),
      .byteena_b(byteena_b),
      .clock(clk),
      .data_a(data_a),
      .data_b(mem_wdata),
      .rden_a(rden_a),
      .rden_b(rden_b),
      .wren_a(wren_a),
      .wren_b(wren_b),
      .q_a(ocram_data_o_instr),
      .q_b(ocram_data_o_data)
  );

  wire [31:0] ocram_rdata = mem_instr ? ocram_data_o_instr : ocram_data_o_data;

  led_pio led_inst (
      .clk(clk),
      .resetn(resetn),
      .led_sel(leds_sel),
      .mem_wdata(mem_wdata),
      .mem_wstrb(mem_wstrb),
      .ledg(ledg)
  );

  assign mem_rdata =
      ocram_sel ? ocram_rdata :
      uart_sel ? uart_data_o :
      leds_sel ? leds_data_o :
      32'hFFFFFFFF;

endmodule
