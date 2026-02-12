/*
 * Copyright (c) 2025 Gerardo Laguna-Sanchez
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none


module tt_um_galaguna_sram_tst (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
 
    //signals:
reg [31:0] dataout_stored;
reg cs_int;
wire [31:0] dataout_int;
wire [31:0] dout;
wire cs,we;    
wire [31:0] datain;
wire [7:0] addr;
wire [3:0] write_allow;


always @(posedge clk) begin
    if(!rst_n) begin
        cs_int <= 1;
        dataout_stored <= 0;
    end else begin
        if(cs)
            dataout_stored <= dataout_int;
        cs_int <= cs;
    end
end

    //instantiations:
    
sky130_sram_1kbyte_1rw1r_32x256_8 sram0(
    .clk0(clk),
    .csb0(!cs),
    .web0(!we),
    .wmask0(write_allow),
    .addr0(addr),
    .din0(datain),
    .dout0(dataout_int),

    .clk1(1'b0),
    .csb1(1'b1),
    .addr1(8'b00000000),
    .dout1()
);
    
  // interconnection logic:
	assign cs      = uio_in[0];
	assign we      = uio_in[1];
	assign addr    = 8'b00000000;
	assign write_allow =4'b0001;
    assign datain  = {24'b000000000000000000000000,ui_in};

  //output logic
    assign uio_oe  = 8'b11111100;
	assign uo_out = cs_int ? dataout_int[7:0] : dataout_stored[7:0];
    
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[2], uio_in[3], uio_in[4], uio_in[5], uio_in[6], uio_in[7], 1'b0};

endmodule
    
