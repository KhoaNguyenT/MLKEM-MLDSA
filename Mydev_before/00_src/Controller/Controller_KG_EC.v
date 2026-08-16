module Controller_KG_EC (
    //controll signal
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                gk_ena_i,
    input   wire                ec_ena_i,
    input   wire                dc_ena_i,
    input   wire    [2:0]       k_i,
    // 2CB843A02EF02EE109305F39119FABF49AB90A57FFECB3A0E75E179450F52761 GenKey
    input   wire    [191:0]     data_i,
    input   wire                valid_i,
    input   wire                done_i,
    // TEMP
    output  wire                BMUL_valid_o,
    output  wire    [191:0]     BMUL_Coeff_o,
    //debug
    
    output  wire    [191:0]     MUL_data_o,
    output  wire                MUL_valid_o,
    output  wire                MUL_pre_valid_o,
    
    output  reg     [255:0]     DC_K
);

/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
    localparam IDLE = 2'b00;
    localparam RHO1 = 2'b01;
    localparam RHO2 = 2'b10;
    localparam DONE = 2'b11;
    localparam FIRST  = 1'b0;
    localparam SECOND = 1'b1;
    
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/ 
    wire                ec_inter;
    wire                dc_inter;
    wire                rst_inter;
    reg                 GEN_temp_INDC;
    wire                Cipher_CMP_o;

    reg                 next_o;
    // wire    [3:0]       idx_mp;
    // KEC
    reg     [1:0]       KEC_state;
    reg     [255:0]     KEC_sigma_reg;
    reg     [255:0]     KEC_rho_reg;
    reg     [255:0]     KEC_K_bar_reg;
    wire    [191:0]     KEC_bram_reg;
    reg     [191:0]     KEC_rho_i;
    reg                 KEC_valid_rho_i;
    reg                 KEC_ena_i;
    wire    [1343:0]    KEC_data_o;
    wire                KEC_ready_o;
    wire                KEC_read_indc;
    wire                KEC_rtimes;
    wire    [2:0]       KEC_status_o;

    wire    [191:0]     KEC_din_next_i;
    wire                KEC_valid_next_i;
    wire                KEC_done_next_i;
    reg                 KEC_done_next;
    wire    [191:0]     KEC_din_i;
    wire                KEC_valid_i;
    wire                KEC_done_i;

    // CBDSampler
    reg                 CBD_ena_i;
    wire    [255:0]     CBD_sigma_i;
    wire    [191:0]     CBD_Coeff_o;
    wire                CBD_valid_o;
    wire                CBD_done_o;
    wire    [4:0]       CBD_runs;



    // from input to NTTSampler
    reg                 GEN_encap_i;
    reg     [255:0]     GEN_edata_i;
    // NTTSampler
    reg                 GEN_ena_i;
    wire    [255:0]     GEN_rho_i;
    wire    [4:0]       GEN_runs;
    wire    [191:0]     GEN_Coeff_o;
    wire                GEN_valid_o;
    wire                GEN_done_o;
    
    // BRAM
    reg                 BRAM_ena_i;

    // NTT
    reg                 NTT_ena_i;
    wire                NTT_done_compute;
    wire    [3:0]       NTT_runs;
    wire                NTT_valid_output;
    wire    [191:0]     NTT_out_o;
    wire                NTT_done_one;

    wire                NTT_pre_valid_output;

    // DEC
    wire    [2:0]       DEC_state;
    wire                DEC_rvalid_i;
    wire                DEC_valid_o;
    wire                DEC_valid_rho;
    wire    [191:0]     DEC_Coeff_o;
    wire    [191:0]     DEC_data_o;
    wire                DEC_wdone_o;
    wire                DC_run_check;
    // DCP
    wire                DCP_valid_m_i;
    wire    [191:0]     DCP_coeff_m_i;
    wire                DCP_valid_m_o;
    wire    [191:0]     DCP_coeff_m_o;

    // CMP
    wire                CMP_valid_o;
    wire    [191:0]     CMP_data_o;
    wire                CMP_done_o;
    // PackBit
    wire                PB_valid_o;
    wire    [191:0]     PB_data_o;
    wire                PB_phase_o;
    reg     [255:0]     PB_m_prime;
    reg                 PB_valid_DCP;
    reg     [191:0]     PB_data_DCP;
    reg                 PB_valid_DONE;

    // ENC
    wire                ENC_s_hat_valid_o;
    wire                ENC_t_hat_valid_o;
    wire                ENC_u_valid_o;
    wire                ENC_valid_o;
    wire    [191:0]     ENC_Coeff_o;
    wire                ENC_done_decap_reg;
    wire                ENC_done_o;


    // MUL
    reg                 MUL_ena_i;
    // wire    [191:0]     MUL_data_o;
    // wire                MUL_valid_o;
    // wire                MUL_pre_valid_o;

    // MUL
    wire    [191:0]     ADD_data_o;
    wire                ADD_valid_o;
    wire                ADD_done_o;


    // BRAM_INDC
    wire                BINDC_valid_o;
    wire    [191:0]     BINDC_data_o;
    wire                BINDC_done_o;
    // BRAM_C
    reg                 BRAM_pre_next_mul;
    reg                 BRAM_next_mul;
    // BRAM_GEN;
    wire                BGEN_valid_o;
    wire    [191:0]     BGEN_Coeff_o;
    wire                BGEN_done_o;
    // BRAM_NTT => BRAM_GEN
    wire                BRAM_stop;

    // BRAM_NTT => MUL
    wire                BNTT_add_signal_o;
    wire                BNTT_valid_o;
    wire    [191:0]     BNTT_Coeff_o;
    wire                BNTT_done_o;
    // BRAM_MUL => ADD
    // wire                BMUL_valid_o;
    // wire    [191:0]     BMUL_Coeff_o;
    // BRAM_CBD
    wire                BCBD_valid_o;
    wire    [191:0]     BCBD_Coeff_o;
    wire                BCBD_done_o;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign  ec_inter    =   ec_ena_i | ENC_done_decap_reg;
    assign  dc_inter    =   dc_ena_i & ~ENC_done_decap_reg;
    assign  rst_inter   =   rst_i    | (PB_phase_o & dc_ena_i & ENC_done_decap_reg);

    assign  CBD_sigma_i = KEC_data_o[255:0];
    assign  GEN_rho_i   = (gk_ena_i & ~ec_ena_i & ~dc_ena_i)  ? KEC_data_o[511:256]
                        : (~gk_ena_i & ec_ena_i & ~dc_ena_i)  ? GEN_edata_i
                        : ((~gk_ena_i & ~ec_ena_i & dc_ena_i) & (KEC_rtimes == SECOND))  ? GEN_edata_i
                        : 0;

    assign  ENC_valid_o = ENC_s_hat_valid_o | ENC_t_hat_valid_o | ENC_u_valid_o;


    assign  KEC_din_next_i      =   ((ENC_done_o & (gk_ena_i & ~ec_ena_i)) | (next_o     & (~gk_ena_i & ec_ena_i)))    ?   KEC_rho_i
                                :   (dc_ena_i & PB_phase_o)     ?   BINDC_data_o
                                :   (dc_ena_i & ~PB_phase_o)    ?   PB_data_o
                                :   ENC_Coeff_o;
    assign  KEC_valid_next_i    =   ((ENC_done_o & (gk_ena_i & ~ec_ena_i)) | (next_o     & (~gk_ena_i & ec_ena_i)))    ?   KEC_valid_rho_i 
                                :   (dc_ena_i & PB_phase_o)     ?   BINDC_valid_o
                                :   (dc_ena_i & ~PB_phase_o)    ?   PB_valid_o
                                :   ENC_t_hat_valid_o;
    assign  KEC_done_next_i     =   (~dc_ena_i)     ?   KEC_done_next
                                :   BINDC_done_o;

    assign  KEC_din_i           =   (~dc_ena_i)     ?   data_i  :   BINDC_data_o;
    assign  KEC_valid_i         =   (~dc_ena_i)     ?   valid_i :   BINDC_valid_o;
    assign  KEC_done_i          =   (~dc_ena_i)     ?   done_i  :   BINDC_done_o;


    assign  DCP_valid_m_i       =   ((DEC_state == 2) & DEC_valid_o &  (~gk_ena_i & ec_inter & ~dc_ena_i))    ?   1'b1    
                                :   (ec_inter & dc_ena_i)  ?   PB_valid_DCP
                                :   (~gk_ena_i & ~ec_ena_i & dc_ena_i & DC_run_check)  ?   DEC_valid_o
                                :   1'b0;///
    assign  DCP_coeff_m_i       =   (ec_inter & dc_ena_i & PB_valid_DCP)  ?   DEC_data_o
                                :   DEC_Coeff_o;
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
    always @(posedge clk_i) begin   : KECCAK
        if (rst_i) begin
            KEC_state       <= IDLE;
            KEC_ena_i       <= 0;
            next_o          <= 0;
            KEC_sigma_reg   <= 0;
            KEC_rho_reg     <= 0;
            KEC_rho_i       <= 0;
            KEC_valid_rho_i <= 0; 
            KEC_done_next   <= 0;
            KEC_K_bar_reg   <= 0;
        end
        else begin
            if (((done_i & ~dc_ena_i) | (BINDC_done_o & dc_ena_i)) & ~KEC_ready_o) begin
                KEC_ena_i   <= 1;
            end
            else if (KEC_ready_o & (gk_ena_i | ec_ena_i) & ~dc_ena_i) begin
            // else if (KEC_ready_o & (gk_ena_i | ec_ena_i| dc_ena_i)) begin
                KEC_ena_i   <= 1;
                next_o      <= 1;
                KEC_sigma_reg   <= KEC_data_o[255:0];
                KEC_rho_reg     <= KEC_data_o[511:256];
            end
            else if (dc_ena_i & KEC_ready_o) begin
                if (~next_o) KEC_K_bar_reg   <= KEC_data_o[1087:832];
                next_o          <= 1'b1;
                KEC_sigma_reg   <= KEC_data_o[255:0];
                KEC_rho_reg     <= KEC_data_o[511:256];
            end
            case (KEC_state)
                IDLE: begin
                    if (gk_ena_i & ~ec_ena_i) begin
                        if (ENC_done_o) begin
                            KEC_state   <= RHO1;
                        end
                        KEC_rho_i   <= 0;
                        KEC_valid_rho_i <= 0;
                        KEC_done_next <= 0;
                    end
                    else if (~gk_ena_i & ec_ena_i) begin
                        if (KEC_ready_o) begin
                            KEC_state   <= RHO1;
                        end
                        KEC_rho_i   <= 0;
                        KEC_valid_rho_i <= 0;
                        KEC_done_next <= 0;
                    end
                end 
                RHO1: begin
                    if (gk_ena_i & ~ec_ena_i) begin
                        KEC_rho_i   <= KEC_rho_reg[255:64];
                    end
                    else if (~gk_ena_i & ec_ena_i) begin
                        KEC_rho_i   <= KEC_sigma_reg[255:64];
                    end
                    KEC_valid_rho_i <= 1'b1;
                    KEC_state   <= RHO2;
                end 
                RHO2: begin
                    if (gk_ena_i & ~ec_ena_i) begin
                        KEC_rho_i   <= {KEC_rho_reg[63:0], 128'b0};
                    end
                    else if (~gk_ena_i & ec_ena_i) begin
                        KEC_rho_i   <= {KEC_sigma_reg[63:0], 128'b0};
                    end
                    KEC_valid_rho_i <= 1'b1;
                    KEC_state   <= DONE;
                end 
                DONE: begin
                    KEC_rho_i   <= 0;
                    KEC_valid_rho_i <= 0;
                    KEC_done_next <= 1'b1;
                end 
                default: KEC_state  <= IDLE;
            endcase
        end
    end

    always @(posedge clk_i) begin   : CBD_SAMPLER
        if (rst_i) begin
            CBD_ena_i           <= 0;
        end
        else begin
            if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
                if (KEC_ready_o & (KEC_rtimes == FIRST)) begin
                    CBD_ena_i       <= 1'b1;
                end
            end
            else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin
                if (KEC_ready_o & (KEC_rtimes == SECOND) & (KEC_state == DONE)) begin
                    CBD_ena_i       <= 1'b1;
                end
            end
            else if (~gk_ena_i & ~ec_ena_i & dc_ena_i & ENC_done_decap_reg) begin
                if (KEC_ready_o) begin
                    CBD_ena_i       <= 1'b1;
                end
            end
        end
    end

    always @(posedge clk_i) begin   : GEN_SAMPLER
        if (rst_i) begin
            GEN_encap_i         <= 0;
            GEN_edata_i         <= 0;
            GEN_ena_i           <= 0;
        end
        else begin
            if (~dc_ena_i) begin
                if (KEC_status_o == 3'b010 & ~GEN_ena_i) begin
                    if (~GEN_encap_i & (|KEC_bram_reg)) begin
                        GEN_encap_i <= 1;
                        GEN_edata_i[255:64] <= KEC_bram_reg;
                    end
                    else if (GEN_encap_i & ~(|KEC_bram_reg[127:0])) begin
                        GEN_edata_i[63:0] <= KEC_bram_reg[191:128];
                    end
                end
            end
            else begin
                if (DEC_valid_rho & ~GEN_encap_i) begin
                    GEN_edata_i[255:64] <= DEC_data_o;
                    GEN_encap_i   <= 1'b1;
                end
                else if (DEC_valid_rho & GEN_encap_i) begin
                    GEN_edata_i[63:0] <= DEC_data_o[191:128];
                end
            end
            // if (gk_ena_i & ~ec_ena_i) begin
            if (gk_ena_i & ~ec_inter) begin
                if (KEC_ready_o & (KEC_rtimes == FIRST)) begin          
                    GEN_ena_i       <= 1'b1;
                end
            end
            // else if (~gk_ena_i & ec_ena_i) begin
            else if (~gk_ena_i & ec_inter) begin
                if (KEC_ready_o) begin            
                    GEN_ena_i       <= 1'b1;
                end
            end
        end
    end

    always @(posedge clk_i) begin   : NTT
        if (rst_i) begin
            NTT_ena_i           <= 0;
        end
        else begin
            if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
                if (KEC_ready_o & (KEC_rtimes == FIRST)) begin
                    NTT_ena_i       <= 1'b1;
                end
            end
            else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin
                if (KEC_ready_o & (KEC_rtimes == SECOND)) begin
                    NTT_ena_i       <= 1'b1;
                end
            end
            else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                NTT_ena_i       <= 1'b1;
            end
        end
    end

    always @(posedge clk_i) begin   : BRAM_MUL
        if (rst_i) begin
            BRAM_next_mul       <= 0;
            BRAM_pre_next_mul   <= 0;
            BRAM_ena_i          <= 0;
        end
        else begin
            if (KEC_ready_o) begin
                BRAM_ena_i      <= 1;
            end
            else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                BRAM_ena_i      <= 1;
            end
            if (gk_ena_i & ~ec_ena_i) begin
                if (BGEN_valid_o & BNTT_valid_o & ~BGEN_done_o & ~BNTT_done_o) begin
                    BRAM_pre_next_mul   <= 1;
                end
                else BRAM_pre_next_mul   <= 0;
            end
            else if (~gk_ena_i & (ec_ena_i | ec_inter)) begin
                if (BGEN_valid_o & BNTT_valid_o & ~BGEN_done_o & ~BNTT_done_o) begin // loi o day dung BRAM_pre_next_mul nen giong voi o tren
                    BRAM_pre_next_mul   <= 1;
                end
                else BRAM_pre_next_mul   <= 0;
            end
            BRAM_next_mul <= BRAM_pre_next_mul;
        end
    end
    
    always @(posedge clk_i) begin   : MUL
        if (rst_i) begin
            MUL_ena_i   <= 0;
        end
        else begin
            if (KEC_ready_o) begin
                MUL_ena_i   <= 1;
            end
            else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                MUL_ena_i   <= 1;
            end
        end
    end

    always @(posedge clk_i) begin   : PB_INDC
        if (rst_i) begin
            PB_m_prime      <= 0;
            GEN_temp_INDC   <= 0;

            PB_data_DCP     <= 0;
            PB_valid_DCP    <= 0;
            PB_valid_DONE   <= 0;
            DC_K            <= 0;
        end
        else begin
            if (PB_valid_o & ~GEN_temp_INDC) begin
                PB_m_prime[255:64] <= PB_data_o;
                GEN_temp_INDC       <= 1'b1;
            end
            else if (PB_valid_o & GEN_temp_INDC) begin
                PB_m_prime[63:0]   <= PB_data_o[191:128];
            end
            
            if (ec_inter & ~PB_valid_DONE & ~PB_valid_DCP) begin
                PB_data_DCP     <= PB_m_prime[255:64];
                PB_valid_DCP    <= 1;
            end
            else if (ec_inter & ~PB_valid_DONE & PB_valid_DCP) begin
                PB_data_DCP[191:128]    <= PB_m_prime[63:0];
                PB_data_DCP[127:0]      <= 0;
                PB_valid_DCP            <= 1;
                PB_valid_DONE           <= 1;
            end
            else begin
                PB_data_DCP     <= 0;
                PB_valid_DCP    <= 0;
                PB_valid_DONE   <= PB_valid_DONE;
            end

            if (ENC_done_o & dc_ena_i) begin
                if (~Cipher_CMP_o) begin
                    DC_K    <=  KEC_rho_reg;
                end
                else begin
                    DC_K    <= KEC_K_bar_reg;
                end
            end
        end
    end

    always @(posedge clk_i) begin   : DISPLAY 
        if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
            if (ENC_s_hat_valid_o | ENC_t_hat_valid_o) begin
                $display("%h",ENC_Coeff_o);
                $fflush();
            end
        end
        else if (~gk_ena_i & (ec_ena_i | dc_ena_i)) begin
            if (ENC_u_valid_o) begin
                $display("%h",ENC_Coeff_o);
                $fflush();
            end
        end
        // Check  
        // if (ec_inter & (NTT_runs == 5) & MUL_valid_o) begin
        //     $display("%h", MUL_data_o);
        //     // $display("%h",ENC_Coeff_o);
        //     $fflush();
        // end
        // if (ec_inter & (NTT_runs == 5) & NTT_valid_output) begin
        //     $display("%h", NTT_out_o);
        //     // $display("%h",ENC_Coeff_o);
        //     $fflush();
        // end
    end
/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/
    WrapperDecode       WrapperDecode_inst( 
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .ec_inter_i(ec_inter),
        .dc_ena_i(dc_inter),
        // .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .NTT_runs(NTT_runs),
        .NTT_done_compute(NTT_done_compute),
        .NTT_done_one(NTT_done_one),
        .DC_run_check(DC_run_check),
        .wvalid_i(valid_i),
        .coeff_i(data_i),
        .done_input_i(done_i),
        .rvalid_i(NTT_pre_valid_output),
        .PB_coeff_i(PB_data_DCP),
        .PB_valid_i(PB_valid_DCP),
        .valid_decode(DEC_valid_o),
        .valid_rho(DEC_valid_rho),
        .coeff_o(DEC_Coeff_o),
        .DEC_data_o(DEC_data_o),
        .state(DEC_state),
        .wdone_o(DEC_wdone_o)
    );

    WrapperDecompress   WrapperDecompress_inst (
        .clk_i(clk_i),
        .rst_i(rst_inter),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .dc_ena_i(dc_inter),
        .k_i(k_i),
        .CBD_runs(CBD_runs),
        .shift_next_i(CBD_valid_o),
        .valid_m_i(DCP_valid_m_i),
        .coeff_m_i(DCP_coeff_m_i),
        // .coeff_m_i(DEC_Coeff_o),
        .valid_o(DCP_valid_m_o),
        .coeff_o(DCP_coeff_m_o)
    );

    WrapperBRAMINDC     WrapperBRAMINDC_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(1'b1),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .wdone_i(done_i),
        .wvalid_i(valid_i),
        .rvalid_i(KEC_read_indc),
        .data_i(data_i),
        .next_i(PB_phase_o),
        .valid_o(BINDC_valid_o),
        .data_o(BINDC_data_o),
        .done_o(BINDC_done_o),

        .ENC_dc_done_i(ENC_done_decap_reg),
        .ENC_valid_i(ENC_valid_o),
        .ENC_Coeff_i(ENC_Coeff_o), 
        .Cipher_CMP_o(Cipher_CMP_o)
    );

    WrapperKeccak       WrapperKeccak_inst (  
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .din_i(KEC_din_i),
        .valid_i(KEC_valid_i),
        .done_i(KEC_done_i),
        .din_next_i(KEC_din_next_i),
        .valid_next_i(KEC_valid_next_i),
        .done_next_i(KEC_done_next_i),
        .oData(KEC_data_o),
        .ready_o(KEC_ready_o),
        .ena_i(KEC_ena_i),
        .rvalid_indc_o(KEC_read_indc),
        .rtimes(KEC_rtimes),
        .status_o(KEC_status_o),
        .dout_bram(KEC_bram_reg)
    );

    CBDSampler_wrapper  CBDSampler_wrapper_m (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        // .ec_ena_i(ec_ena_i | ENC_done_decap_reg), //////////////////////////
        .ec_ena_i(ec_inter), //////////////////////////
        .k_i(k_i),
        .ena_i(CBD_ena_i),
        .sigma_i(CBD_sigma_i),
        .CBD_runs(CBD_runs),
        .NTT_done_compute_i(NTT_done_compute),
        .Coeff_o(CBD_Coeff_o),
        .valid_o(CBD_valid_o),
        .done_o(CBD_done_o)
    );

    WrapperBRAMCBD      WrapperBRAMCBD_inst (
        .clk_i(clk_i),
        .rst_i(rst_inter),
        .ena_i(CBD_ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .k_i(k_i),
        .valid_i(CBD_valid_o),
        .data_i(CBD_Coeff_o),
        .add_valid_i(ADD_valid_o),
        .add_data_i(ADD_data_o),
        .CBD_runs(CBD_runs),
        .next_i(NTT_pre_valid_output),
        .stop_i(1'b0),
        .valid_o(BCBD_valid_o),
        .data_o(BCBD_Coeff_o),
        .done_o(BCBD_done_o)
    );

    NTTSampler_wrapper  NTTSampler_wrapper_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(GEN_ena_i),
        .gk_ena_i(gk_ena_i),
        // .ec_ena_i(ec_ena_i),
        .ec_ena_i(ec_inter),
        .k_i(k_i),
        .rho_i(GEN_rho_i),
        .runtimes(GEN_runs),
        .Coeff_o(GEN_Coeff_o),
        .valid_o(GEN_valid_o),
        .done_o(GEN_done_o)
    );

    WrapperBRAMGEN      WrapperBRAMGEN_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(BRAM_ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .k_i(k_i),
        .valid_i(GEN_valid_o),
        .data_i(GEN_Coeff_o),
        .GEN_runs(GEN_runs),
        .next_i(GEN_done_o),
        .valid_o(BGEN_valid_o),
        .stop_i(BRAM_stop),//////////
        .data_o(BGEN_Coeff_o),
        .done_o(BGEN_done_o)
    );

    WrapperNTTINTT      WrapperNTTINTT_inst (
        .clk_i(clk_i),
        // .rst_i(rst_i | PB_phase_o), ///////////////////////
        .rst_i(rst_inter),
        .ena_i(NTT_ena_i),
        .gk_ena_i(gk_ena_i),
        // .ec_ena_i(ec_ena_i | ENC_done_decap_reg),
        .ec_ena_i(ec_inter),
        // .dc_ena_i(dc_ena_i & ~ENC_done_decap_reg),
        .dc_ena_i(dc_inter),
        .k_i(k_i),
        .CBD_valid_input(CBD_valid_o),
        .CBD_data_i(CBD_Coeff_o),
        .MUL_valid_input(MUL_valid_o),
        .MUL_data_i(MUL_data_o),
        .DCP_valid_input(DCP_valid_m_o),
        .DCP_data_i(DCP_coeff_m_o),
        .done_compute(NTT_done_compute),
        .valid_output(NTT_valid_output),
        .pre_valid_output(NTT_pre_valid_output),
        .out(NTT_out_o),
        .NTT_done(NTT_done_one),
        .NTT_runs(NTT_runs)
    );

    WrapperBRAMNTT      WrapperBRAMNTT_inst(
        .clk_i(clk_i),
        .rst_i(rst_inter),
        .ena_i(BRAM_ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .dc_ena_i(dc_inter),
        .k_i(k_i),
        .valid_i(NTT_valid_output),
        .data_i(NTT_out_o),
        .NTT_runs(NTT_runs),
        .next_i(GEN_done_o),
        .NTT_done_compute(NTT_done_compute),
        .stop_o(BRAM_stop),
        .add_signal(BNTT_add_signal_o),
        .valid_o(BNTT_valid_o),
        .data_o(BNTT_Coeff_o),
        .done_o(BNTT_done_o)
    );

    WrapperCompress     WrapperCompress_inst (
        .clk_i(clk_i),
        .rst_i(rst_inter),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .dc_ena_i(dc_inter),
        .k_i(k_i),
        .CMP_valid_i(ADD_valid_o),
        .CMP_data_i(ADD_data_o),
        .CMP_valid_o(CMP_valid_o),
        .CMP_data_o(CMP_data_o),
        .done_o(CMP_done_o)
    );

    WrapperEncode       WrapperEncode_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .dc_ena_i(dc_inter),
        .k_i(k_i),
        .NTT_runs(NTT_runs),
        .uv_valid_i(CMP_valid_o),
        .uv_data_i(CMP_data_o),
        .s_valid_i(NTT_valid_output),
        .s_hat_i(NTT_out_o),
        .t_valid_i(ADD_valid_o),
        .t_hat_i(ADD_data_o),
        .s_hat_valid_o(ENC_s_hat_valid_o),
        .t_hat_valid_o(ENC_t_hat_valid_o),
        .uv_valid_o(ENC_u_valid_o),
        .coeff_o(ENC_Coeff_o),
        .done_decap_o(ENC_done_decap_reg),
        .done_encode_i(ADD_done_o),
        .done_encode_o(ENC_done_o)
    );


    PackBits            PackBits_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .in_valid(ENC_valid_o),
        .in_data(ENC_Coeff_o[191:176]),
        .out_valid(PB_valid_o),
        .out_phase(PB_phase_o),
        .out_data(PB_data_o),
        .done_i(BINDC_done_o)
    );

    WrapperMul          WrapperMul (
        .clk_i(clk_i),
        .rst_i(rst_inter),
        .ena_i(MUL_ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .dc_ena_i(dc_inter),
        .k_i(k_i),
        .DEC_valid_i(DEC_valid_o),
        .DEC_data_i(DEC_Coeff_o),
        .BGEN_valid_i(BGEN_valid_o),
        .BGEN_data_i(BGEN_Coeff_o),
        .BNTT_valid_i(BNTT_valid_o),
        .BNTT_data_i(BNTT_Coeff_o),
        .MUL_valid_o(MUL_valid_o),
        .MUL_data_o(MUL_data_o)
    );

    assign MUL_pre_valid_o = MUL_valid_o;

    WrapperBRAMMUL      WrapperBRAMMUL_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(BRAM_ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .k_i(k_i),
        .valid_i(MUL_valid_o),
        .data_i(MUL_data_o),
        .enr_i(NTT_pre_valid_output), 
        .enrgk_i(BNTT_add_signal_o), 
        .NTT_runs(NTT_runs),
        .valid_o(BMUL_valid_o),
        .data_o(BMUL_Coeff_o)
    );
    
    WrapperADD      WrapperADD_inst (
        .clk_i(clk_i),
        .rst_i(rst_inter),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_inter),
        .dc_ena_i(dc_inter),
        .k_i(k_i),
        .BNTT_valid_i(BNTT_valid_o & BNTT_add_signal_o),
        .BNTT_Coeff_i(BNTT_Coeff_o),
        .BMUL_valid_i(BMUL_valid_o),
        .BMUL_Coeff_i(BMUL_Coeff_o),
        .BCBD_valid_i(BCBD_valid_o),
        .BCBD_Coeff_i(BCBD_Coeff_o),
        .NTT_valid_i(NTT_valid_output),
        .NTT_data_i(NTT_out_o),
        .CBD_valid_i(CBD_valid_o),
        .CBD_Coeff_i(CBD_Coeff_o),
        .DCP_valid_i(DCP_valid_m_o),
        .DCP_Coeff_i(DCP_coeff_m_o),
        .oSum_valid_o(ADD_valid_o),
        .oSum_done_o(ADD_done_o),
        .oSum(ADD_data_o)
    );
    
endmodule
