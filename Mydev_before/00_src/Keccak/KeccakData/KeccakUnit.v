module KeccakUnit (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                ena_i,

    input   wire    [1:0]       mode_i, // 0 => 512, 1 => 256, 2 => 128
    input   wire                SHA_i,  // 0 => SHA, 1 => SHAKE
    input   wire    [255:0]     data_i, 
    input   wire                valid_i,
    input   wire    [7:0]       ldata_i, 
    input   wire                last_i,
    input   wire                lmode_i, // 1 => data_i + ldata, 0 => thì thôi
    
    output  wire                next_o,
    output  wire                f_oReady,
    output  wire    [1343:0]    oData,
    output  wire                oReady
);
    

/*****************************************************************************
*                 Internal Wires and Registers Declarations                 *
*****************************************************************************/

    reg     [7:0]   ldata_i_reg;


    // Data to Keccak
    wire    [63:0]  data_o;
    wire            valid_o;
    // Keccak to Data
    wire            oBuffer_full, oBuffer_temp, oBuffer_temp_2;
    wire            f_oAck;

    // Data to LData
    wire            last_o;

    // LData to Keccak
    wire            last_hash_o;
    wire    [2:0]   lnum_hash_o;
    wire    [63:0]  last_Block_o;
    wire    [63:0]  data_keccak;
/*****************************************************************************
*                            Combinational Logic                            *
*****************************************************************************/

    assign  data_keccak = (last_hash_o) ? last_Block_o : data_o;

/*****************************************************************************
*                             Sequential Logic                              *
*****************************************************************************/

    always @(posedge clk_i) begin
        if (rst_i) begin
            ldata_i_reg <= 0;
        end
        else begin
            if (last_i) begin
                ldata_i_reg <= ldata_i;
            end
        end
    end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
    KeccakLData KeccakLData_m (
        .ena_i(last_o),
        .last_Block_i(ldata_i_reg),
        .mode_last_i(lmode_i),
        .last_Block_o(last_Block_o),
        .last_hash_o(last_hash_o),
        .lnum_hash_o(lnum_hash_o)
    );

    KeccakData KeccakData_m (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .data_i(data_i),
        .valid_i(valid_i),
        .last_i(last_i),
        .data_o(data_o),
        .valid_o(valid_o),
        .last_o(last_o),
        .perfull_i(oBuffer_full),
        .perfull_i_0(oBuffer_temp & oBuffer_temp_2),
        .perready_i(f_oAck),
        .next_o(next_o)
    );

    Keccak Keccak_m (
        .iClk(clk_i),
        .iRst(rst_i),
        .iMode(mode_i),	
        .i_SHA(SHA_i),
        .iData(data_keccak),
        .iReady(valid_o),
        .iLast(last_hash_o),
        .iByte_num(lnum_hash_o),
        .iCon_per(1'b0),
        .oBuffer_full(oBuffer_full), 
        .oBuffer_temp(oBuffer_temp),
        .oBuffer_temp_2(oBuffer_temp_2),
        .f_oAck(f_oAck), 		
        .f_oReady(f_oReady),
        .oData(oData),
        .oReady(oReady)
    );
endmodule
