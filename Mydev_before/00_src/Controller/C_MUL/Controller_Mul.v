module Controller_Mul # (
    parameter DATA_WIDTH = 192
)(
    //controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,

    //  I/O MUL
    input   wire                        DEC_valid_i,
    input   wire    [DATA_WIDTH-1: 0]   DEC_data_i,

    input   wire                        BGEN_valid_i,
    input   wire    [DATA_WIDTH-1: 0]   BGEN_data_i,
    
    input   wire                        BNTT_valid_i,
    input   wire    [DATA_WIDTH-1: 0]   BNTT_data_i,
    
    output  reg                         valid_mul_o,
    output  reg     [DATA_WIDTH-1: 0]   Adata_mul_o,
    output  reg     [DATA_WIDTH-1: 0]   Bdata_mul_o,
    //  I/O Controller
    input   wire                        pre_valid_mul_i,
    input   wire                        valid_mul_i
);
    
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
localparam IDLE     = 3'b000;
localparam GENKEY   = 3'b001;
localparam ENCAP0   = 3'b010;
localparam DONE     = 3'b111;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
reg     [2:0]   state;
reg     [2:0]   runs;

/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/


/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            state   <= IDLE;
            valid_mul_o     <= 0;
            Adata_mul_o     <= 0;
            Bdata_mul_o     <= 0;
            runs            <= 1;
        end
        else begin
            case (state)
                IDLE: begin
                    if (ena_i) begin
                        if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
                            state   <= GENKEY;
                        end
                        else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin
                            state   <= GENKEY;
                        end
                        else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                            state   <= ENCAP0;
                        end
                    end
                    valid_mul_o     <= 0;
                    Adata_mul_o     <= 0;
                    Bdata_mul_o     <= 0;
                end 
                GENKEY: begin
                    if (BGEN_valid_i & BNTT_valid_i) begin
                        valid_mul_o <= 1'b1;
                        Adata_mul_o <= BGEN_data_i;
                        Bdata_mul_o <= BNTT_data_i;
                    end
                    else begin
                        valid_mul_o     <= 0;
                        Adata_mul_o     <= 0;
                        Bdata_mul_o     <= 0;
                    end
                    if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
                        if (valid_mul_i & ~pre_valid_mul_i) begin
                            state       <= DONE;
                        end
                    end
                    else if (~gk_ena_i & ec_ena_i) begin
                        if (valid_mul_i & ~pre_valid_mul_i & (runs == k_i)) begin
                            state       <= ENCAP0;
                        end
                        else if (valid_mul_i & ~pre_valid_mul_i & (runs != k_i)) begin
                            runs        <= runs + 1;
                        end
                    end
                    else begin
                        state       <= GENKEY;
                    end
                end 
                ENCAP0: begin
                    if (DEC_valid_i & BNTT_valid_i) begin
                        valid_mul_o <= 1'b1;
                        Adata_mul_o <= DEC_data_i;
                        Bdata_mul_o <= BNTT_data_i;
                    end
                    else begin
                        valid_mul_o     <= 0;
                        Adata_mul_o     <= 0;
                        Bdata_mul_o     <= 0;
                    end
                    if (valid_mul_i & ~pre_valid_mul_i) begin
                        state       <= GENKEY;
                    end
                    else state       <= ENCAP0;
                end 
                DONE: begin
                    
                end 
                default: state <= IDLE; 
            endcase
        end
    end 
endmodule
