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

module InEnd(
	input			mode,
	input	[55:0]	in,
	input	[2:0]	byte_num,
	output	[63:0]	out
);
/*
 case (byte_num)
	0: out =             64'h1F00000000000000;
	1: out = {in[63:56], 56'h1F000000000000};
	2: out = {in[63:48], 48'h1F0000000000};
	3: out = {in[63:40], 40'h1F00000000};
	4: out = {in[63:32], 32'h1F000000};
	5: out = {in[63:24], 24'h1F0000};
	6: out = {in[63:16], 16'h1F00};
	7: out = {in[63:8],   8'h1F};
 endcase
*/
 wire [63:0] out_SHA, out_SHAKE;

 assign out_SHAKE[63:56] = 	(byte_num == 3'd0) ? 8'h1F : in[55:48];
 assign out_SHAKE[55:48] = 	(byte_num < 3'd1)  ? 8'h00 :
					 		(byte_num == 3'd1) ? 8'h1F : in[47:40];
 assign out_SHAKE[47:40] = 	(byte_num < 3'd2)  ? 8'h00 :
					 		(byte_num == 3'd2) ? 8'h1F : in[39:32];
 assign out_SHAKE[39:32] = 	(byte_num < 3'd3)  ? 8'h00 :
					 		(byte_num == 3'd3) ? 8'h1F : in[31:24];
 assign out_SHAKE[31:24] = 	(byte_num < 3'd4)  ? 8'h00 :
					 		(byte_num == 3'd4) ? 8'h1F : in[23:16];
 assign out_SHAKE[23:16] = 	(byte_num < 3'd5)  ? 8'h00 :
					 		(byte_num == 3'd5) ? 8'h1F : in[15:8];
 assign out_SHAKE[15:8]  = 	(byte_num < 3'd6)  ? 8'h00 :
					 		(byte_num == 3'd6) ? 8'h1F : in[7:0];
 assign out_SHAKE[7:0]   = 	(byte_num < 3'd7)  ? 8'h00 : 8'h1F;

 assign out_SHA[63:56] = 	(byte_num == 3'd0) ? 8'h06 : in[55:48];
 assign out_SHA[55:48] = 	(byte_num < 3'd1)  ? 8'h00 :
					 		(byte_num == 3'd1) ? 8'h06 : in[47:40];
 assign out_SHA[47:40] = 	(byte_num < 3'd2)  ? 8'h00 :
					 		(byte_num == 3'd2) ? 8'h06 : in[39:32];
 assign out_SHA[39:32] = 	(byte_num < 3'd3)  ? 8'h00 :
					 		(byte_num == 3'd3) ? 8'h06 : in[31:24];
 assign out_SHA[31:24] = 	(byte_num < 3'd4)  ? 8'h00 :
					 		(byte_num == 3'd4) ? 8'h06 : in[23:16];
 assign out_SHA[23:16] = 	(byte_num < 3'd5)  ? 8'h00 :
					 		(byte_num == 3'd5) ? 8'h06 : in[15:8];
 assign out_SHA[15:8]  = 	(byte_num < 3'd6)  ? 8'h00 :
					 		(byte_num == 3'd6) ? 8'h06 : in[7:0];
 assign out_SHA[7:0]   = 	(byte_num < 3'd7)  ? 8'h00 : 8'h06;

 assign out = (~mode) ? out_SHA : out_SHAKE;
endmodule
