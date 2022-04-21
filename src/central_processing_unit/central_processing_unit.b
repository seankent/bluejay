//==============================================
// central_processing_unit
//==============================================
module central_processing_unit
(
    input clk,
    input rst
);

//==============================================
// Intruction Fetch (IF)
//==============================================
logic IF__valid;
logic IF__ready;                         
logic [63:0] IF__pc;
logic [63:0] IF__pc_n;
logic [31:0] IF__ir;

// IF pipe stage.
always_ff @(posedge clk) begin
    if (rst) begin
        IF__pc <= 64'h0;
    end
    else if (IF__ready) begin
        IF__pc <= IF__pc_n;
    end
end

// Select the next pc.
always_comb begin
    IF__pc_n = IF__pc + 4;
end

// TODO
assign IF__valid = 1'b1;
assign IF__ir = NOP;

//==============================================
// Instruction Decode (ID)
//==============================================  
logic ID__valid;
logic ID__ready;
logic [63:0] ID__pc;
logic [31:0] ID__ir;
logic [5:0] ID__op;
logic [3:0] ID__func;
logic [4:0] ID__rd_addr__0;
logic [4:0] ID__rd_addr__1;
logic [4:0] ID__wr_addr;
logic [63:0] ID__imm;
logic ID__we;
logic ID__sel__a;
logic ID__sel__b;
logic [1:0] ID__sel__wr_data;
logic [63:0] ID__rd_data__0;
logic [63:0] ID__rd_data__1;

// IF/ID pipe stage (valid).
always_ff @(posedge clk) begin
    if (rst) begin
        ID__valid <= 1'b0;
    end
    else begin
        ID__valid <= ID__ready ? IF__valid : ID__valid;
    end
end

// IF/ID pipe stage (data).
always_ff @(posedge clk) begin
    if (IF__valid && ID__ready) begin
        ID__pc <= IF__pc;
        ID__ir <= IF__ir;
    end
end

//==============================
// decoder
//==============================
decoder decoder__0
(
    .clk(clk),
    .rst(rst),
    .ir(ID__ir),
    .op(ID__op),
    .func(ID__func),
    .rd_addr__0(ID__rd_addr__0),
    .rd_addr__1(ID__rd_addr__1),
    .wr_addr(ID__wr_addr),
    .imm(ID__imm),
    .we(ID__we),
    .sel__a(ID__sel__a),
    .sel__b(ID__sel__b),
    .sel__wr_data(ID__sel__wr_data)
);

//==============================
// register_file
//==============================
register_file register_file__0
(
    .clk(clk),
    .rst(rst),
    .we(WB__we & WB__valid),
    .rd_addr__0(ID__rd_addr__0),
    .rd_data__0(ID__rd_data__0),
    .rd_addr__1(ID__rd_addr__1),
    .rd_data__1(ID__rd_data__1),
    .wr_addr(WB__wr_addr),
    .wr_data(WB__wr_data)
);

//==============================================
// Execute (EX)
//==============================================
logic EX__valid;
logic EX__ready;
logic [63:0] EX__pc;
logic [31:0] EX__ir;
logic [5:0] EX__op;
logic [3:0] EX__func;
logic [4:0] EX__wr_addr;
logic [63:0] EX__imm;
logic EX__we;
logic EX__sel__a;
logic EX__sel__b;
logic [1:0] EX__sel__wr_data;
logic [63:0] EX__rd_data__0;
logic [63:0] EX__rd_data__1;
logic [63:0] EX__a;
logic [63:0] EX__b;
logic [63:0] EX__c;
logic EX__eq;
logic EX__ne;
logic EX__lt;
logic EX__ltu;
logic EX__ge;
logic EX__geu;


// IF/ID pipe stage (valid).
always_ff @(posedge clk) begin
    if (rst) begin
        EX__valid <= 1'b0;
    end
    else begin
        EX__valid <= EX__ready ? ID__valid : EX__valid;
    end
end

// IF/ID pipe stage (data).
always_ff @(posedge clk) begin
    if (ID__valid && EX__ready) begin
        EX__pc <= ID__pc;
        EX__ir <= ID__ir;
        EX__op <= ID__op;
        EX__func <= ID__func;
        EX__wr_addr <= ID__wr_addr;
        EX__imm <= ID__imm;
        EX__we <= ID__we;
        EX__sel__a <= ID__sel__a;
        EX__sel__b <= ID__sel__b;
        EX__sel__wr_data <= ID__sel__wr_data;
        EX__rd_data__0 <= ID__rd_data__0;
        EX__rd_data__1 <= ID__rd_data__1;
    end
end

