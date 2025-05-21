class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard);

    uvm_blocking_get_port #(uart_trans) a_exp_port; // from env_a model
    uvm_blocking_get_port #(uart_trans) a_act_port; // from env_b dut rx
    uart_trans a_expect_queue[$];
    uart_trans a_actual_queue[$];

    uvm_blocking_get_port #(uart_trans) b_exp_port; // from env_a model
    uvm_blocking_get_port #(uart_trans) b_act_port; // from env_b dut rx
    uart_trans b_expect_queue[$];
    uart_trans b_actual_queue[$];    

    int a_compare_cnt = 0;
    int a_match_cnt = 0;
    int a_mismatch_cnt = 0;

    int b_compare_cnt = 0;
    int b_match_cnt = 0;
    int b_mismatch_cnt = 0;

    function new(string name = "uart_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass

function void uart_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    a_exp_port = new("a_exp_port", this);
    a_act_port = new("a_act_port", this);

    b_exp_port = new("b_exp_port", this);
    b_act_port = new("b_act_port", this);
endfunction

task uart_scoreboard::run_phase(uvm_phase phase);
    uart_trans a_get_expect, a_get_actual, a_tmp_tran;
    bit a_result;

    uart_trans b_get_expect, b_get_actual, b_tmp_tran;
    bit b_result;

    // env_a
    fork
        forever begin
            a_exp_port.get(a_get_expect); // from model
            a_expect_queue.push_back(a_get_expect);
        end
        forever begin
            wait(a_expect_queue.size() > 0);
            a_act_port.get(a_get_actual); // from dut b
            a_tmp_tran = a_expect_queue.pop_front();
            //a_result = a_get_actual.compare(a_tmp_tran);
            if(a_get_actual.rx_data === a_tmp_tran.rx_data)
                a_result = 1;
            else
                a_result = 0;
                
            a_compare_cnt++;

            if(a_result) begin
                `uvm_info("uart_scoreboard", "env_a: Compare SUCCESSFULLY", UVM_LOW);
                $display("Model expect: %0h", a_tmp_tran.rx_data);
                $display("DUT actual : %0h", a_get_actual.rx_data);
                a_match_cnt++;
            end
            else begin
                `uvm_error("uart_scoreboard", "env_a: Compare FAILED");
                $display("the expect data is %0h", a_tmp_tran.rx_data);
                $display("the actual data is %0h", a_get_actual.rx_data);
                a_mismatch_cnt++;
            end
        end
    join_none

    // env_b
    fork
        forever begin
            b_exp_port.get(b_get_expect); // from model
            b_expect_queue.push_back(b_get_expect);
        end
        forever begin
            wait(b_expect_queue.size() > 0);
            b_act_port.get(b_get_actual); // from dut a
            b_tmp_tran = b_expect_queue.pop_front();
            //b_result = b_get_actual.compare(b_tmp_tran);
            if(b_get_actual.rx_data === b_tmp_tran.rx_data)
                b_result = 1;
            else
                b_result = 0;

            b_compare_cnt++;

            if(b_result) begin
                `uvm_info("uart_scoreboard", "env_b: Compare SUCCESSFULLY", UVM_LOW);
                $display("Model expect: %0h", b_tmp_tran.rx_data);
                $display("DUT actual : %0h", b_get_actual.rx_data);
                b_match_cnt++;
            end
            else begin
                `uvm_error("uart_scoreboard", "env_b: Compare FAILED");
                $display("the expect data is %0h", b_tmp_tran.rx_data);
                $display("the actual data is %0h", b_get_actual.rx_data);
                b_mismatch_cnt++;
            end
        end
    join_none
endtask

function void uart_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("uart_scoreboard", $sformatf("\nenv_a: Total compare times is: %0d\tMatch count is: %0d\tMismatch count is: %0d", a_compare_cnt, a_match_cnt, a_mismatch_cnt), UVM_LOW);
    `uvm_info("uart_scoreboard", $sformatf("\nenv_b: Total compare times is: %0d\tMatch count is: %0d\tMismatch count is: %0d", b_compare_cnt, b_match_cnt, b_mismatch_cnt), UVM_LOW);
endfunction