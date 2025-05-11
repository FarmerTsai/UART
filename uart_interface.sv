interface uart_if(input clk, input rst_n);
	// for TX
	logic tx_en;
	logic [7:0] tx_data;
	logic tx_done;

	// TX -> RX
	logic uart_txd;
	logic uart_rxd;

	// for RX
	logic [7:0] rx_data;
	logic rx_ready;
	
	// parity control
	logic parity_mode;
	logic parity_error;
	logic parity_bit;
endinterface