`timescale 1ns / 1ps

module tb_SPI_Transmitter();

reg clk;
reg rst;
wire sendComplete;
wire MOSI;
wire SCLK;
wire CS;
wire MISO;
reg [31:0] sendData;
wire [31:0] recvData;

SPI_Transmitter transmitter(
    .clk(clk),
    .rst(rst),
    .sendComplete(sendComplete),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .CS(CS),
    .MISO(MISO),
    .sendData(sendData),
    .recvData(recvData)
);

reg [31:0] slaveData;
reg [31:0] MOSIReg;
assign MISO = slaveData[31];
// pseud slave device
always @ (posedge SCLK or negedge rst)begin
    if(rst == 1'b0)begin
        slaveData <= 32'hFEDCBA98;
        MOSIReg <= 32'h00000000;
    end else begin
        slaveData <= {slaveData[30:0],1'b0};
        MOSIReg <= {MOSIReg[30:0],MOSI};
    end
end

always #10
    if(rst == 1'b0)
        clk <= 1'b0;
    else
        clk <= ~clk;

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,transmitter);
    #0
    rst <= 1'b1;
    sendData <= 32'h12345678;
    #30
    rst <= 1'b0;
    #50
    rst <= 1'b1;
    #2500
    $finish;
end

endmodule
