`include "airi5c_hasti_constants.vh"

module airi5c_nexys4_ddr_7seg_display 
#(
  parameter BASE_ADDR = 32'hC0000900,
  parameter SCAN_FREQ = 60
)    
(
  // system clk and reset
  input     nreset,
  input     clk,

  // 7-segment display outputs
  output [7:0]  data,
  output [7:0]  scan,

  // system bus 
  input [`HASTI_ADDR_WIDTH-1:0]      haddr,
  input                              hwrite,     // unused, as imem is read-only (typically)
  input [`HASTI_SIZE_WIDTH-1:0]      hsize,
  input [`HASTI_BURST_WIDTH-1:0]     hburst,
  input                              hmastlock,
  input [`HASTI_PROT_WIDTH-1:0]      hprot,
  input [`HASTI_TRANS_WIDTH-1:0]     htrans,
  input [`HASTI_BUS_WIDTH-1:0]       hwdata,      // unused, as imem is read-only (typically)
  output  reg [`HASTI_BUS_WIDTH-1:0] hrdata,
  output                             hready,
  output    [`HASTI_RESP_WIDTH-1:0]  hresp
);

// Determine scan clock period length = sysclk/(8 display positions * 256 brightness levels * scan frequency)
localparam SCAN_TICKS = `SYS_CLK_HZ/(8*256*SCAN_FREQ);

reg [`HASTI_ADDR_WIDTH-1:0] haddr_r;
reg                         hwrite_r;

// Left and right 7-segment display groups
reg [31:0]  disp_l;
reg [31:0]  disp_r;
reg [31:0]  bright_l;
reg [31:0]  bright_r;

// Display enable
reg         disp_en;

always @(posedge clk, negedge nreset) begin
  if(~nreset)
    haddr_r <= 0;
  else 
    haddr_r <= haddr;   
end

always @(posedge clk, negedge nreset) begin
  if(~nreset)
    hwrite_r <= 0;
  else 
    hwrite_r <= hwrite;
end

always @(posedge clk, negedge nreset) begin
  if(~nreset) begin
    hrdata   <= 0;
    disp_l   <= 0;
    disp_r   <= 0; 
    bright_l <= 0;
    bright_r <= 0;
    disp_en  <= 0;
  end else begin
    if(hwrite_r) begin
      case(haddr_r) 
        (BASE_ADDR)   : disp_l <= hwdata[31:0];
        (BASE_ADDR+4) : disp_r <= hwdata[31:0];
        (BASE_ADDR+8) : bright_l <= hwdata[31:0];
        (BASE_ADDR+12): bright_r <= hwdata[31:0];
        (BASE_ADDR+16): disp_en <= hwdata[0];
        default       : ;
      endcase 
    end

    if(|htrans) begin
      case(haddr)
        (BASE_ADDR)   : hrdata <= disp_l;
        (BASE_ADDR+4) : hrdata <= disp_r;
        (BASE_ADDR+8) : hrdata <= bright_l;
        (BASE_ADDR+12): hrdata <= bright_r;
        default       : hrdata <= 32'hffffffff;
      endcase
    end
  end
end

// the core complex peripherals will always 
// handle read/writes in one cycle, so they will 
// never issue wait cycles. Hence hready is always 1'b1
assign hready = 1'b1;
assign hresp = 0;

reg [15:0]  clkcounter;
reg [10:0]  scancounter;
wire        scancounter_en;
reg [7:0]   char;
reg [7:0]   pos;
reg [7:0]   bright;


always @(posedge clk, negedge nreset)
    if (~nreset) begin
        clkcounter <= 0;
    end else if (disp_en)
        if (scancounter_en)
            clkcounter <= 0;
        else
            clkcounter = clkcounter + 1; 
        
assign scancounter_en = (clkcounter == SCAN_TICKS);  

always @(posedge clk, negedge nreset)
    if (~nreset)
        scancounter <= 0;
    else if (scancounter_en)
        scancounter <= scancounter + 1;
    
 always @*
    case (scancounter[10:8])
        3'b000:     begin char = disp_r[7:0];   bright = bright_r[7:0];   pos = 8'b1111_1110; end
        3'b001:     begin char = disp_r[15:8];  bright = bright_r[15:8];  pos = 8'b1111_1101; end
        3'b010:     begin char = disp_r[23:16]; bright = bright_r[23:16]; pos = 8'b1111_1011; end
        3'b011:     begin char = disp_r[31:24]; bright = bright_r[31:24]; pos = 8'b1111_0111; end
        3'b100:     begin char = disp_l[7:0];   bright = bright_l[7:0];   pos = 8'b1110_1111; end
        3'b101:     begin char = disp_l[15:8];  bright = bright_l[15:8];  pos = 8'b1101_1111; end
        3'b110:     begin char = disp_l[23:16]; bright = bright_l[23:16]; pos = 8'b1011_1111; end
        3'b111:     begin char = disp_l[31:24]; bright = bright_l[31:24]; pos = 8'b0111_1111; end
        default:    ;
    endcase

assign scan = disp_en ? pos : 8'hff;
assign data = scancounter[7:0] < bright ? ~char : 8'hff;

endmodule
