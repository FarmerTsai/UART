`include "uart_tx.sv"
`include "uart_rx.sv"

module uart(clk, rst_n, DIV, tx_en, tx_data, uart_txd, uart_rxd, rx_data, rx_ready, tx_done);
    input clk;
    input rst_n;
    input [7:0] DIV;
    input tx_en;
    input [7:0] tx_data;
    input uart_rxd;

    output uart_txd;
    output [7:0] rx_data;
    output rx_ready;
    output tx_done;

    // TX
    uart_tx dut_tx(
        .clk(clk),
        .rst_n(rst_n),
        .DIV(DIV),
        .tx_en(tx_en),
        .tx_data(tx_data),
        .uart_txd(uart_txd),
        .tx_done(tx_done)
    );

    // RX
    uart_rx dut_rx(
        .clk(clk),
        .rst_n(rst_n),
        .DIV(DIV),
        .uart_rxd(uart_rxd),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

endmodule