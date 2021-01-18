`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/28/2020 07:01:35 AM
// Design Name:
// Module Name: TB
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module TB();

reg IRDY, FRAME, reset;
wire DEVSEL, TRDY, AD_direction;
reg [3:0] CBE;
reg [31:0] AD;
//wire [31:0] AD_out;
wire [31:0] AD_bus;

assign AD_bus = (AD_direction)? AD: 32'bz;

reg CLK;
always begin
#5 CLK = ~CLK;
end

TargetDevice TD(.AD(AD_bus), .CBE(CBE), .FRAME(FRAME), .clock(CLK), .IRDY(IRDY), .AD_direction(AD_direction),
 .DEVSEL(DEVSEL), .TRDY(TRDY), .reset(reset));

initial begin
CLK=1;reset=0; FRAME = 1; AD=32'bz; CBE=4'bz; IRDY= 1;

#1
reset=1;
#1
reset=0;

#3 //neg 1
FRAME = 0; AD=2; CBE=4'b0111; IRDY= 1;

#10 //neg 2
FRAME = 0; AD=10; CBE=4'b1111; IRDY= 0;

#10 //neg 3
FRAME = 0; AD=10; CBE=4'b1111; IRDY= 0;

#10 //neg 4
FRAME = 0; AD=11; CBE=4'b1111; IRDY= 0;

#10 //neg 5
FRAME = 0; AD=11; CBE=4'b1111; IRDY= 0;

#10 //neg 5
FRAME = 0; AD=11; CBE=4'b1111; IRDY= 0;

#10 //neg 5
FRAME = 0; AD=12; CBE=4'b1111; IRDY= 0;

#10 //neg 6
FRAME = 1; AD=13; CBE=4'b1111; IRDY= 0;

#10 //neg 7
FRAME = 1; AD=32'bz; CBE=4'b1111; IRDY= 1;


//read transaction
#10 //neg 8 (1)
FRAME = 0; AD = 2; CBE = 4'b0110; IRDY = 1;

#10 //neg 9 (2)
FRAME = 0; AD = 32'bz; CBE = 4'b1111; IRDY = 0;

#10 //neg 9 (3)
FRAME = 0; AD = 32'bz; CBE = 4'b1111; IRDY = 0;

#10 //neg 9 (4)
FRAME = 0; AD = 32'bz; CBE = 4'b1111; IRDY = 0;

#10 //neg 9 (5)
FRAME = 0; AD = 32'bz; CBE = 4'b1111; IRDY = 0;

#10 //neg 9 (6)
FRAME = 0; AD = 32'bz; CBE = 4'b1111; IRDY = 1;

#10 //neg 9 (7)
FRAME = 1; AD = 32'bz; CBE = 4'b1111; IRDY = 0;

#10 //neg 9 (8)
FRAME = 1; AD = 32'bz; CBE = 4'b1111; IRDY = 1;

end

endmodule
