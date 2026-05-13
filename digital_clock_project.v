module digital_clock_project( output [6:0] seg, output [3:0] an, output dp, output [7:0] led,
                              input [1:0] mode, input clk, input reset,
                            input inc_btn, input dec_btn, input lshift_btn, input rshift_btn, input load, input show_sec, input hold);

    // Mode

    wire mode_clock = (mode == 2'b00);
    wire mode_alarm = (mode == 2'b01);
    wire mode_timer = (mode == 2'b10);
    wire mode_sw = (mode == 2'b11);

    // Per mode reset

    wire clk_reset = reset & (mode_clock | mode_alarm);
    wire tim_reset = reset & mode_timer;
    wire sw_reset = reset & mode_sw;

    // digital clock

    wire [6:0] clk_seg;
    wire [3:0] clk_an;
    wire clk_dp;
    wire [7:0] clk_led;

    digital_clock u_clock( .seg (clk_seg), .an (clk_an), .dp (clk_dp), .led (clk_led), .clk (clk), .reset (clk_reset),
                            .show_sec (show_sec & (mode_clock | mode_alarm)), .rshift_btn (rshift_btn & (mode_clock | mode_alarm)), .load (load & (mode_clock | mode_alarm)),
                            .lshift_btn (lshift_btn & (mode_clock | mode_alarm)), .inc_btn (inc_btn & (mode_clock | mode_alarm)),
                            .dec_btn (dec_btn & (mode_clock | mode_alarm)), .alarm (mode_alarm));

    // timer

    wire [6:0] tim_seg;
    wire [3:0] tim_an;
    wire tim_dp;
    wire [7:0] tim_led;

    timer u_timer( .seg (tim_seg), .an (tim_an), .dp (tim_dp), .led (tim_led), .clk (clk), .reset (tim_reset), .load (load & mode_timer),
                    .show_sec (show_sec & mode_timer), .rshift_btn (rshift_btn & mode_timer), .lshift_btn (lshift_btn & mode_timer), .inc_btn (inc_btn & mode_timer),
                    .dec_btn (dec_btn & mode_timer));

    // stopwatch

    wire [6:0] sw_seg;
    wire [3:0] sw_an;
    wire sw_dp;

    stopwatch u_sw( .seg (sw_seg), .an (sw_an), .dp (sw_dp), .clk (clk), .reset (sw_reset), .hold (hold & mode_sw), .show_cs(show_sec & mode_sw));

    // Output mux

    assign seg = mode_timer ? tim_seg : mode_sw ? sw_seg : clk_seg;
    assign an = mode_timer ? tim_an : mode_sw ? sw_an : clk_an;
    assign dp = mode_timer ? tim_dp : mode_sw ? sw_dp : clk_dp;
    assign led = mode_timer ? tim_led : mode_sw ? 8'b0 : clk_led;

endmodule