module CBDSampler (
    input   wire            clk_i,
    input   wire            rst_i,
    input   wire            gk_ena_i,
    input   wire            ec_ena_i,
    input   wire    [2:0]   k_i,
    input   wire    [7:0]   runtimes_i,
    input   wire            ena_i,
    input   wire            cnext_hash_i,
    input   wire            rst_hash_i,
    input   wire    [255:0] sigma_i,
    input   wire            NTT_done_compute_i,
    output  wire            Coeff_eta_o,// 0: eta=2, 1: eta=3
    output  reg             ena_hash_o,
    output  reg             next_hash_o,
    output  reg             rst_hash_o,
    output  wire    [63:0]  data_o,
    output  reg             ena_gen_o,
    output  reg             next_gen_o
);
    reg   [255:0]   rho_reg;
    reg   [1:0]     idx;
    reg   [1:0]     state;
    reg             first;
    wire  [7:0]     k_i_remp;
    localparam IDLE = 2'b00, DATA = 2'b01, WAIT = 2'b10, NEXT = 2'b11;

    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/

    assign data_o       = rho_reg[(idx*64) +: 64];
    assign k_i_remp     = {5'b0, k_i};
    // 0: eta=2, 1: eta=3
    // always @(*) begin
    //     if (gk_ena_i & ~ec_ena_i) begin
    //         if (k_i == 2) Coeff_eta_o = 1;
    //         else Coeff_eta_o = 0;
    //     end
    //     else if (~gk_ena_i & ec_ena_i) begin
    //         if (k_i == 2 & (runtimes_i > k_i_remp)) begin
    //             Coeff_eta_o = 0;
    //         end
    //         else if (k_i == 2) Coeff_eta_o = 1;
    //         else Coeff_eta_o = 0;
    //     end
    //     else Coeff_eta_o = 0;
    // end 
    assign Coeff_eta_o =
                        (gk_ena_i & ~ec_ena_i & (k_i == 2)) |
                        (~gk_ena_i & ec_ena_i & (k_i == 2) & ~(runtimes_i > k_i_remp));
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/

    always @(posedge clk_i) begin
        if (rst_i) begin
            ena_hash_o      <= 0;
            next_hash_o     <= 0;
            rst_hash_o      <= 0;
            ena_gen_o       <= 0;
            next_gen_o      <= 0;
            //
            rho_reg         <= 0;
            idx             <= 2'b11;
            state           <= IDLE;  
            first           <= 0; 
        end
        else begin
            case (state)
                IDLE: begin
                    if (ena_i) begin
                        if (~first) begin
                            rho_reg <= sigma_i;
                            first   <= 1'b1;
                        end 
                        if (!rst_hash_o) begin 
                            state       <= DATA;
                            ena_hash_o  <= 1'b1;
                        end
                    end
                    if (NTT_done_compute_i) rst_hash_o  <= 0;
                    // if (gk_ena_i & ~ec_ena_i) begin
                    //     if (NTT_done_compute_i) rst_hash_o  <= 0;
                    // end
                    // else if (~gk_ena_i & ec_ena_i) begin
                    //     if (runtimes_i > k_i_remp) begin
                            
                    //     end
                    // end
                    
                end
                DATA: begin
                    if (!(|idx)) begin
                        ena_gen_o   <= 1'b1;
                        ena_hash_o  <= 1'b0;
                        // next_gen_o  <= 1'b1;
                        idx         <= 2'b11;
                        state       <= WAIT;
                    end
                    else begin 
                        ena_hash_o  <= 1'b1;
                        idx         <= idx - 2'b01;
                    end
                    // if(~idx[1] & idx[0]) 
                    //     ena_gen_o   <= 1'b1;
                    // else 
                    //     ena_gen_o   <= 1'b0;
                end
                WAIT: begin
                    ena_gen_o       <= 1'b0;
                    next_gen_o      <= ena_gen_o;
                    if (rst_hash_i) begin
                        rst_hash_o <= rst_hash_i;
                        state <= IDLE;
                        next_hash_o <= 1'b0;
                    end
                    else if (cnext_hash_i & ~rst_hash_i) begin
                        state <= NEXT;
                        next_hash_o <= 1'b1;
                    end
                end
                NEXT: begin
                    next_hash_o     <= 1'b0;
                    state           <= WAIT;
                end
                default: state <= state;
            endcase
        end
    end
endmodule
