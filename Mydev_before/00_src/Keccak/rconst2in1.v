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

/* round constant (2 in 1 ~ ~) */
module rconst2in1(
	input	[23:0]	i,
	output	[6:0]	rc
);

 wire [6:0] rc1, rc2;
 assign rc = (i[0] | i[2] | i[4] | i[6] | i[8] | i[10] | i[12] | i[14] | i[16] | i[18] | i[20] | i[22]) ? rc1 : rc2;
 
 assign rc1[6] = i[2] | i[6]  | i[14] | i[16] | i[20];
 assign rc1[5] = i[6] | i[10] | i[12] | i[20] | i[22];
 assign rc1[4] = i[2] | i[4]  | i[6]  | i[10] | i[12] | i[14] | i[16] | i[18] | i[20];
 assign rc1[3] = i[2] | i[4]  | i[6]  | i[8]  | i[12] | i[14] | i[20];
 assign rc1[2] = i[2] | i[4]  | i[8]  | i[10] | i[12] | i[14] | i[18];
 assign rc1[1] = i[2] | i[4]  | i[8]  | i[12] | i[16] | i[18];
 assign rc1[0] = i[0] | i[4]  | i[6]  | i[10] | i[12] | i[14] | i[20] | i[22];
 
 assign rc2[6] = i[3] | i[7]  | i[13] | i[15] | i[17] | i[19] | i[21] | i[23];
 assign rc2[5] = i[3] | i[5]  | i[11] | i[19] | i[23];
 assign rc2[4] = i[1] | i[3]  | i[7]  | i[15] | i[21] | i[23];
 assign rc2[3] = i[1] | i[9]  | i[13] | i[17] | i[21];
 assign rc2[2] = i[7] | i[9]  | i[11] | i[13] | i[19] | i[23];
 assign rc2[1] = i[1] | i[11] | i[13] | i[15] | i[19];
 assign rc2[0] = i[5] | i[7]  | i[13] | i[15];
 
endmodule
