/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* "iLast" == 0 means byte number is 8, no matter what value "iByte_num" is. */
/* if "iReady" == 0, then "iLast" should be 0. */
/* the user switch to next "iData" only if "ack" == 1. */

module Keccak #(
	/* Standard KECCAK-p[b, nr] 
	b : Bits of permutation 
	nr: Number of round in permutation 
	using KECCAK-p[1600, 24] */
	parameter b  = 1600,
    // parameter Length = 8, 	// SHA3 - 128, 256, 512 (2, 4, 8 * 64 bit)
	parameter Block  = 21,
    parameter lbits = 3 	// KECCAK-p[1600, 24] => l = 6 Lenght of iData Bytes
)
(
	input				   	iClk,
	input				   	iRst,
    input   [1:0]           iMode, 			// 0 => 512, 1 => 256, 2 => 128
    input                   i_SHA, 			// 0 => SHA, 1 => SHAKE
	input	[63:0]	      	iData,
	input				   	iReady,
	input				   	iLast,
	input	[lbits-1:0]		iByte_num,
	input 					iCon_per,
	output				   	oBuffer_full, 	/* to "user" module */
	output                  oBuffer_temp,
	output                  oBuffer_temp_2,
	output				   	f_oAck, 		/* to "user" module */
	output					f_oReady,
	output	[Block*64-1:0]	oData,
	output	reg				oReady
);
	
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
 reg						state;	/* state == 0: user will send more input data
									 * state == 1: user will not send any data */
 reg	[22:0]				i; 		/* gen "oReady" */
 
 wire	[Block*64-1:0]	    padder_oData, f_iData, padder_oData_pre; /* before reorder byte */
 wire						padder_oReady, f_iReady;
// wire						f_oAck, Padder_full;
// assign Padder_full = oBuffer_full & f_oAck;
 
 wire	[Block*64-1:0]		Data_out_pre; /* before reorder byte */
 wire	[Block*64-1:0]		oData_pre;
 assign oData = (~i_SHA) 
 				? ((iMode == 2'b10) ? {{((Block-2)*64){1'b0}} , oData_pre[(Block*64-1):(Block-2)*64]} 
					: (iMode == 2'b01) ? {{((Block-4)*64){1'b0}} , oData_pre[(Block*64-1):(Block-4)*64]}
					: (iMode == 2'b00) ? {{((Block-8)*64){1'b0}} , oData_pre[(Block*64-1):(Block-8)*64]}
					: oData_pre)
				:((iMode == 2'b10) ? oData_pre 
					: (iMode == 2'b01) ? {{((Block-17)*64){1'b0}} , oData_pre[(Block*64-1):(Block-17)*64]}
					: (iMode == 2'b00) ? {{((Block-9)*64){1'b0}} , oData_pre[(Block*64-1):(Block-9)*64]}
					: oData_pre);
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
 genvar ibyte;
 generate
  for (ibyte = 0; ibyte < Block; ibyte = ibyte + 1) begin : reverse_bytes
    assign oData_pre[ibyte*64 +: 64] = {
        Data_out_pre[ibyte*64 +: 8],          // byte 0 -> th�nh byte 7
        Data_out_pre[ibyte*64+8 +: 8],
        Data_out_pre[ibyte*64+16 +: 8],
        Data_out_pre[ibyte*64+24 +: 8],
        Data_out_pre[ibyte*64+32 +: 8],
        Data_out_pre[ibyte*64+40 +: 8],
        Data_out_pre[ibyte*64+48 +: 8],
        Data_out_pre[ibyte*64+56 +: 8]        // byte 7 -> th�nh byte 0
    };
  end
endgenerate
//genvar ibyte;
generate
  for (ibyte = 0; ibyte < Block; ibyte = ibyte + 1) begin : reverse_bytes_per
    assign padder_oData[ibyte*64 +: 64] = {
        padder_oData_pre[ibyte*64 +: 8],          // byte 0 -> th�nh byte 7
        padder_oData_pre[ibyte*64+8 +: 8],
        padder_oData_pre[ibyte*64+16 +: 8],
        padder_oData_pre[ibyte*64+24 +: 8],
        padder_oData_pre[ibyte*64+32 +: 8],
        padder_oData_pre[ibyte*64+40 +: 8],
        padder_oData_pre[ibyte*64+48 +: 8],
        padder_oData_pre[ibyte*64+56 +: 8]        // byte 7 -> th�nh byte 0
    };
  end
endgenerate
//SHAKE
assign f_iData  = (iCon_per) ? 0 : padder_oData;
assign f_iReady = (f_oReady & iCon_per) | padder_oReady;
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
 always@(posedge iClk) begin
	if(iRst)			i <= 23'b0;
	// else if(iCon_per)	i <= 23'b0;
	else				i <= {i[21:0], state & f_oAck};
 end

 always@(posedge iClk) begin
	if(iRst)		state <= 1'b0;
	else if(iLast)	state <= 1'b1;
	else			state <= state;
 end

 always@(posedge iClk) begin
	if(iRst)			oReady <= 1'b0;
	else if(i[22])		oReady <= 1'b1;
	else if(iCon_per)	oReady <= 1'b0;
	else				oReady <= oReady;
 end
 
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
 Padder #(
	// .b(b),
	// .Length(Length),
	.lbits(lbits)
 ) padder_ (
	.iClk			(iClk),
	.iRst			(iRst),
	.iMode          (iMode),
	.i_SHA			(i_SHA),
	.iData			(iData),
	.iReady			(iReady),
	.iLast			(iLast),
	.iByte_num		(iByte_num),
	.oBuffer_full	(oBuffer_full),
	.oBuffer_temp   (oBuffer_temp),
	.oBuffer_temp_2 (oBuffer_temp_2),
	.oData			(padder_oData_pre),
	.oReady			(padder_oReady),
	.iF_ack			(f_oAck)
 );

 F_permutation #(
	.b(b),
	// .Length(Length),
	.Block(Block)
 ) f_permutation_ (
	.iClk		(iClk),
	.iRst		(iRst),
	.iMode      (iMode),
	.iData		(f_iData),
	.iReady		(f_iReady),
	.oAck		(f_oAck),
	.oData		(Data_out_pre),
	.oReady	    (f_oReady)
 );

endmodule
