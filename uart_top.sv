`timescale 1 ns/ 1 ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uart_interface.sv"
`include "uart_transaction.sv"
`include "uart_basic_sequence.sv"
`include "uart_corner_sequence.sv"
`include "uart_special_sequence.sv"
`include "uart_sequencer.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_agent.sv"
`include "uart_model.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv"
`include "uart_env_a.sv"
`include "uart_env_b.sv"
`include "uart_env_top.sv"
`include "uart_base_test.sv"
`include "uart_basic_test.sv"
`include "uart_corner_test.sv"
`include "uart_special_test.sv"

module tb_uart_top; 
  
    reg clk;
    reg rst_n;
  
    uart_if a_if(.clk(clk));
    uart_if b_if(.clk(clk));
  
    uart dut_a(
        .clk(a_if.clk),
        .rst_n(a_if.rst_n),
        .tx_en(a_if.tx_en),
        .tx_data(a_if.tx_data),
        .uart_txd(a_if.uart_txd),
        .uart_rxd(a_if.uart_rxd),
        .rx_data(a_if.rx_data),
        .rx_ready(a_if.rx_ready)
    );

    uart dut_b(
        .clk(b_if.clk),
        .rst_n(b_if.rst_n),
        .tx_en(b_if.tx_en),
        .tx_data(b_if.tx_data),
        .uart_txd(b_if.uart_txd),
        .uart_rxd(b_if.uart_rxd),
        .rx_data(b_if.rx_data),
        .rx_ready(b_if.rx_ready)
    );

    // connect two dut
    assign b_if.uart_rxd = a_if.uart_txd;
    assign a_if.uart_rxd = b_if.uart_txd;

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
    /*initial begin
        rst_n = 1'b0;
        $display("Time: %0t: top.rst_n is 1'b0", $time);
        #100;
        rst_n = 1'b1;
        $display("Time: %0t: top.rst_n is 1'b1", $time);
    end*/

    initial begin
        // env_tx
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_a", "uart_if", a_if);		
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_a.i_agt.mon", "uart_if", a_if);		
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_a.i_agt.drv", "a_if", a_if);
		uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_a.i_agt.drv", "b_if", b_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_a.o_agt.mon", "uart_if", a_if);
        
        // env_rx
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_b", "uart_if", b_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_b.i_agt.mon", "uart_if", b_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_b.i_agt.drv", "a_if", a_if);
		uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_b.i_agt.drv", "b_if", b_if);
        uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env_top.env_b.o_agt.mon", "uart_if", b_if);

        
        // start test
        run_test("uart_special_test");
    end

endmodule