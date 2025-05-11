class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard);

    uvm_blocking_get_port #(uart_trans) tx_exp_port; // from env_tx model
    uvm_blocking_get_port #(uart_trans) tx_act_port; // from env_rx dut rx
    uart_trans tx_expect_queue[$];
    uart_trans tx_actual_queue[$];

    uvm_blocking_get_port #(uart_trans) rx_exp_port; // from env_rx model
    uvm_blocking_get_port #(uart_trans) rx_act_port; // from env_tx dut rx
    uart_trans rx_expect_queue[$];
    uart_trans rx_actual_queue[$];    

    int tx_compare_cnt = 0;
    int tx_match_cnt = 0;
    int tx_mismatch_cnt = 0;

    int rx_compare_cnt = 0;
    int rx_match_cnt = 0;
    int rx_mismatch_cnt = 0;

    function new(string name = "uart_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass

function void uart_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    tx_exp_port = new("tx_exp_port", this);
    tx_act_port = new("tx_act_port", this);

    rx_exp_port = new("rx_exp_port", this);
    rx_act_port = new("rx_act_port", this);
endfunction

task uart_scoreboard::run_phase(uvm_phase phase);
    uart_trans tx_get_expect, tx_get_actual, tx_tmp_tran;
    bit tx_result;

    uart_trans rx_get_expect, rx_get_actual, rx_tmp_tran;
    bit rx_result;

    // env_tx
    fork
        forever begin
            tx_exp_port.get(tx_get_expect); // from model
            tx_expect_queue.push_back(tx_get_expect);
        end
        forever begin
            wait(tx_expect_queue.size() > 0);
            tx_act_port.get(tx_get_actual); // from dut rx
            tx_tmp_tran = tx_expect_queue.pop_front();
            tx_result = tx_get_actual.compare(tx_tmp_tran);
            tx_compare_cnt++;

            if(tx_result) begin
                `uvm_info("uart_scoreboard", "env_tx: Compare SUCCESSFULLY", UVM_LOW);
                $display("Model expect: %0h", tx_tmp_tran.rx_data);
                $display("DUT actual : %0h", tx_get_actual.rx_data);
                tx_match_cnt++;
            end
            else begin
                `uvm_error("uart_scoreboard", "env_tx: Compare FAILED");
                $display("the expect data is %0h", tx_tmp_tran.rx_data);
                $display("the actual data is %0h", tx_get_actual.rx_data);
                tx_mismatch_cnt++;
            end
        end
    join_none

    // env_rx
    fork
        forever begin
            rx_exp_port.get(rx_get_expect); // from model
            rx_expect_queue.push_back(rx_get_expect);
        end
        forever begin
            wait(rx_expect_queue.size() > 0);
            rx_act_port.get(rx_get_actual); // from dut rx
            rx_tmp_tran = rx_expect_queue.pop_front();
            rx_result = rx_get_actual.compare(rx_tmp_tran);
            rx_compare_cnt++;

            if(rx_result) begin
                `uvm_info("uart_scoreboard", "env_rx: Compare SUCCESSFULLY", UVM_LOW);
                $display("Model expect: %0h", rx_tmp_tran.rx_data);
                $display("DUT actual : %0h", rx_get_actual.rx_data);
                rx_match_cnt++;
            end
            else begin
                `uvm_error("uart_scoreboard", "env_rx: Compare FAILED");
                $display("the expect data is %0h", rx_tmp_tran.rx_data);
                $display("the actual data is %0h", rx_get_actual.rx_data);
                rx_mismatch_cnt++;
            end
        end
    join_none
endtask

function void uart_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("uart_scoreboard", $sformatf("\nenv _tx: Total compare times is: %0d\tMatch count is: %0d\tMismatch count is: %0d", tx_compare_cnt, tx_match_cnt, tx_mismatch_cnt), UVM_LOW);
    `uvm_info("uart_scoreboard", $sformatf("\nenv_rx: Total compare times is: %0d\tMatch count is: %0d\tMismatch count is: %0d", rx_compare_cnt, rx_match_cnt, rx_mismatch_cnt), UVM_LOW);
endfunction