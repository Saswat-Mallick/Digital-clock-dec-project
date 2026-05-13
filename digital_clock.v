module digital_clock( output [6:0] seg, output [3:0] an, output dp, output [7:0]led,
                      input clk, input reset, input show_sec, input lshift_btn, input load, input rshift_btn, input inc_btn, input dec_btn, input alarm);

    // State memory block

    reg rshift_next, inc_next, dec_next, lshift_next;
    always @(posedge clk) 
    begin
        rshift_next <= rshift_btn;
        inc_next <= inc_btn;
        dec_next <= dec_btn;
        lshift_next <= lshift_btn;
    end

    wire rshift_pulse = rshift_btn & ~rshift_next; // value updates iff change is detected
    wire inc_pulse = inc_btn & ~inc_next;
    wire dec_pulse = dec_btn & ~dec_next;
    wire lshift_pulse = lshift_btn & ~lshift_next;

    // Main counter clock

    wire clk1Hz;
    clock_divider cd(.clk(clk), .clkout(clk1Hz));

    reg clk1Hz_next;
    always @(posedge clk) clk1Hz_next <= clk1Hz;
    wire sec_tick = clk1Hz & ~clk1Hz_next;

    // Blink clock

    reg [24:0] blink_cnt;
    always @(posedge clk) blink_cnt <= blink_cnt + 1;
    wire blink = blink_cnt[24];

    // Selected field

    reg [1:0] sel_field;
    always @(posedge clk) 
    begin
        if (reset || ~load) sel_field <= 0;
        else if (load && ~alarm) 
            begin
                if (rshift_pulse) 
                    begin
                        if (sel_field == 2'd2) sel_field <= 0;
                        else                   sel_field <= sel_field + 1;
                    end 
                else if (lshift_pulse) 
                    begin
                        if (sel_field == 2'd0) sel_field <= 2'd2;
                        else                   sel_field <= sel_field - 1;
                    end
            end
    end

    // Alarm Selected field

    reg al_sel_field;
    assign al_reset = al_load & reset;
    assign al_load = alarm & load;
    always @(posedge clk) 
    begin
        if (al_reset) al_sel_field <= 0;
        else if (al_load && (rshift_pulse || lshift_pulse)) al_sel_field <= ~al_sel_field;
    end

    // Output logic block

    // Seconds of clock

    reg [3:0] sec_units;
    reg [2:0] sec_tens;

    wire sec_inc = load && ~alarm && inc_pulse && (sel_field == 2'd2);
    wire sec_dec = load && ~alarm && dec_pulse && (sel_field == 2'd2);

    wire sec_rollover = (sec_tens == 3'd5) && (sec_units == 4'd9);
    wire sec_u_tick = ~load & sec_tick;

    always @(posedge clk) 
    begin
        if (reset) 
            begin
                sec_units <= 0; sec_tens <= 0;
            end 
        else if (sec_inc || sec_u_tick) 
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
        else if (sec_dec) 
            begin
                if (sec_units == 4'd0 && sec_tens == 3'd0) 
                    begin
                        sec_units <= 4'd9; sec_tens <= 3'd5;
                    end 
                else if (sec_units == 4'd0) 
                    begin
                        sec_units <= 4'd9; sec_tens <= sec_tens - 1;
                    end 
                else sec_units <= sec_units - 1;
            end 
    end

    wire min_tick = sec_u_tick & sec_rollover;

  
    // Minutes of clock
 
    reg [3:0] min_units;
    reg [2:0] min_tens;

    wire min_inc = load && ~alarm && inc_pulse && (sel_field == 2'd1);
    wire min_dec = load && ~alarm && dec_pulse && (sel_field == 2'd1);
    wire min_rollover = (min_tens == 3'd5) && (min_units == 4'd9);

    always @(posedge clk) 
    begin
        if (reset) 
            begin
                min_units <= 0; min_tens <= 0;
            end 
        else if (min_inc || min_tick) 
            begin
                if (min_rollover) 
                    begin
                        min_units <= 0; min_tens <= 0;
                    end 
                else if (min_units == 4'd9) 
                    begin
                        min_units <= 0; min_tens <= min_tens + 1;
                    end 
                else min_units <= min_units + 1;
            end 
        else if (min_dec) 
            begin
                if (min_units == 4'd0 && min_tens == 3'd0) 
                    begin
                        min_units <= 4'd9; min_tens <= 3'd5;
                    end 
                else if (min_units == 4'd0) 
                    begin
                        min_units <= 4'd9; min_tens <= min_tens - 1;
                    end 
                else min_units <= min_units - 1;
            end 
    end

    wire hr_tick = min_tick & min_rollover;

 
    // Hours of clock
 
    reg [3:0] hr_units;
    reg [1:0] hr_tens;

    wire hr_inc = load && ~alarm && inc_pulse && (sel_field == 2'd0);
    wire hr_dec = load && ~alarm && dec_pulse && (sel_field == 2'd0);
    wire hr_rollover = (hr_tens == 2'd2) && (hr_units == 4'd3);

    always @(posedge clk) 
    begin
        if (reset) 
            begin
                hr_units <= 0; hr_tens <= 0;
            end 
        else if (hr_inc || hr_tick) 
            begin
                if (hr_rollover) 
                    begin
                        hr_units <= 0; hr_tens <= 0;
                    end 
                else if (hr_units == 4'd9) 
                    begin
                        hr_units <= 0; hr_tens <= hr_tens + 1;
                    end 
                else hr_units <= hr_units + 1;
            end 
        else if (hr_dec) 
            begin
                if (hr_units == 4'd0 && hr_tens == 2'd0) 
                    begin
                        hr_units <= 4'd3; hr_tens <= 2'd2;
                    end 
                else if (hr_units == 4'd0) 
                    begin
                        hr_units <= 4'd9; hr_tens <= hr_tens - 1;
                    end 
                else hr_units <= hr_units - 1;
            end 
    end

    // Hours of alarm clock
 
    reg [3:0] al_hr_units;
    reg [1:0] al_hr_tens;

    wire al_hr_inc = al_load && inc_pulse && (al_sel_field == 2'd0);
    wire al_hr_dec = al_load && dec_pulse && (al_sel_field == 2'd0);
    wire al_hr_rollover = (al_hr_tens == 2'd2) && (al_hr_units == 4'd3);

    always @(posedge clk)
    begin
        if (al_reset) 
            begin
                al_hr_units <= 0; al_hr_tens <= 0;
            end 
        else if (al_hr_inc) 
            begin
                if (al_hr_rollover) 
                    begin
                        al_hr_units <= 0; al_hr_tens <= 0;
                    end 
                else if (al_hr_units == 4'd9) 
                    begin
                        al_hr_units <= 0; al_hr_tens <= al_hr_tens + 1;
                    end 
                else al_hr_units <= al_hr_units + 1;
            end 
        else if (al_hr_dec) 
            begin
                if (al_hr_units == 4'd0 && al_hr_tens == 2'd0) 
                    begin
                        al_hr_units <= 4'd3; al_hr_tens <= 2'd2;
                    end 
                else if (al_hr_units == 4'd0) 
                    begin
                        al_hr_units <= 4'd9; al_hr_tens <= al_hr_tens - 1;
                    end 
                else al_hr_units <= al_hr_units - 1;
            end 
    end

    // Minutes for alarm clock
 
    reg [3:0] al_min_units;
    reg [2:0] al_min_tens;

    wire al_min_inc = al_load && inc_pulse && (al_sel_field == 2'd1);
    wire al_min_dec = al_load && dec_pulse && (al_sel_field == 2'd1);
    wire al_min_rollover = (al_min_tens == 3'd5) && (al_min_units == 4'd9);

    always @(posedge clk) 
    begin
        if (al_reset) 
            begin
                al_min_units <= 0; al_min_tens <= 0;
            end 
        else if (al_min_inc) 
            begin
                if (al_min_rollover) 
                    begin
                        al_min_units <= 0; al_min_tens <= 0;
                    end 
                else if (al_min_units == 4'd9) 
                    begin
                        al_min_units <= 0; al_min_tens <= al_min_tens + 1;
                    end 
                else al_min_units <= al_min_units + 1;
            end 
        else if (al_min_dec) 
            begin
                if (al_min_units == 4'd0 && al_min_tens == 3'd0) 
                begin
                    al_min_units <= 4'd9; al_min_tens <= 3'd5;
                end 
                else if (al_min_units == 4'd0) 
                begin
                    al_min_units <= 4'd9; al_min_tens <= al_min_tens - 1;
                end 
                else al_min_units <= al_min_units - 1;
            end 
    end

    // =====================
    // CLOCK BLINK MASK
    // =====================
    wire [3:0] hr_t_disp = (load && sel_field == 2'd0 && blink) ? 4'hF : {2'b00, hr_tens};
    wire [3:0] hr_u_disp = (load && sel_field == 2'd0 && blink) ? 4'hF : hr_units;
    wire [3:0] min_t_disp = (load && sel_field == 2'd1 && blink) ? 4'hF : {1'b0, min_tens};
    wire [3:0] min_u_disp = (load && sel_field == 2'd1 && blink) ? 4'hF : min_units;
    wire [3:0] sec_t_disp = (load && sel_field == 2'd2 && blink) ? 4'hF : {1'b0, sec_tens};
    wire [3:0] sec_u_disp = (load && sel_field == 2'd2 && blink) ? 4'hF : sec_units;

    // =====================
    // ALARM BLINK MASK
    // =====================
    wire [3:0] al_hr_t_disp = (al_load && al_sel_field==2'd0 && blink) ? 4'hF : {2'b00, al_hr_tens};
    wire [3:0] al_hr_u_disp = (al_load && al_sel_field==2'd0 && blink) ? 4'hF : al_hr_units;
    wire [3:0] al_min_t_disp = (al_load && al_sel_field==2'd1 && blink) ? 4'hF : {1'b0, al_min_tens};
    wire [3:0] al_min_u_disp = (al_load && al_sel_field==2'd1 && blink) ? 4'hF : al_min_units;

    // DISPLAY PACK

    wire show_sec_active = show_sec | (load & ~alarm & (sel_field == 2'd2));

    wire al_out = alarm && (al_min_units == min_units) && (al_min_tens == min_tens) && (al_hr_units == hr_units) && (al_hr_tens == hr_tens);

    wire fb_display,fb;

    myDff d1(.q(led[3]),.qbar(),.d(fb_display),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());
    myDff d2(.q(led[2]),.qbar(),.d(led[3]),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());
    myDff d3(.q(led[1]),.qbar(),.d(led[2]),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());
    myDff d4(.q(led[0]),.qbar(fb_display),.d(led[1]),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());

    myDff d5(.q(led[4]),.qbar(),.d(fb),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());
    myDff d6(.q(led[5]),.qbar(),.d(led[4]),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());
    myDff d7(.q(led[6]),.qbar(),.d(led[5]),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());
    myDff d8(.q(led[7]),.qbar(fb),.d(led[6]),.clk(clk1Hz),.rst(~al_out),.load(1'b0),.d_load());    

    wire [15:0] display_in = show_sec_active ? {4'd15, 4'd15, sec_t_disp, sec_u_disp} :
                al_load ? {al_hr_t_disp, al_hr_u_disp, al_min_t_disp, al_min_u_disp} : {hr_t_disp, hr_u_disp, min_t_disp, min_u_disp};
    wire colon_on = load ? clk1Hz : 1'b1;
    hex_display disp( .clk(clk), .reset(reset), .x(display_in), .seg(seg), .an(an), .colon_on(colon_on), .dp(dp));

endmodule