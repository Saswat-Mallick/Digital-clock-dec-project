module stopwatch( output [6:0] seg, output [3:0] an, output dp, input clk, input reset, input hold, input show_cs);

    // Centisecond clock

    reg [19:0] cs_cnt;
    wire cs_tick;

    always @(posedge clk)
    begin
        if (reset) cs_cnt <= 0;
        else if (cs_cnt == 20'd999999) cs_cnt <= 0;
        else cs_cnt <= cs_cnt + 1;
    end

    assign cs_tick = (cs_cnt == 20'd999999);

    // Centisecond of stopwatch

    reg [3:0] cs_units;
    reg [3:0] cs_tens;

    wire cs_rollover = (cs_tens == 4'd9) && (cs_units == 4'd9);

    always @(posedge clk)
    begin
        if (reset)
            begin
                cs_units <= 0; cs_tens <= 0;
            end
        else if (cs_tick)
            begin
                if (cs_rollover)
                    begin
                        cs_units <= 0; cs_tens <= 0;
                    end
                else if (cs_units == 4'd9)
                    begin
                        cs_units <= 0; cs_tens <= cs_tens + 1;
                    end
                else cs_units <= cs_units + 1;
            end
    end

    wire sec_tick = cs_tick & cs_rollover;

    // seconds of stopwatch

    reg [3:0] sec_units;
    reg [2:0] sec_tens;

    wire sec_rollover = (sec_tens == 3'd5) && (sec_units == 4'd9);

    always @(posedge clk) 
    begin
        if (reset) 
            begin
                sec_units <= 0; sec_tens <= 0;
            end 
        else if (sec_tick) 
            begin
                if (sec_rollover) 
                    begin
                        sec_units <= 0; sec_tens <= 0;
                    end 
                else if (sec_units == 4'd9) 
                    begin
                        sec_units <= 0; sec_tens <= sec_tens + 1;
                    end 
                else sec_units <= sec_units + 1;
            end
    end

    wire min_tick = sec_tick & sec_rollover;

    // Minutes of stopwatch

    reg [3:0] min_units;

    wire min_rollover = min_units == 4'd9;

    always @(posedge clk) 
    begin
        if (reset) min_units <= 0;
        else if (min_tick) 
            begin
                if (min_rollover) min_units <= 0;
                else min_units <= min_units + 1;
            end
    end

    // Hold function

    reg [3:0] held_cs_units; reg [3:0] held_cs_tens;
    reg [3:0] held_sec_units; reg [2:0] held_sec_tens;
    reg [3:0] held_min_units;

    reg hold_next;
    always @(posedge clk) hold_next <= hold;
    wire hold_pulse = hold & ~hold_next;

    always @(posedge clk) 
    begin
        if (hold_pulse) 
            begin
                held_cs_units <= cs_units; held_cs_tens <= cs_tens;
                held_sec_units <= sec_units; held_sec_tens <= sec_tens;
                held_min_units <= min_units;
            end
    end

    // MUX: live vs held values for display

    wire [3:0] d_cs_units = hold ? held_cs_units : cs_units;
    wire [3:0] d_cs_tens = hold ? held_cs_tens : cs_tens;
    wire [3:0] d_sec_units = hold ? held_sec_units : sec_units;
    wire [2:0] d_sec_tens = hold ? held_sec_tens : sec_tens;
    wire [3:0] d_min_units = hold ? held_min_units : min_units;

    // DISPLAY PACK

    wire [15:0] display_in = show_cs ? {4'd15, 4'd15, d_cs_tens, d_cs_units} : {4'd15, 4'd0, d_min_units, {1'b0, d_sec_tens}, d_sec_units};
    wire colon_on = 1'b1;
    hex_display disp( .clk(clk), .reset(reset), .x(display_in), .seg(seg), .an(an), .colon_on(colon_on), .dp(dp));

endmodule