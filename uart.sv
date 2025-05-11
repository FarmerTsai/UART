`include "uart_tx.sv"
`include "uart_rx.sv"

module uart(clk, rst_n, tx_en, tx_data, uart_txd, uart_rxd, rx_data, rx_ready, tx_done);

parameter CLK_FREQ = 50000000;
parameter BAUD_RATE = 9600;
parameter DIV = CLK_FREQ/BAUD_RATE;

    input clk;
    input rst_n;
    input tx_en;
    input [7:0] tx_data;
    input uart_rxd;
    //input parity_mode;

    output uart_txd;
    output [7:0] rx_data;
    output rx_ready;
    output tx_done;
    //output parity_error;

    // TX
    uart_tx dut_tx(
        .clk(clk),
        .rst_n(rst_n),
        .tx_en(tx_en),
        .tx_data(tx_data),
        .uart_txd(uart_txd),
        .tx_done(tx_done)
        //.parity_mode(parity_mode)
    );

    // RX
    uart_rx dut_rx(
        .clk(clk),
        .rst_n(rst_n),
        .uart_rxd(uart_rxd),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
        //.parity_mode(parity_mode),
        //.parity_error(parity_error)
    );

endmodule