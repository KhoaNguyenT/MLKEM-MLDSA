module NTTSampler (
    input   wire            clk_i,
    input   wire            rst_i,
    input   wire            ena_i,
    input   wire            cnext_hash_i,
    input   wire            rst_hash_i,
    input   wire    [255:0] rho_i,
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
    localparam IDLE = 2'b00, DATA = 2'b01, WAIT = 2'b10, NEXT = 2'b11;

    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/

    assign data_o = rho_reg[(idx*64) +: 64];
    
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
                            rho_reg <= rho_i;
                            first   <= 1'b1;
                        end 
                        state       <= DATA;
                        ena_hash_o  <= 1'b1;
                    end
                    rst_hash_o  <= 0;
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
