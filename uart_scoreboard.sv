class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard);

    int dut_num;

    int tx_compare_cnt, tx_match_cnt, tx_mismatch_cnt;
    int rx_compare_cnt, rx_match_cnt, rx_mismatch_cnt;

    // DUT tx vs Driver
    uvm_blocking_get_port #(uart_trans) tx_port[]; // from i_agt.mon(DUT tx)
    uvm_blocking_get_port #(uart_trans) drv_port[]; // from i_agt drv
    uart_trans tx_queue[$], drv_queue[$];

    // DUT rx vs Model
    uvm_blocking_get_port #(uart_trans) rx_port[]; // from o_agt.mon(DUT rx)
    uvm_blocking_get_port #(uart_trans) mdl_port; // from model    
    uart_trans rx_queue[$], mdl_queue[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass

function void uart_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get dut amount
	if(!uvm_config_db #(int)::get(this, "", "dut_num", dut_num))
		`uvm_fatal("scoreboard", "dut_num must be set!");

    tx_port = new[dut_num];
    drv_port = new[dut_num];
    rx_port = new[dut_num];
    for(int i = 0; i < dut_num; i++) begin
        tx_port[i] = new($sformatf("tx_port[%0d]", i), this);
        drv_port[i] = new($sformatf("drv_port[%0d]", i), this);
        rx_port[i] = new($sformatf("rx_port[%0d]", i), this);
    end

    mdl_port = new("mdl_port", this);
endfunction

task uart_scoreboard::run_phase(uvm_phase phase);
    uart_trans tx_expect, tx_actual, tx_tmp_tran;
    uart_trans rx_expect, rx_actual, rx_tmp_tran;
    bit tx_result, rx_result;

    // tx
    fork
        for(int i = 0; i < dut_num; i++) begin
            forever begin
                drv_port[i].get(tx_expect); // from driver
                drv_queue.push_back(tx_expect);

                wait(drv_queue.size() > 0);
                tx_port[i].get(tx_actual); // from i_agt.mon
                tx_tmp_tran = drv_queue.pop_front();
                if(tx_actual.tx_data === tx_tmp_tran.tx_data)
                    tx_result = 1;
                else
                    tx_result = 0;

                tx_compare_cnt++;

                if(tx_result) begin
                    `uvm_info("uart_scoreboard", $sformatf("env_[%0d]: Compare SUCCESSFULLY", i), UVM_LOW);
                    $display("env_[%0d] Model expect: %0h", i, tx_tmp_tran.tx_data);
                    $display("env_[%0d] DUT actual : %0h", i, tx_actual.tx_data);
                    tx_match_cnt++;
                end
                else begin
                    `uvm_error("uart_scoreboard", $sformatf("env_[%0d]: Compare FAILED", i));
                    $display("env_[%0d] the expect data is %0h", i, tx_tmp_tran.rx_data);
                    $display("env_[%0d] the actual data is %0h", i, tx_actual.rx_data);
                    tx_mismatch_cnt++;
                end
            end
        end
    join_none

    // rx
    fork
        for(int i = 0; i < dut_num; i++) begin
            forever begin
                mdl_port.get(rx_expect); // from model
                mdl_queue.push_back(rx_expect);

                wait(mdl_queue.size() > 0);
                rx_port[i].get(rx_actual); // from o_agt.mon
                rx_tmp_tran = mdl_queue.pop_front();
                if(rx_actual.rx_data === rx_tmp_tran.rx_data)
                    rx_result = 1;
                else
                    rx_result = 0;

                rx_compare_cnt++;

                if(rx_result) begin
                    `uvm_info("uart_scoreboard", $sformatf("env_[%0d]: Compare SUCCESSFULLY", i), UVM_LOW);
                    $display("env_[%0d] Model expect: %0h", i, rx_tmp_tran.rx_data);
                    $display("env_[%0d] DUT actual : %0h", i, rx_actual.rx_data);
                    rx_match_cnt++;
                end
                else begin
                    `uvm_error("uart_scoreboard", $sformatf("env_[%0d]: Compare FAILED", i));
                    $display("env_[%0d] the expect data is %0h", i, rx_tmp_tran.rx_data);
                    $display("env_[%0d] the actual data is %0h", i, rx_actual.rx_data);
                    rx_mismatch_cnt++;
                end
            end
        end
    join_none
endtask

function void uart_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("uart_scoreboard", $sformatf("\ntx: Total compare times is: %0d\tMatch count is: %0d\tMismatch count is: %0d", tx_compare_cnt, tx_match_cnt, tx_mismatch_cnt), UVM_LOW);
    `uvm_info("uart_scoreboard", $sformatf("\nrx: Total compare times is: %0d\tMatch count is: %0d\tMismatch count is: %0d", rx_compare_cnt, rx_match_cnt, rx_mismatch_cnt), UVM_LOW);
endfunction