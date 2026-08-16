module CoeffNTT (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire    [1343:0]    data_i,
    input   wire                valid_i,

    
    output  wire    [191:0]     data_o,
    output  wire                valid_o,
    output  reg                 rdone_o,
    // output  logic               next_o,
    output  wire                done_o
);
    
    /*****************************************************************************
    *                               Local Parameter                              *
    *****************************************************************************/
    // localparam IDLE = 2'b00;
    // localparam READ = 2'b01;
    // localparam RUNN = 2'b10;
    // localparam NEXT = 2'b11;

    // logic [1:0] state;

    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/
    reg   first_done;
    reg   first_valid;
    reg   done_pre_sampling_reg;
    reg   done_sampling_reg;
    wire  valid_temp;
    wire  valid_reg;
    wire  rst_temp;
    // logic               next_o;
    // logic               rdone_o;
    // NTTSampleIn to NTTSamplePoly
    wire    [47:0]  data_pre_sampling;
    wire            valid_pre_sampling;
    wire            done_pre_sampling;
    
    // NTTSamplePoly to NTTSampleOut
    wire    [47:0]  data_sampling;
    wire    [3:0]   valid_sampling;
    wire            done_sampling;
    
    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/

    assign  done_o      =   done_sampling;
    // assign  next_o      =   done_pre_sampling & first_done & first_valid & ~done_pre_sampling_reg;
    assign  valid_o     =   valid_temp & ~done_sampling_reg;
    assign  rst_temp    =   rst_i | done_sampling;
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/
    always @(posedge clk_i) begin
                if (rst_i)                          rdone_o   <= 0;
        else    if (valid_i & done_pre_sampling)    rdone_o   <= 1;
        else                                        rdone_o   <= 0;
    end
    always @(posedge clk_i) begin
                if (rst_i)              first_done  <= 0;
        else    if (done_pre_sampling)  first_done  <= 1;
    end
    always @(posedge clk_i) begin
                if (rst_i)              first_valid   <= 0;
        else    if (valid_pre_sampling) first_valid   <= 1;
    end
    always @(posedge clk_i) begin
                if (rst_i)              done_pre_sampling_reg   <= 0;
        else    if (done_pre_sampling)  done_pre_sampling_reg   <= 1;
        else    if (valid_i)            done_pre_sampling_reg   <= 0;
    end
    always @(posedge clk_i) begin
                if (rst_i)              done_sampling_reg       <= 0;
        else    if (done_sampling)      done_sampling_reg       <= 1;
        else    if (done_pre_sampling)  done_sampling_reg       <= 0;
    end
    /*****************************************************************************
    *                              Internal Modules                             *
    *****************************************************************************/

    NTTSampleIn NTTSampleIn_m (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(data_i),
        .valid_i(valid_i),
        .data_o(data_pre_sampling),
        .valid_o(valid_pre_sampling),
        .done_o(done_pre_sampling)
    );

    NTTSamplePoly NTTSamplePoly_m (
        .data_i(data_pre_sampling),
        .valid_i(valid_pre_sampling),
        .data_o(data_sampling),
        .valid_o(valid_sampling)
    );

    NTTSampleOut NTTSampleOut(
       .clk_i(clk_i),
       .rst_i(rst_temp),
       .data_i(data_sampling),
       .valid_i(valid_sampling),
       .data_o(data_o),
       .valid_o(valid_temp),
       .done_o(done_sampling)
    );

endmodule
