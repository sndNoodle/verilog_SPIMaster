`timescale 1ns / 1ps


module SPI_Master #(
    parameter SPI_DATALENGTH = 6'd32
)
(
    input clk,
    input rst,
    input sendStart,
    output SPI_MOSI,
    output SPI_SCLK,
    output SPI_CS,
    input SPI_MISO,
    input [31:0] sendData, // to transmitter
    output [31:0] recvData
);
    localparam STATE_INITIALIZE  = 2'b00;
    localparam STATE_SENDMSG     = 2'b01;
    localparam STATE_FINALIZE    = 2'b11;
    
    reg [1:0] currentState;
    reg [1:0] nextState;
    reg sendStart_reg;
    wire sendComplete;
    
    
    SPI_Transmitter #(SPI_DATALENGTH) transmitter(
        .clk(clk),
        .rst(sendStart_reg),
        .sendComplete(sendComplete),
        .MOSI(SPI_MOSI),
        .SCLK(SPI_SCLK),
        .CS(SPI_CS),
        .MISO(SPI_MISO),
        .sendData(sendData),
        .recvData(recvData)
    );
    
    always @ (posedge clk or negedge rst) begin
        if(rst == 1'b0)begin
            currentState <= STATE_INITIALIZE;
            sendStart_reg <= 1'b0;
        end else begin
            case (currentState)
                STATE_INITIALIZE : begin
                    if(sendStart == 1'b1)begin
                        currentState <= STATE_SENDMSG;
                        sendStart_reg <= 1'b1;
                    end else begin
                        currentState <= currentState;
                        sendStart_reg <= 1'b0;
                    end
                end
                STATE_SENDMSG : begin
                    if(sendComplete == 1'b1) begin
                        currentState <= STATE_FINALIZE;
                        sendStart_reg <= 1'b1;
                    end else begin
                        currentState <= currentState;
                        sendStart_reg <= 1'b1;
                    end
                end
                STATE_FINALIZE : begin
                    if(sendStart == 1'b0)begin
                        currentState <= STATE_INITIALIZE;
                        sendStart_reg <= 1'b0;
                    end else begin
                        currentState <= currentState;
                        sendStart_reg <= 1'b1;
                    end
                end
            endcase
        end
    end
    
endmodule
