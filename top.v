module top (
      
);

parameter [0:0]         BARREL_SHIFTER  = 0;
parameter [0:0]         ENABLE_MUL      = 0;
parameter [0:0]         ENABLE_DIV      = 0;
parameter [0:0]         ENABLE_FAST_MUL = 0;
parameter [0:0]         ENABLE_DIV      = 0;
parameter [0:0]         ENABLE_IRQ_QREGS = 0;

parameter integer       MEM_WORDS       = 8192; // 32K
parameter [31:0]        STACKADDR       = (4 * MEM_WORDS);
parameter [31:0]        PROGADDR_RESET  = 32'h0000_0000;
parameter [31:0]        PROGADDR_IRQ  = 32'h0000_0000;

wire mem_valid;
wire mem_instr;
wire mem_ready;
wire[31:0] mem_addr;
wire[31:0] mem_wdata;
wire[31:0] mem_wstrb;
wire[31:0] mem_rdata;

// Memory Map
// On-Chip Ram  0x0000_0000 - 0x0000_7FFF   (32K)
// SRAM         0x0800_0000 - 0x087F_FFFF   (8MB)
// 

assign oc_sel   = mem_valid && (mem_addr < 32'h0000_8000);
assign sram_sel = mem_valid && (mem_addr < 32'h8000_2000);
assign led_sel = mem_valid && (mem_addr == 32'h8000_0000);
assign uart_sel = mem_valid && (mem_addr & 32'hfffffff8) == 32'h8000_0008;

