//==============================================
// central_processing_unit
//==============================================
module central_processing_unit
(
    input clk,
    input rst,
    output logic [60:0] l1_to_mem__addr,
    output logic [63:0] l1_to_mem__wr_data,
    input [63:0] l1_to_mem__rd_data,
    output logic l1_to_mem__en,
    output logic l1_to_mem__we
);

// Program Counter/Instruction Register
logic [63:0] pc;
logic [63:0] pc__n;
logic [31:0] ir;
logic [31:0] ir__n;

// Decoder.
logic [5:0] op;
logic [3:0] func;
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
logic [63:0] imm;
logic [2:0] dtype;

// Register File.
logic we;
logic [63:0] rd_data__0;
logic [63:0] rd_data__1;
logic [63:0] wr_data;

// ALU.
logic [3:0] alu_func;
logic [63:0] a;
logic [63:0] b;
logic [63:0] c;

// Comparator.
logic eq;
logic ne;
logic lt;
logic ge;
logic ltu;
logic geu;

// Temp.
logic [63:0] temp;
logic [63:0] temp__n;

// L1.
logic cpu_to_l1__valid;
logic cpu_to_l1__ready;
logic cpu_to_l1__we;
logic [63:0] cpu_to_l1__addr;
logic [63:0] cpu_to_l1__wr_data;
logic [63:0] cpu_to_l1__rd_data;
logic [2:0] cpu_to_l1__dtype;


// FSM.
logic [5:0] state;
logic [5:0] state__n;



//==============================
// decoder__0
//==============================
decoder decoder__0
(
    .clk(clk),
    .rst(rst),
    .ir(ir),
    .op(op),
    .func(func),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .imm(imm),
    .dtype(dtype)
);

//==============================
// register_file__0
//==============================
register_file register_file__0
(
    .clk(clk),
    .rst(rst),
    .we(we),
    .rd_addr__0(rs1),
    .rd_data__0(rd_data__0),
    .rd_addr__1(rs2),
    .rd_data__1(rd_data__1),
    .wr_addr(rd),
    .wr_data(wr_data)
);

//==============================
// arithmetic_logic_unit__0
//==============================
arithmetic_logic_unit arithmetic_logic_unit__0
(
    .clk(clk),
    .rst(rst),
    .func(alu_func),
    .a(a),
    .b(b),
    .c(c)
);

//==============================
// comparator__0
//==============================
comparator comparator__0
(
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .eq(eq),
    .ne(ne),
    .lt(lt),
    .ltu(ltu),
    .ge(ge),
    .geu(geu)
);

//==============================
// l1__0
//==============================
l1 l1__0 
(
    .clk(clk),
    .rst(rst),
    .cpu_to_l1__valid(cpu_to_l1__valid),
    .cpu_to_l1__ready(cpu_to_l1__ready),
    .cpu_to_l1__we(cpu_to_l1__we),
    .cpu_to_l1__addr(cpu_to_l1__addr),
    .cpu_to_l1__wr_data(cpu_to_l1__wr_data),
    .cpu_to_l1__rd_data(cpu_to_l1__rd_data),
    .cpu_to_l1__dtype(cpu_to_l1__dtype),
    .l1_to_mem__addr(l1_to_mem__addr),
    .l1_to_mem__wr_data(l1_to_mem__wr_data),
    .l1_to_mem__rd_data(l1_to_mem__rd_data),
    .l1_to_mem__en(l1_to_mem__en),
    .l1_to_mem__we(l1_to_mem__we)
);




//==============================================
// Finite State Machine
//==============================================
localparam STATE__RESET = 6'h0;
localparam STATE__IF__REQ = 6'h1;
localparam STATE__IF__WAIT = 6'h2;
localparam STATE__ID = 6'h3;
localparam STATE__LOAD__REQ = 6'h4;
localparam STATE__LOAD__WAIT = 6'h5;
localparam STATE__STORE = 6'h6;
localparam STATE__REG_REG = 6'h7;
localparam STATE__REG_IMM = 6'h8;
localparam STATE__AUIPC = 6'h9;
localparam STATE__PC_PLUS_FOUR = 6'ha;
localparam STATE__JALR__MOVE_RS1_TO_TEMP = 6'hb;
localparam STATE__JALR__LINK = 6'hc;
localparam STATE__JALR__JUMP = 6'hd;
localparam STATE__JAL__LINK = 6'he;
localparam STATE__JAL__JUMP = 6'hf;
localparam STATE__BRANCH__COMPARE = 6'h10;
localparam STATE__ECALL = 6'h11;
localparam STATE__EBREAK = 6'h12;
localparam STATE__FENCE = 6'h13;
localparam STATE__FENCE_I = 6'h14;
localparam STATE__LUI = 6'h15;


