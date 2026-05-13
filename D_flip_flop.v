`timescale 1ns / 1ps

module myDff(output reg q, output reg qbar, input d, input clk, input rst, input load, input d_load);
    initial q=0; initial qbar=1;
    always @(posedge clk or posedge rst or posedge load)
    begin
        if (rst)
            begin
                q <= 0;
                qbar <= 1;
            end
        else if (load)
            begin
                q <= d_load;
                qbar <= ~d_load;
            end
        else
            begin
                q <= d;
                qbar <= ~d;
            end
    end
endmodule