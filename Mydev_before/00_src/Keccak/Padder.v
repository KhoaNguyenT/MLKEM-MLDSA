module Padder #(
	//default KECCAK-p[1600, 24], SHA3 - 512
	// parameter b  = 1600,
    // parameter Length = 8,
	parameter Block  = 21,
    parameter lbits = 3
)
(
    input				        iClk,
	input				        iRst,
    input       [1:0]           iMode, // 0 => 512, 1 => 256, 2 => 128
	input						i_SHA, // 0 => SHA, 1 => SHAKE
    input		[63:0]	        iData,
    input				        iReady,
	input				        iLast,
    input		[lbits-1:0]     iByte_num,
    output				        oBuffer_full,	/* to "user" module */
    output                      oBuffer_temp,   /* to "user" module */
    output                      oBuffer_temp_2,
    output		[Block*64-1:0]  oData,		    /* to "f_permutation" module */
    output				        oReady,			/* to "f_permutation" module */
    input				        iF_ack		  	/* from "f_permutation" module */
);

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
 reg [Block*64-1:0]  oData_reg;
 assign oData =   (iMode == 2'b10) ? oData_reg 
 				: (iMode == 2'b01) ? {{((Block-17)*64){1'b0}} , oData_reg[((Block-4)*64-1):0]}
				: (iMode == 2'b00) ? {{((Block-9)*64){1'b0}} , oData_reg[((Block-12)*64-1):0]}
				: oData_reg;
 
 wire [255:0] Data_0, Data_1, Data_2, Data_3;
 wire [63:0] Data_4, DATA_IN;
 assign Data_0 = oData_reg[255:0];
 assign Data_1 = oData_reg[511:256];
 assign Data_2 = oData_reg[767:512];
 assign Data_3 = oData_reg[1023:768];
 assign Data_4 = oData_reg[1087:1024];
 assign DATA_IN = oData_reg[63:0];
 
 reg				state;		/* state == 0: user will send more input data
							 * state == 1: user will not send any data */
 reg				done;		/* == 1: oReady should be 0 */
 reg	[Block-1:0]	i;			/* length of "oData" buffer */
 wire	[63:0]		v0;			/* output of module "padder1" */
 wire	[63:0]		v1;			/* to be shifted into register "oData" */
 //wire				accept;		/* accept user input? */
 wire				update;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
 
//  assign oBuffer_full = (iMode) ? i[16] : i[8];
 assign oBuffer_full = (iMode == 2'b10) ? i[Block-1] 
 					:  (iMode == 2'b01) ? i[Block-5]
					:  (iMode == 2'b00) ? i[Block-13]
					:  i[Block-1];
 assign oBuffer_temp = (iMode == 2'b10) ? i[Block-2] 
 					:  (iMode == 2'b01) ? i[Block-6]
					:  (iMode == 2'b00) ? i[Block-14]
					:  i[Block-2];
 assign oBuffer_temp_2 = (iMode == 2'b10) ? i[Block-3] 
 					:  (iMode == 2'b01) ? i[Block-7]
					:  (iMode == 2'b00) ? i[Block-15]
					:  i[Block-3];
 assign oReady = oBuffer_full;
 
 // if state == 1, do not eat input
 //assign accept = ~state & iReady & ~oBuffer_full;
 // don't fill buffer if done
 assign update = (iReady|state) & ~(oBuffer_full|done);
 
// assign v1 = (state) ? {56'b0, i[7], 7'b0} :
//			 (~iLast) ? iData : {v0[63:8], v0[7]|i[7], v0[6:0]};
 assign v1[63:8] = {(56){~state}} & ((~iLast) ? iData[63:8] : v0[63:8]);
 assign v1[7] = (state) ? 
                ((iMode == 2'b10) ? i[Block-2] : (iMode == 2'b01) ? i[Block-6] : i[Block-14]) : 
                ((~iLast) ? iData[7] : (v0[7]| ((iMode == 2'b10) ? i[Block-2] : (iMode == 2'b01) ? i[Block-6] : i[Block-14]))); //0x80 (1)000_0000 khi iLast hoặc khi đủ Block_pad
                
 assign v1[6:0] = {(7){~state}} & ((~iLast) ? iData[6:0] : v0[6:0]);
			 
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
 always@(posedge iClk) begin
	if (update) begin
		case (iMode)
			2'b10: begin
				oData_reg <= {oData_reg[((Block-1)*64-1):0], v1};
			end
			2'b01: begin
				oData_reg[((Block-4)*64-1):0] <= {oData_reg[((Block-5)*64-1):0], v1};
				oData_reg[(Block*64-1):((Block-4)*64)] <= 0;
			end
			2'b00: begin
				oData_reg[((Block-12)*64-1):0] <= {oData_reg[((Block-13)*64-1):0], v1};
				oData_reg[(Block*64-1):((Block-12)*64)] <= 0;
			end 
			default: oData_reg <= oData_reg;
		endcase
	end
 end
 
 // if (iF_ack)  i <= 0;
 // if (update) i <= {i[7:0], 1'b1};	/* increase length */
 always@(posedge iClk) begin
	if(iRst)				i <= 0;
	else if(iF_ack|update)	begin
		case (iMode)
			2'b10: begin
				i <= {i[Block-2:0], 1'b1} & {(Block){~iF_ack}};
			end
			2'b01: begin
				i[Block-5:0] <= {i[Block-6:0], 1'b1} & {(Block-4){~iF_ack}};
				i[Block-1:Block-4] <= 0;
			end
			2'b00: begin
				i[Block-13:0] <= {i[Block-14:0], 1'b1} & {(Block-12){~iF_ack}};
				i[Block-1:Block-12] <= 0;
			end 
			default: i <= i;
		endcase
	end
 end
 
 always@(posedge iClk) begin
	if(iRst)		state <= 1'b0;
	else if(iLast)	state <= 1'b1;
	else			state <= state;
 end
 
 always@(posedge iClk) begin
	if(iRst)				done <= 1'b0;
	else if(state&oReady)	done <= 1'b1;
	else					done <= done;
 end
 
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
 InEnd p0 (
	.mode       (i_SHA), //0:SHA, 1:SHAKE
	.in			(iData[63:8]),
	.byte_num	(iByte_num),
	.out		(v0)
 );
 
endmodule
