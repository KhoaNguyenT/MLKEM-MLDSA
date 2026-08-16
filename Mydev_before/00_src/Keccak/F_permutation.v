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

/* if "oAck" is 1, then current input has been used. */

module F_permutation #(
	parameter b  = 1600,
    // parameter Length = 8, 	// SHA3 - 512 (8 Bytes)
	parameter Block  = 21
)
(
	input						iClk,
	input						iRst,
    input       [1:0]           iMode, // 0 => 512, 1 => 256, 2 => 128
	input		[Block*64-1:0]	iData,
	input						iReady,
	output						oAck,
	output		[Block*64-1:0]	oData,
	output	reg					oReady
);

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
 
 reg	[22:0]	i; /* select round constant */
 reg	[b-1:0]	round;
 wire	[b-1:0]	round_in, round_out;
 wire	[6:0]	rc;
 wire			update;
 wire			accept;
 
 reg			calc; /* == 1: calculating rounds */

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

 assign accept = iReady & ~calc;	//iReady & (i==0)
 assign round_in = 	(accept) ? 
							((iMode == 2'b10) ? {iData[b-1-(Block-17)*64:0]^round[b-1:(Block-17)*64], round[(Block-17)*64-1:0]} 
							:(iMode == 2'b01) ? {iData[b-1-(Block-13)*64:0]^round[b-1:(Block-13)*64], round[(Block-13)*64-1:0]} 
							: {iData[b-1-(Block-5)*64:0]^round[b-1:(Block-5)*64], round[(Block-5)*64-1:0]}) 
					: round;
 
 assign update = calc | accept;
 assign oAck = accept;
//  assign oData = (iMode) ? {round[b-1:b-4*64], 256'b0} : round[b-1:b-8*64];
assign oData = round[b-1:b-Block*64];
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
 always@(posedge iClk) begin
	if(iRst)	i <= 23'b0;
	else		i <= {i[21:0], accept};
 end
 
 always@(posedge iClk) begin
	if(iRst)	calc <= 1'b0;
	else		calc <= (calc & ~i[22]) | accept;
 end

 always@(posedge iClk) begin
	if(iRst | accept)	oReady <= 1'b0;
	// only change at the last round
	else if(i[22])		oReady <= 1'b1;
	else				oReady <= oReady;
 end

 always@(posedge iClk) begin
	if(iRst)		round <= {b{1'b0}};
	else if(update)	round <= round_out;
	else			round <= round_in;
 end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
 rconst2in1 rconst_ (
	.i		({i, accept}),
	.rc  	(rc)
 );

 round2in1 round_ (
	.in		(round_in),
	.rc 	(rc),
	.out	(round_out)
 );

endmodule
