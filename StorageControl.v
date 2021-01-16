`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/27/2020 06:27:17 AM
// Design Name:
// Module Name: StorageControl
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


module StorageControl(
output reg [2:0] storage_address, //the address of the register in the storage device
output reg [3:0] BE, //the byte enable to the storage device
output BURST_MODE, //tells the storage to store bulk if 1 and once if 0
output resetS, //the reset of the storage
output reg [2:0] CMD, //the command to be send to the storage module
output reg [31:0] Sdata, //data to storage
output reg AD_direction, STOP, DEVSEL, TRDY,// AD_direction : the direction of AD, STOP: request for ending transaction
input clock, reset, S_FULL, B_FULL, //storage full, buffer full
input FRAME, IRDY,
input [31:0] AD,
input [3:0] CBE,
output reg [2:0] STATUS
//output reg [3:0] CBE_register
);
parameter DEVICE_NUM = 2'b00;
parameter READ=2'b00, WRITE=2'b01, DETERM=2'b10; //commands for storage
parameter IDLE=3'b000, READING=3'b001, WRITING=3'b010, WAITING=3'b011, ENDING=3'b100;//states
parameter MEM_READ = 4'b0110, MEM_WRITE = 4'b0111;//PCI commands

// registers to sense the output
reg [31:0] AD_register;
reg [3:0] CBE_register;


reg [31:0] address_register;
reg [3:0] PCI_CM; // stores the kind of the transaction

reg [2:0] state, next_state;

// both devices will have the same reset
assign resetS = reset;

// burst mode is off
assign BURST_MODE=0;


//synchronous block for state
always @(posedge clock or posedge reset) begin

    if(reset==1) begin
        state = IDLE;
        AD_register = 0;
        CBE_register = 0;
        address_register = 0;
        PCI_CM = 0;
    end
    else state = next_state;
end



always @(posedge clock) begin
    AD_register = AD;
    CBE_register = CBE;
    STATUS = state;
end

//states transition
always @(state or posedge clock)begin
    case (state)
        IDLE:begin
            if(AD_register > 3) next_state = IDLE;
            else begin
                if(CBE_register == MEM_READ)begin next_state = READING; PCI_CM = MEM_READ; end
                else if(CBE_register == MEM_WRITE)begin next_state = WRITING; PCI_CM = MEM_WRITE; end
                else next_state = IDLE;
            end
        end

        READING:begin
            if(FRAME==1) next_state = IDLE;
            else if(S_FULL == 1) next_state = WAITING;
            else if(B_FULL == 1) next_state = ENDING;
            else begin next_state = READING; end
        end

        WRITING:begin
            if(FRAME==1) next_state = IDLE;
            else if(S_FULL == 1) next_state = WAITING;
            else if(B_FULL == 1) next_state = ENDING;
            else begin next_state = WRITING; end
        end

        WAITING:begin
            if(S_FULL == 0)begin
                if(PCI_CM == MEM_READ) next_state = READING;
                else if (PCI_CM == MEM_WRITE) next_state = WRITING;
                else next_state = IDLE;
            end
            else next_state = WAITING;
        end

        ENDING:begin
            if(FRAME==1) next_state = IDLE;
            else next_state = ENDING;
        end
   endcase
end

//store control
always @(posedge clock) begin
    case(state)
        IDLE:begin
            Sdata = 32'bz;
            STOP = 1;
            CMD = 2'b11;
            address_register = AD_register;
        end
        READING:begin
            address_register = (IRDY==1 || TRDY==1)? address_register : address_register + 1;
            storage_address = address_register [2:0];//up one
            Sdata = 32'bz;
            CMD = (FRAME==0)? READ : 2'b11;
            BE = CBE_register;
        end
        WRITING:begin
            storage_address = address_register [2:0]; //just an old quick fix
            address_register = (IRDY==1 || TRDY==1)? address_register : address_register + 1;
            CMD = WRITE;
            Sdata = 32'bz;
            BE = CBE_register;
            Sdata = AD_register;
        end
        WAITING:begin
            storage_address = address_register [2:0];
            address_register = address_register;
            Sdata = 32'bz;
            CMD = DETERM;
            BE = CBE_register;
        end
    endcase
end


//states ouput
always @(negedge clock)begin
    case (state)
        IDLE:begin
            AD_direction = 1;
            TRDY = 1; DEVSEL = 1;
        end

        READING:begin
            AD_direction = 0;
            DEVSEL = (FRAME==1)? IRDY : 0;
            TRDY = (FRAME==1)? IRDY : 0;
            
            TRDY = (next_state == WAITING) ? 1: TRDY;
            STOP=1;
        end

        WRITING:begin
        AD_direction = 1;
        DEVSEL = (FRAME==1)? IRDY : 0;
        TRDY = (FRAME==1)? IRDY : 0;
        TRDY = (next_state == WAITING) ? 1: TRDY;
        STOP=1;
        end

        WAITING:begin
        AD_direction = 1;
        DEVSEL = 0;
        TRDY = (next_state == WAITING) ? 1 : 0;
        STOP=1;
        end

        ENDING:begin
            AD_direction = 0;
            DEVSEL = 0;
            TRDY = 0;
            storage_address = address_register [2:0];
            address_register = address_register + 1;
            Sdata = 32'bz;
            CMD = 2'b11;
            BE = CBE_register;
            STOP = 0;
        end
    endcase
end

endmodule


