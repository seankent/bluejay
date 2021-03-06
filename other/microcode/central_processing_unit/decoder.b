//==============================================
// decoder
//==============================================
module decoder
(
    input clk,
    input rst,
    input [31:0] ir,

    output logic [2:0] op,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [63:0] imm,
    output logic [3:0] func,
);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [1:0] instr_type;

// decode the instruction fields
assign opcode = ir[6:0];
assign rs1 = ir[19:15];
assign rs2 = ir[24:20];
assign rd = ir[11:7];
assign funct3 = ir[14:12];
assign funct7 = ir[31:25];


always_comb begin
    op = NOP;
    func = FUNC__ADD;

    case (opcode)
        7'h03:
        begin
            case (funct3)
                // lb
                3'h0:
                begin
                    op == OP__LB
                    instr_type = I_TYPE;
                    we = 1'b1;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__MEM;
                end
                // lh
                3'h1:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__MEM;
                end
                // lw
                3'h2:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__MEM;
                end
                // ld
                3'h3:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__MEM;
                end
                // lbu
                3'h4:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__MEM;
                end
                // lhu
                3'h5:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__MEM;
                end
                // lhu
                3'h6:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__MEM;
                end
            endcase
        end
        7'h0f:
        begin
            case (funct3)
                // fence
                3'h0:
                begin
                    instr_type = I_TYPE;
                end
                // fence.i
                3'h1:
                begin
                    instr_type = I_TYPE;
                end
            endcase
        end
        7'h13:
        begin
            case (funct3)
                // addi
                3'h0:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    func = FUNC__ADD;
                    sel__data_1 = SEL__DATA_1__IMM;
                end
                3'h1:
                begin
                    case (funct7)
                        // slli
                        7'h00:
                        begin
                            instr_type = I_TYPE;
                            we = 1'b1;
                            func = FUNC__SLL;
                            sel__data_1 = SEL__DATA_1__IMM;
                        end
                    endcase
                end
                // slti
                3'h2:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    func = FUNC__SLT;
                    sel__data_1 = SEL__DATA_1__IMM;
                end
                // sltiu
                3'h3:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    func = FUNC__SLTU;
                    sel__data_1 = SEL__DATA_1__IMM;
                end
                // xori
                3'h4:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    func = FUNC__XOR;
                    sel__data_1 = SEL__DATA_1__IMM;
                end
                3'h5:
                begin
                    case (funct7)
                        // srli
                        7'h00:
                        begin
                            instr_type = I_TYPE;
                            we = 1'b1;
                            func = FUNC__SRL;
                            sel__data_1 = SEL__DATA_1__IMM;
                        end
                        // srai
                        7'h20:
                        begin
                            instr_type = I_TYPE;
                            we = 1'b1;
                            func = FUNC__SRA;
                            sel__data_1 = SEL__DATA_1__IMM;
                        end
                    endcase
                end
                // ori
                3'h6:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    func = FUNC__OR;
                    sel__data_1 = SEL__DATA_1__IMM;
                end
                // andi
                3'h7:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    func = FUNC__AND;
                    sel__data_1 = SEL__DATA_1__IMM;
                end
            endcase
        end
        // auipc
        7'h17:
        begin
            instr_type = U_TYPE;
            we = 1'b1;
            func = FUNC__AND;
            sel__data_0 = SEL__DATA_0__PC;
            sel__data_1 = SEL__DATA_1__IMM;
        end
        7'h1b:
        begin
            case (funct3)
                // addiw
                3'h0:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    func = FUNC__ADDW;
                    sel__data_1 = SEL__DATA_1__IMM;
                end
                3'h1:
                begin
                    case (funct7)
                        // slliw
                        7'h00:
                        begin
                            instr_type = I_TYPE;
                            we = 1'b1;
                            func = FUNC__SLLW;
                            sel__data_1 = SEL__DATA_1__IMM;
                        end
                    endcase
                end
                3'h5:
                begin
                    case (funct7)
                        // srliw
                        7'h00:
                        begin
                            instr_type = I_TYPE;
                            we = 1'b1;
                            func = FUNC__SRLW;
                            sel__data_1 = SEL__DATA_1__IMM;
                        end
                        // sraiw
                        7'h00:
                        begin
                            instr_type = I_TYPE;
                            we = 1'b1;
                            func = FUNC__SRAW;
                            sel__data_1 = SEL__DATA_1__IMM;
                        end
                    endcase
                end
            endcase
        end
        7'h23:
        begin
            case (funct3)
                // sb
                3'h0:
                begin
                    instr_type = S_TYPE;
                end
                // sh
                3'h1:
                begin
                    instr_type = S_TYPE;
                end
                // sw
                3'h2:
                begin
                    instr_type = S_TYPE;
                end
                // sd
                3'h3:
                begin
                    instr_type = S_TYPE;
                end
            endcase
        end
        7'h33:
        begin
            case (funct3)
                3'h0:
                begin
                    case (funct7)
                        // add
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__ADD;
                        end
                        // sub
                        7'h20:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SUB;
                        end
                    endcase
                end
                3'h1:
                begin
                    case (funct7)
                        // sll
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SLL;
                        end
                    endcase
                end
                3'h2:
                begin
                    case (funct7)
                        // slt
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SLT;
                        end
                    endcase
                end
                3'h3:
                begin
                    case (funct7)
                        // sltu
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SLTU;
                        end
                    endcase
                end
                3'h4:
                begin
                    case (funct7)
                        // xor
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__XOR;
                        end
                    endcase
                end
                3'h5:
                begin
                    case (funct7)
                        // srl
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SRL;
                        end
                        // sra
                        7'h20:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SRA;
                        end
                    endcase
                end
                3'h6:
                begin
                    case (funct7)
                        // or
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__OR;
                        end
                    endcase
                end
                3'h7:
                begin
                    case (funct7)
                        // and
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__AND;
                        end
                    endcase
                end
            endcase
        end
        // lui
        7'h37:
        begin
            instr_type = U_TYPE;
            we = 1'b1;
        end
        7'h3b:
        begin
            case (funct3)
                3'h0:
                begin
                    case (funct7)
                        // addw
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__ADDW;
                        end
                        // subw
                        7'h20:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SUBW;
                        end
                    endcase
                end
                3'h1:
                begin
                    case (funct7)
                        // sllw
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SLLW;
                        end
                    endcase
                end
                3'h5:
                begin
                    case (funct7)
                        // srlw
                        7'h00:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SRLW;
                        end
                        // sraw
                        7'h20:
                        begin
                            instr_type = R_TYPE;
                            we = 1'b1;
                            func = FUNC__SRAW;
                        end
                    endcase
                end
            endcase
        end
        7'h63:
        begin
            case (funct3)
                // beq
                3'h0:
                begin
                    instr_type = B_TYPE;
                    ctrl_flow = CTRL_FLOW__BEQ;
                end
                // bne
                3'h1:
                begin
                    instr_type = B_TYPE;
                    ctrl_flow = CTRL_FLOW__BNE;
                end
                // blt
                3'h4:
                begin
                    instr_type = B_TYPE;
                    ctrl_flow = CTRL_FLOW__BLT;
                end
                // bge
                3'h5:
                begin
                    instr_type = B_TYPE;
                    ctrl_flow = CTRL_FLOW__BGE;
                end
                // bltu
                3'h6:
                begin
                    instr_type = B_TYPE;
                    ctrl_flow = CTRL_FLOW__BLTU;
                end
                // bgeu
                3'h7:
                begin
                    instr_type = B_TYPE;
                    ctrl_flow = CTRL_FLOW__BGEU;
                end
            endcase
        end
        7'h67:
        begin
            case (funct3)
                // jalr
                3'h0:
                begin
                    instr_type = I_TYPE;
                    we = 1'b1;
                    ctrl_flow = CTRL_FLOW__JALR;
                    sel__data_1 = SEL__DATA_1__IMM;
                    sel__rd_data = SEL__RD_DATA__PC_PLUS_FOUR;
                end
            endcase
        end
        // jal
        7'h6f:
        begin
            instr_type = J_TYPE;
            we = 1'b1;
            ctrl_flow = CTRL_FLOW__JAL;
            sel__rd_data = SEL__RD_DATA__PC_PLUS_FOUR;
        end
    endcase
end

// create the immediate value
always_comb begin
    case (instr_type)
        I_TYPE: imm = {{53{ir[31]}}, ir[30:25], ir[24:21], ir[20]};
        S_TYPE: imm = {{53{ir[31]}}, ir[30:25], ir[11:8], ir[7]};
        B_TYPE: imm = {{52{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
        U_TYPE: imm = {{33{ir[31]}}, ir[30:20], ir[19:12], 12'h0};
        J_TYPE: imm = {{44{ir[31]}}, ir[19:12], ir[20], ir[30:25], ir[24:21], 1'b0};
    endcase
end

endmodule
