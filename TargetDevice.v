`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/27/2020 06:27:17 AM
// Design Name:
// Module Name: Target Device
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

module TargetDevice(AD, CBE, FRAME, clock, IRDY, AD_direction, DEVSEL, TRDY, reset);

inout [31:0] AD;
input [3:0] CBE;
input clock;
output AD_direction, DEVSEL, TRDY; // AD_direction : the direction of AD, STOP: request for ending transaction
input reset;
input FRAME, IRDY;

wire [2:0] storage_address; //the address of the register in the storage device
wire [3:0] BE; //the byte enable to the storage device
wire BURST_MODE; //tells the storage to store bulk if 1 and once if 0
wire resetS; //the reset of the storage
wire [2:0] CMD; //the command to be send to the storage module
wire [31:0] Sdata; //data to storage
wire [2:0] STATUS;
wire [31:0] AD_bus;
wire [31:0] data_out;

assign AD = (AD_direction) ? AD_bus : data_out;

//device
StorageControl SC(.storage_address(storage_address), .BE(BE), .BURST_MODE(BURST_MODE),
.resetS(resetS), .CMD(CMD), .Sdata(Sdata), .AD_direction(AD_direction),
.DEVSEL(DEVSEL), .TRDY(TRDY), .reset(reset), .S_FULL(S_FULL), .B_FULL(B_FULL),
.FRAME(FRAME), .IRDY(IRDY), .AD(AD), .STATUS(STATUS), .clock(clock), .CBE(CBE));

Storage store(.data_in(Sdata), .BE(BE), .CMD(CMD), .BURST_MODE(BURST_MODE), .RESET(resetS), .clock(clock),
.address(storage_address), .data_out(data_out), .RF_FULL(S_FULL), .BUFF_FULL(B_FULL));

endmodule
