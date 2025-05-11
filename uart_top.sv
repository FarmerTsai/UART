`timescale 1 ns/ 1 ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uart_interface.sv"
`include "uart_transaction.sv"
`include "uart_sequence.sv"
`include "uart_sequencer.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_agent.sv"
`include "uart_model.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv"
`include "uart_env_rx.sv"
`include "uart_env_tx.sv"
`include "uart_env_top.sv"
`include "uart_test.sv"

module tb_uart_top; 
  
    reg clk;
    reg rst_n;
  
    uart_if tx_if(.clk(clk), .rst_n(rst_n));
    uart_if rx_if(.clk(clk), .rst_n(rst_n));
  
    uart dut_tx(
        .clk(tx_if.clk),
        .rst_n(tx_if.rst_n),
        .tx_en(tx_if.tx_en),
        .tx_data(tx_if.tx_data),
        .uart_txd(tx_if.uart_txd),
        .uart_rxd(tx_if.uart_rxd),
        .rx_data(tx_if.rx_data),
        .rx_ready(tx_if.rx_ready)
        //.parity_mode(tx_if.parity_mode)
    );

    uart dut_rx(
        .clk(rx_if.clk),
        .rst_n(rx_if.rst_n),
        .tx_en(rx_if.tx_en),
        .tx_data(rx_if.tx_data),
        .uart_txd(rx_if.uart_txd),
        .uart_rxd(rx_if.uart_rxd),
        .rx_data(rx_if.rx_data),
        .rx_ready(rx_if.rx_ready)
        //.parity_mode(rx_if.parity_mode)
    );

    // connect two dut
    assign rx_if.uart_rxd = tx_if.uart_txd;
    assign tx_if.uart_rxd = rx_if.uart_txd;

    // waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $display("generate dump file");
        $dumpvars(0, tb_uart_top);
    end


    // Clock generator
    initial begin
        clk = 0;
        forever begin
            #500 clk = ~clk; // 1MHZ
        end
    end
  
    // generate reset
    initial begin
        rst_n = 1'b0;
        $display("Time: %0t: top.rst_n is 1'b0", $time);
        #100;
        rst_n = 1'b1;
        $display("Time: %0t: top.rst_n is 1'b1", $time);
    end

    initial begin
        // env_tx
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_tx", "uart_if", tx_if);		
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_tx.i_agt.mon", "uart_if", tx_if);		
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_tx.i_agt.drv", "tx_if", tx_if);
		uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_tx.i_agt.drv", "rx_if", rx_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_tx.o_agt.mon", "uart_if", tx_if);
        
        // env_rx
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_rx", "uart_if", rx_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_rx.i_agt.mon", "uart_if", rx_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_rx.i_agt.drv", "tx_if", tx_if);
		uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_rx.i_agt.drv", "rx_if", rx_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_rx.o_agt.mon", "uart_if", rx_if);

        
        // start test
        run_test("uart_test");
    end

endmodule