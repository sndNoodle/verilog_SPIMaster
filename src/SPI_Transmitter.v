`timescale 1ns / 1ps

module SPI_Transmitter #(
    parameter SPI_DATALENGTH = 6'd32
)
(
    input clk,
    input rst,
    output reg sendComplete,
    output MOSI,
    output reg SCLK,
    output reg CS,
    input MISO,
    input [31:0] sendData,
    output reg [31:0] recvData
);
    reg [31:0] sendData_reg;
    reg[5:0] counter;
    reg[1:0] state;
    localparam DEFSTATE   = 2'b00;
    localparam CLKUP      = 2'b01;
    localparam CLKDOWN    = 2'b10;
    localparam DATACHANGE = 2'b11;
    
    assign MOSI = sendData_reg[31];
    reg[31:0] recvData_tmp;
 
    always @(posedge clk or negedge rst)begin
        if(rst == 1'b0)begin
            sendComplete <= 1'b0;
            recvData <= 32'h0000_0000;
            recvData_tmp <= 32'h0000_0000;
            SCLK     <= 1'b0;
            CS       <= 1'b1;
            counter  <= 6'b000000;
            sendData_reg <= sendData;
            state <= DEFSTATE;
        end else begin
            case (state)
                DEFSTATE : begin
                    sendComplete <= 1'b0;
                    SCLK  <= 1'b0;
                    CS    <= 1'b0;
                    state <= CLKUP;
                    recvData <= recvData;
                    recvData_tmp <= recvData_tmp;
                end
                CLKUP : begin
                    sendComplete <= 1'b0;
                    SCLK  <= 1'b1;
                    CS    <= 1'b0;
                    state <= CLKDOWN;
                    recvData <= recvData;
                    recvData_tmp <= recvData_tmp;
                end
                CLKDOWN : begin
                    sendComplete <= 1'b0;
                    SCLK  <= 1'b0;
                    CS    <= 1'b0;
                    state <= DATACHANGE;
                    recvData <= recvData;
                    recvData_tmp <= {recvData_tmp[30:0],MISO};
                end
                DATACHANGE : begin
                    SCLK <= SCLK;
                    recvData_tmp <= recvData_tmp;
                    if (counter == SPI_DATALENGTH - 6'b000001)begin
                        sendComplete <= 1'b1;
                        CS           <= 1'b1;
                        state        <= DATACHANGE;
                        counter      <= counter;
                        recvData     <= recvData_tmp;
                    end else begin
                        sendComplete <= 1'b0;
                        sendData_reg <= {sendData_reg[30:0],1'b0};
                        state        <= CLKUP;
                        counter      <= counter + 6'b000001;
                        recvData     <= recvData;
                    end
                end
                default :
                    SCLK <= 1'b0;
            endcase
        end
    end
endmodule
