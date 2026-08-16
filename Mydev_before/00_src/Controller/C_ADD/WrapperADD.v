module WrapperADD (
    // Controll signal
    input   wire            clk_i,
    input   wire            rst_i,
    input   wire            gk_ena_i,
    input   wire            ec_ena_i,
    input   wire            dc_ena_i,
    input   wire    [2:0]   k_i,

    input   wire            BNTT_valid_i,
    input   wire  [191:0]   BNTT_Coeff_i,
    input   wire            BMUL_valid_i,
    input   wire  [191:0]   BMUL_Coeff_i,
    input   wire            BCBD_valid_i,
    input   wire  [191:0]   BCBD_Coeff_i,
    input   wire            NTT_valid_i,
    input   wire  [191:0]   NTT_data_i,
    

    input   wire            CBD_valid_i,
    input   wire  [191:0]   CBD_Coeff_i,
    input   wire            DCP_valid_i,
    input   wire  [191:0]   DCP_Coeff_i,

    output  reg             oSum_valid_o,
    output  reg             oSum_done_o,
    output  wire  [191:0]   oSum
);  

/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
    localparam  IDLE   = 3'b000;
    localparam  GENKEY = 3'b001;
    localparam  ENCAP0 = 3'b010;
    localparam  ENCAP1 = 3'b011;
    localparam  DECAP  = 3'b100;
    localparam  DONE   = 3'b111;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    reg   [2:0]   state;
    reg   [191:0] A;
    reg   [191:0] B;
    wire  [7:0]   max_k;
    reg   [7:0]   count;
    reg           runtime;
    reg           is_SUB;

/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign  max_k           = (k_i == 2)        ?   8'd32
                            : (k_i == 3)        ?   8'd48
                            : (k_i == 4)        ?   8'd64
                            : 0;                 
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            state           <= IDLE;
            A               <= 0;
            B               <= 0;
            count           <= 0;
            oSum_valid_o    <= 0;
            oSum_done_o     <= 0;
            runtime         <= 0;
            is_SUB          <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
                        state <= GENKEY;
                    end
                    else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin
                        state <= ENCAP0;
                    end
                    else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                        state <= DECAP;
                    end
                end 
                GENKEY: begin
                    if (k_i == 2) begin
                        if (BMUL_valid_i & NTT_valid_i) begin
                            A   <= BMUL_Coeff_i;
                            B   <= NTT_data_i;
                            oSum_valid_o    <= 1'b1;
                            count   <= count + 1;
                        end
                        else begin
                            A   <= 0;
                            B   <= 0;
                            oSum_valid_o    <= 1'b0;
                            count <= count;
                        end
                        if (count == max_k) begin
                            state <= DONE;
                        end
                    end
                    else begin
                        if (BMUL_valid_i & BNTT_valid_i) begin
                            A   <= BMUL_Coeff_i;
                            B   <= BNTT_Coeff_i;
                            oSum_valid_o    <= 1'b1;
                            count   <= count + 1;
                        end
                        else begin
                            A   <= 0;
                            B   <= 0;
                            oSum_valid_o    <= 1'b0;
                            count <= count;
                        end
                        if (count == max_k) begin
                            state <= DONE;
                        end
                    end
                end 
                ENCAP0: begin
                    if (BCBD_valid_i & NTT_valid_i & (count != max_k)) begin
                        A               <= BCBD_Coeff_i;
                        B               <= NTT_data_i;
                        oSum_valid_o    <= 1'b1;
                        count           <= count + 1;
                    end
                    else if ((count == max_k) | (count[4] & runtime)) begin
                        A               <= 0;
                        B               <= 0;
                        oSum_valid_o    <= 1'b0;
                        count           <= 0;
                    end
                    else begin
                        A   <= 0;
                        B   <= 0;
                        oSum_valid_o    <= 1'b0;
                        count <= count;
                    end
                    if (count == max_k & & ~runtime) begin
                        state <= ENCAP1;
                    end
                    else if (count[4] & runtime) begin
                        state <= DONE;
                    end
                end 
                ENCAP1: begin
                    if (CBD_valid_i & DCP_valid_i & ~count[4]) begin
                        A   <= CBD_Coeff_i;
                        B   <= DCP_Coeff_i;
                        oSum_valid_o    <= 1'b1;
                        count   <= count + 1;
                    end
                    else if (count[4]) begin
                        A   <= 0;
                        B   <= 0;
                        oSum_valid_o    <= 1'b0;
                        count <= 0;
                    end
                    else begin
                        A   <= 0;
                        B   <= 0;
                        oSum_valid_o    <= 1'b0;
                        count <= count;
                    end
                    if (count[4] & ~runtime) begin
                        state <= ENCAP0;
                        runtime <= 1'b1;
                    end
                end 
                DECAP: begin
                    if (NTT_valid_i & DCP_valid_i) begin
                        is_SUB  <= 1'b1;
                        A   <= DCP_Coeff_i;
                        B   <= NTT_data_i;
                        oSum_valid_o    <= 1'b1;
                        count   <= count + 1;
                    end
                    else begin
                        A   <= 0;
                        B   <= 0;
                        oSum_valid_o    <= 1'b0;
                        count <= count;
                    end
                    if (count == 16) begin
                        state <= DONE;
                        count <= 0;
                    end
                end 
                DONE: begin
                    oSum_done_o <= 1;
                end 
                default: state <= IDLE;
            endcase
        end
    end


    add add_inst (
        .iA_flat(A),
        .iB_flat(B),
        .is_SUB(is_SUB),
        .oSum_flat(oSum)
    );
endmodule