//==============================
// arithmetic_logic_unit
//==============================
arithmetic_logic_unit arithmetic_logic_unit__0
(
    .clk(clk),
    .rst(rst),
    .func(EX__func),
    .a(EX__a),
    .b(EX__b),
    .c(EX__c),
);

//==============================
// comparator
//==============================
comparator comparator__0
(
    .clk(clk),
    .rst(rst),
    .a(EX__rd_data__0),
    .b(EX__rd_data__0),
    .eq(EX__eq),
    .ne(EX__ne),
    .lt(EX__lt),
    .ltu(EX__ltu),
    .ge(EX__ge),
    .geu(EX__geu)
);

// Select a (input to ALU).
always_comb begin
    case (sel__a)
        SEL__A__RD_DATA__0:
        begin
            EX__a = EX__rd_data__0;
        end
        SEL__A__PC:
        begin
            EX__a = EX__pc;
        end
    endcase
end

// Select b (input to ALU).
always_comb begin
    case (sel__b)
        SEL__B__RD_DATA__1:
        begin
            EX__b = EX__rd_data__1;
        end
        SEL__B__IMM:
        begin
            EX__b = EX__imm;
        end
    endcase
end

//==============================================
// Memory (MEM)
//==============================================
logic MEM__ready;
logic [63:0] MEM__pc;
logic [31:0] MEM__ir;
logic MEM__we;
logic [4:0] MEM__rd;
logic [1:0] MEM__sel__rd_data;
logic [3:0] MEM__ctrl_flow;
logic [63:0] MEM__imm;
logic [63:0] MEM__rs2_data;
logic [63:0] MEM__data_2;
logic [63:0] MEM__mem_data;
logic MEM__eq;
logic MEM__ne;
logic MEM__lt;
logic MEM__ltu;
logic MEM__ge;
logic MEM__geu;
logic MEM__take_branch;
logic [63:0] MEM__branch_pc;

// EX/MEM pipe stage.
always_ff @(posedge clk) begin
    if (rst | MEM__take_branch) {MEM__we, MEM__ctrl_flow} <= {1'b0, CTRL_FLOW__PC_PLUS_FOUR};
    else if (MEM__ready) {MEM__pc, MEM__ir, MEM__we, MEM__rd, MEM__rs2_data, MEM__data_2, MEM__sel__rd_data, MEM__eq, MEM__ne, MEM__lt, MEM__ltu, MEM__ge, MEM__geu} <= {EX__pc, EX__ir, EX__we, EX__rd, EX__rs2_data, EX__data_2, EX__sel__rd_data, EX__eq, EX__ne, EX__lt, EX__ltu, EX__ge, EX__geu};
end

assign MEM__ready = 1'b1;
assign MEM__branch_pc = (MEM__ctrl_flow == CTRL_FLOW__JALR) ? MEM__data_2 : MEM__pc + MEM__imm;
always_comb begin
    case (MEM__ctrl_flow)
        CTRL_FLOW__PC_PLUS_FOUR: MEM__take_branch = 1'b0;
        CTRL_FLOW__JAL: MEM__take_branch = 1'b1;
        CTRL_FLOW__JALR: MEM__take_branch = 1'b1;
        CTRL_FLOW__BEQ: MEM__take_branch = MEM__eq;
        CTRL_FLOW__BNE: MEM__take_branch = MEM__ne;
        CTRL_FLOW__BLT: MEM__take_branch = MEM__lt;
        CTRL_FLOW__BLTU: MEM__take_branch = MEM__ltu;
        CTRL_FLOW__BGE: MEM__take_branch = MEM__ge;
        CTRL_FLOW__BGEU: MEM__take_branch = MEM__geu;
    endcase
end

//==============================================
// Write Back (WB)
//==============================================
logic [63:0] WB__pc;
logic [31:0] WB__ir;
logic WB__we;
logic [4:0] WB__rd;
logic [1:0] WB__sel__rd_data;
logic [63:0] WB__data_2;
logic [63:0] WB__mem_data;
logic [63:0] WB__rd_data;
logic WB__ready;

// MEM/WB pipe stage.
always_ff @(posedge clk) begin
    if (rst) {WB__we} <= {1'b0};
    else if (WB__ready) {WB__pc, WB__ir, WB__we, WB__rd, WB__data_2, WB__sel__rd_data, WB__mem_data} <= {MEM__pc, MEM__ir, MEM__we, MEM__rd, MEM__data_2, MEM__sel__rd_data, MEM__mem_data};
end

always_comb begin
    case (WB__sel__rd_data)
        SEL__RD_DATA__ALU: WB__rd_data = WB__data_2;
        SEL__RD_DATA__MEM: WB__rd_data = WB__mem_data;
        SEL__RD_DATA__PC_PLUS_FOUR: WB__rd_data = WB__pc + 4;
    endcase
end


endmodule
