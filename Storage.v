`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/27/2020 06:27:17 AM
// Design Name:
// Module Name: Storage
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



module Storage(data_out, RF_FULL, BUFF_FULL, STATUS, clock, BURST_MODE, BE, data_in, CMD, RESET, address);

input [31:0] data_in;
input [3:0] BE;
input [2:0] CMD;
input RESET, BURST_MODE, clock;
input [2:0] address;

output reg [2:0] STATUS;
output reg RF_FULL, BUFF_FULL;
output reg [31:0] data_out;

parameter [1:0] READ=2'b00, WRITE=2'b01, DETERM=2'b10; //commands

parameter [2:0] READING=3'b000, WRITING=3'b001, MAT_OP=3'b010, IDLE=3'b011;


reg [1:0] read_address;
reg [2:0] write_BUFF_address;
reg [1:0] write_RF_address;
reg [31:0] reg_file [0:7];
//reg [31:0] buffer [0:3];
reg [31:0] data_masked;


// extended and negation of byte enable
wire [31:0] EBE, EBEn;

assign EBE = {{8{BE[3]}}, {8{BE[2]}}, {8{BE[1]}}, {8{BE[0]}}};
assign EBEn = ~EBE;

//send this signal so the next cycle to be waiting
always @(write_RF_address) begin RF_FULL = (write_RF_address == 2) ? 1: 0; end
always @(write_BUFF_address) begin BUFF_FULL = (write_BUFF_address == 7) ? 1: 0; end


always @(negedge clock or posedge RESET) begin

    if(RESET) begin
        STATUS <= IDLE;
        data_out <= 32'bz;
        RF_FULL <=0;
        BUFF_FULL <=0;
        write_RF_address<=0;
        read_address <=0;
        write_BUFF_address <= 4;//starting address of the buffer

    end
    else begin

        if(CMD==WRITE) begin
            STATUS = WRITING;
            data_out = 32'bz;
            write_RF_address = (BURST_MODE==1) ? write_RF_address + 1 : address[1:0];

            //write_RF_address = (BURST_MODE==1) ? write_RF_address: address;

            data_masked = ((EBEn) & (reg_file[write_RF_address])) | ((EBE) & (data_in));
            reg_file[write_RF_address] = data_masked;
        end

        else if(CMD==READ) begin
            STATUS = READING;
            read_address = (BURST_MODE==1) ? read_address + 1 : address;
            data_out =  reg_file[read_address];
        end

        else if(CMD==DETERM) begin
            STATUS = MAT_OP;
            data_out = 32'bz;
            RF_FULL=0;
            //i hope that works
            //EX: if address is 8 then 8%8 is 0 +4 is 4 which is first address in the buffer
            write_BUFF_address = (BURST_MODE==1) ? (write_BUFF_address % 7) + 4 : address;
            reg_file[write_BUFF_address] = ( reg_file[0] * reg_file[3]) - ( reg_file[1] * reg_file[2]);
            //write_BUFF_address = write_BUFF_address + 1;
            //write_BUFF_address = (write_BUFF_address==8)? 4 : write_BUFF_address;

        end
        else begin
            STATUS <= IDLE;
            data_out <= 32'bz;
        end
    end
end

endmodule