always_comb begin
    we = 1'b0;
    wr_data = c;
    alu_func = 4'h0;
    a = rd_data__0;
    b = imm;
    cpu_to_l1__addr = c;
    cpu_to_l1__wr_data = rd_data__1;
    cpu_to_l1__valid = 1'b0;
    cpu_to_l1__we = 1'b0;
    cpu_to_l1__dtype = 3'h0;
    pc__n = pc;
    ir__n = ir;
    temp__n = temp;
    state__n = state;

    case (state)
        //==============================
        // STATE__RESET
        //==============================
        STATE__RESET:
        begin
            state__n = STATE__IF__REQ;
        end
        
        //==============================
        // STATE__IF__REQ
        //==============================
        STATE__IF__REQ:
        begin
            cpu_to_l1__valid = 1'b1;
            cpu_to_l1__addr = pc;
            cpu_to_l1__dtype = 3'h1;

            if (cpu_to_l1__ready) begin
                state__n = STATE__IF__WAIT;
            end
        end

        //==============================
        // STATE__IF__WAIT
        //==============================
        STATE__IF__WAIT:
        begin
            if (cpu_to_l1__ready) begin
                ir__n = cpu_to_l1__rd_data[31:0];
                state__n = STATE__ID;
            end
        end

        //==============================
        // STATE__ID
        //==============================
        STATE__ID:
        begin
            if ((op == 6'h2c) || (op == 6'h2d) || (op == 6'h2e) || (op == 6'h2f) || (op == 6'h30) || (op == 6'h31)) begin
                state__n = STATE__BRANCH__COMPARE;
            end
            else if (op == 6'h33) begin
                state__n = STATE__JAL__LINK;
            end
            else if (op == 6'h32) begin
                state__n = STATE__JALR__MOVE_RS1_TO_TEMP;
            end
            else if ((op == 6'h1c) || (op == 6'h27) || (op == 6'h25) || (op == 6'h24) || (op == 6'h1e) || (op == 6'h29) || (op == 6'h1f) || (op == 6'h20) || (op == 6'h23) || (op == 6'h2b) || (op == 6'h22) || (op == 6'h2a) || (op == 6'h1d) || (op == 6'h28) || (op == 6'h21)) begin
                state__n = STATE__REG_REG;
            end
            else if ((op == 6'ha) || (op == 6'h14) || (op == 6'h12) || (op == 6'h11) || (op == 6'hb) || (op == 6'h15) || (op == 6'hc) || (op == 6'hd) || (op == 6'h10) || (op == 6'h17) || (op == 6'hf) || (op == 6'h16) || (op == 6'he)) begin
                state__n = STATE__REG_IMM;
            end
            else if ((op == 6'h1) || (op == 6'h5) || (op == 6'h2) || (op == 6'h6) || (op == 6'h3) || (op == 6'h7) || (op == 6'h4)) begin
                state__n = STATE__LOAD__REQ;
            end
            else if ((op == 6'h18) || (op == 6'h19) || (op == 6'h1a) || (op == 6'h1b)) begin
                state__n = STATE__STORE;
            end
            else if (op == 6'h13) begin
                state__n = STATE__AUIPC;
            end
            else if (op == 6'h34) begin
                state__n = STATE__ECALL;
            end
            else if (op == 6'h35) begin
                state__n = STATE__EBREAK;
            end
            else if (op == 6'h8) begin
                state__n = STATE__FENCE;
            end
            else if (op == 6'h9) begin
                state__n = STATE__FENCE_I;
            end
            else if (op == 6'h26) begin
                state__n = STATE__LUI;
            end
        end

        //==============================
        // STATE__LOAD__REQ
        //==============================
        STATE__LOAD__REQ:
        begin
            a = rs1;
            b = imm;
            cpu_to_l1__valid = 1'b1;
            cpu_to_l1__addr = c;
            cpu_to_l1__dtype = dtype;

            if (cpu_to_l1__ready) begin
                state__n = STATE__LOAD__WAIT;
            end
        end

        //==============================
        // STATE__LOAD__WAIT
        //==============================
        STATE__LOAD__WAIT:
        begin
            if (cpu_to_l1__ready) begin
                wr_data = cpu_to_l1__rd_data;
                we = 1'b1;
                state__n = STATE__PC_PLUS_FOUR;
            end
        end

        //==============================
        // STATE__STORE
        //==============================
        STATE__STORE:
        begin
            a = rs1;
            b = imm;
            cpu_to_l1__valid = 1'b1;
            cpu_to_l1__addr = c;
            cpu_to_l1__wr_data = rd_data__1;
            cpu_to_l1__we = 1'b1;
            cpu_to_l1__dtype = dtype;

            if (cpu_to_l1__ready) begin
                state__n = STATE__PC_PLUS_FOUR;
            end
        end

        //==============================
        // STATE__REG_REG
        //==============================
        STATE__REG_REG:
        begin
            a = rd_data__0;
            b = rd_data__1;
            wr_data = c;
            we = 1'b1;
            alu_func = func;
            state__n = STATE__PC_PLUS_FOUR;
        end

        //==============================
        // STATE__REG_IMM
        //==============================
        STATE__REG_IMM:
        begin
            a = rd_data__0;
            b = imm;
            wr_data = c;
            we = 1'b1;
            alu_func = func;
            state__n = STATE__PC_PLUS_FOUR;
        end

        //==============================
        // STATE__AUIPC
        //==============================
        STATE__AUIPC:
        begin
            a = pc;
            b = imm;
            wr_data = c;
            we = 1'b1;
            alu_func = 4'h0;
            state__n = STATE__PC_PLUS_FOUR;
        end

        //==============================
        // STATE__PC_PLUS_FOUR
        //==============================
        STATE__PC_PLUS_FOUR:
        begin
            a = pc;
            b = 4;
            pc__n = c;
            state__n = STATE__IF__REQ;
        end

        //==============================
        // STATE__JALR__MOVE_RS1_TO_TEMP
        //==============================
        STATE__JALR__MOVE_RS1_TO_TEMP:
        begin
            temp__n = rd_data__1;
            state__n = STATE__JALR__LINK;
        end

        //==============================
        // STATE__JALR__LINK
        //==============================
        STATE__JALR__LINK:
        begin
            a = pc;
            b = 4;
            wr_data = c;
            we = 1'b1;
            state__n = STATE__JALR__JUMP;
        end

        //==============================
        // STATE__JALR__JUMP
        //==============================
        STATE__JALR__JUMP:
        begin
            a = temp;
            b = imm;
            pc__n = c;
            state__n = STATE__IF__REQ;
        end

        //==============================
        // STATE__JAL__LINK
        //==============================
        STATE__JAL__LINK:
        begin
            a = pc;
            b = 4;
            wr_data = c;
            we = 1'b1;
            state__n = STATE__JAL__JUMP;
        end

        //==============================
        // STATE__JAL__JUMP
        //==============================
        STATE__JAL__JUMP:
        begin
            a = pc;
            b = imm;
            pc__n = c;
            state__n = STATE__IF__REQ;
        end

        //==============================
        // STATE__BRANCH__COMPARE
        //==============================
        STATE__BRANCH__COMPARE:
        begin
            a = rd_data__0;
            b = rd_data__1;

            case (op)
                6'h2c:
                    state__n = eq ? STATE__JAL__JUMP : STATE__PC_PLUS_FOUR; 
                6'h2d:
                    state__n = ne ? STATE__JAL__JUMP : STATE__PC_PLUS_FOUR; 
                6'h2e:
                    state__n = lt ? STATE__JAL__JUMP : STATE__PC_PLUS_FOUR; 
                6'h2f:
                    state__n = ge ? STATE__JAL__JUMP : STATE__PC_PLUS_FOUR; 
                6'h30:
                    state__n = ltu ? STATE__JAL__JUMP : STATE__PC_PLUS_FOUR; 
                6'h31:
                    state__n = geu ? STATE__JAL__JUMP : STATE__PC_PLUS_FOUR; 
            endcase
        end

        //==============================
        // STATE__ECALL
        //==============================
        STATE__ECALL:
        begin
            state__n = STATE__ECALL;
        end

        //==============================
        // STATE__EBREAK
        //==============================
        STATE__EBREAK:
        begin
            state__n = STATE__EBREAK;
        end

        //==============================
        // STATE__FENCE
        //==============================
        STATE__FENCE:
        begin
            state__n = STATE__FENCE;
        end

        //==============================
        // STATE__FENCE_I
        //==============================
        STATE__FENCE_I:
        begin
            state__n = STATE__FENCE_I;
        end

        //==============================
        // STATE__LUI
        //==============================
        STATE__LUI:
        begin
            wr_data = imm;
            we = 1'b1;
            state__n = STATE__PC_PLUS_FOUR;
        end

    endcase
end


always_ff @(posedge clk) begin
    if (rst) begin
        state <= STATE__RESET;
    end
    else begin
        state <= state__n;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        pc <= 0;
    end
    else begin
        pc <= pc__n;
    end
end

always_ff @(posedge clk) begin
    ir <= ir__n;
end

always_ff @(posedge clk) begin
    temp <= temp__n;
end



endmodule
