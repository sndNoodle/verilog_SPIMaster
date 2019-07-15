`timescale 1ns / 1ps


module tb_SPI_Master();

    reg clk;
    reg rst;
    wire SPI_MOSI;
    wire SPI_SCLK;
    wire SPI_CS;
    wire SPI_MISO;
    reg [31:0] sendData;
    wire[31:0] recvData;
    reg sendStart;

    SPI_Master spimaster (
        .clk(clk),
        .rst(rst),
        .sendStart(sendStart),
        .SPI_MOSI(SPI_MOSI),
        .SPI_SCLK(SPI_SCLK),
        .SPI_CS(SPI_CS),
        .SPI_MISO(SPI_MISO),
        .sendData(sendData),
        .recvData(recvData)
    );

    //pseud slave device  


    reg [31:0] slaveData;
    reg [31:0] MOSIReg;
    assign SPI_MISO = slaveData[31];
    // pseud slave device
    always @ (posedge SPI_SCLK or negedge rst)begin
        if(rst == 1'b0)begin
            slaveData <= 32'hFEDCBA98;
            MOSIReg <= 32'h00000000;
        end else begin
            slaveData <= {slaveData[30:0],1'b0};
            MOSIReg <= {MOSIReg[30:0],SPI_MOSI};
        end
    end


    always #10
    if(rst == 1'b0)
        clk <= 1'b0;
    else
        clk <= ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0,spimaster);
        #0
        rst <= 1'b0;
        sendData <= 32'h12345678;
        sendStart <= 1'b0;

        #30
        rst <= 1'b0;
        #50
        rst <= 1'b1;

        #50
        sendStart <= 1'b1;
        #2500
        $finish;    

    end

endmodule
