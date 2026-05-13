module hex_display( input clk, input [15:0] x, input reset, input colon_on, output reg [6:0] seg, output reg [3:0] an, output reg dp);

    reg [17:0] refresh_cnt;
    wire [1:0] digit_sel = refresh_cnt [17:16];

    always @(posedge clk) 
    begin
        if(reset) refresh_cnt <= 0;
        else refresh_cnt <= refresh_cnt + 1;
    end

    reg [3:0] active_digit;

    always @(*) 
    begin
        case (digit_sel)
            2'd0: begin an = 4'b1110; active_digit = x[3:0]; dp = 1'b1; end
            2'd1: begin an = 4'b1101; active_digit = x[7:4]; dp = 1'b1; end
            2'd2: begin an = 4'b1011; active_digit = x[11:8]; dp = ~colon_on; end
            2'd3: begin an = 4'b0111; active_digit = x[15:12]; dp = 1'b1; end
        endcase
    end

    always @(*) 
    begin
        case(active_digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b1111111;
            4'hF: seg = 7'b0111111;
            default: seg = 7'b1111111;
        endcase
    end

endmodule