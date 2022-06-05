//==============================================
// top
//==============================================
module top
(
    input clk_100mhz,
    input [15:0] sw,
    input btnc,
    input btnu,
    input btnl,
    input btnr,
    input btnd,
    // output logic [15:0] led,        //little LEDs above switches
    output logic led16_b    //blue channel left RGB LED
    // output logic led16_g,    //green channel left RGB LED
    // output logic led16_r,    //red channel left RGB LED
    // output logic led17_b,    //blue channel right RGB LED
    // output logic led17_g,    //green channel right RGB LED
    // output logic led17_r,    //red channel right RGB LED
    output logic [7:0] an,
    output logic ca, 
    output logic cb, 
    output logic cc, 
    output logic cd, 
    output logic ce, 
    output logic cf, 
    output logic cg
);

logic btnc__clean;
logic btnu__clean;
logic btnd__clean;
logic btnl__clean;
logic btnr__clean;
logic [15:0] sw__clean;
logic [63:0] port__0;
logic [63:0] port__1;

logic [7:0] en;
PYTHON(for i in range(8): print(f"logic [3:0] n__{i};"))



assign clk = clk_100mhz;
assign rst = btnc__clean;



//==============================
// jay__0
//==============================
jay jay__0
(
    .clk(clk),
    .rst(rst),
    .port__0(port__0),
    .port__1(port__1)
);

//==============================
// seven_segment_display__0
//==============================
seven_segment_display seven_segment_display__0
(
    .clk(clk),
    .rst(rst),
    .en(en),
    .n__0(n__0), 
    .n__1(n__1), 
    .n__2(n__2), 
    .n__3(n__3), 
    .n__4(n__4), 
    .n__5(n__5), 
    .n__6(n__6), 
    .n__7(n__7),
    .an(an),
    .ca(ca), 
    .cb(cb), 
    .cc(cc), 
    .cd(cd), 
    .ce(ce), 
    .cf(cf), 
    .cg(cg)
);

assign en = 8'hff;
PYTHON(for i in range(8): print(f"assign n__{i} = port__0[{i*8 + 7}:{i*8}];"))




//==============================
// debouncer__btnc
//==============================
debouncer debouncer__btnc
(
    .clk(clk),
    .rst(rst),
    .in(btnc),
    .out(btnc__clean)
);

//==============================
// debouncer__btnu
//==============================
debouncer debouncer__btnu
(
    .clk(clk),
    .rst(rst),
    .in(btnu),
    .out(btnu__clean)
);

//==============================
// debouncer__btnd
//==============================
debouncer debouncer__btnd
(
    .clk(clk),
    .rst(rst),
    .in(btnd),
    .out(btnd__clean)
);

//==============================
// debouncer__btnl
//==============================
debouncer debouncer__btnl
(
    .clk(clk),
    .rst(rst),
    .in(btnl),
    .out(btnl__clean)
);

//==============================
// debouncer__btnr
//==============================
debouncer debouncer__btnr
(
    .clk(clk),
    .rst(rst),
    .in(btnr),
    .out(btnr__clean)
);

PYTHON
(
for i in range(16):
    print(f"//==============================")
    print(f"// debouncer__sw__{i}")
    print(f"//==============================")
    print(f"debouncer debouncer__sw__{i}")
    print(f"(")
    print(f"    .clk(clk),")
    print(f"    .rst(rst),")
    print(f"    .in(sw[{i}]),")
    print(f"    .out(sw__clean[{i}])")
    print(f");")

    if i != 15:
        print("")
)







endmodule
