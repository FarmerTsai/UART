class uart_env_top extends uvm_env;
    `uvm_component_utils(uart_env_top);

    uart_env_tx env_tx;
    uart_env_rx env_rx;
    uart_model model;
    uart_scoreboard scoreboard;
    uart_coverage cov;

    uvm_tlm_analysis_fifo #(uart_trans) tx_drv2mdl_fifo; // env_tx drv -> model
    uvm_tlm_analysis_fifo #(uart_trans) tx_mdl_fifo; // env_tx model -> scoreboard
    uvm_tlm_analysis_fifo #(uart_trans) tx_dut_fifo; // env_tx monitor -> scoreboard

    uvm_tlm_analysis_fifo #(uart_trans) rx_drv2mdl_fifo; // env_rx drv -> model
    uvm_tlm_analysis_fifo #(uart_trans) rx_mdl_fifo; // env_rx model -> scoreboard
    uvm_tlm_analysis_fifo #(uart_trans) rx_dut_fifo; // env_rx monitor -> scoreboard

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function void uart_env_top::build_phase(uvm_phase phase);
    super.build_phase(phase);

    env_tx = uart_env_tx::type_id::create("env_tx", this);
    env_rx = uart_env_rx::type_id::create("env_rx", this);
    model = uart_model::type_id::create("model", this);
    scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
    cov = uart_coverage::type_id::create("cov", this);

    tx_drv2mdl_fifo = new("tx_drv2mdl_fifo", this);    
    tx_mdl_fifo = new("tx_mdl_fifo", this);
    tx_dut_fifo = new("tx_dut_fifo", this);

    rx_drv2mdl_fifo = new("rx_drv2mdl_fifo", this);
    rx_mdl_fifo = new("rx_mdl_fifo", this);
    rx_dut_fifo = new("rx_dut_fifo", this);
endfunction

function void uart_env_top::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // env_tx drive -> model
    env_tx.i_agt.drv.drv2mdl_port.connect(tx_drv2mdl_fifo.blocking_put_export);
    model.tx_in_port.connect(tx_drv2mdl_fifo.blocking_get_export);
    // env_rx monitor -> scoreboard(tx -> rx)
    env_rx.o_agt.mon.ap_port.connect(tx_dut_fifo.analysis_export);
    scoreboard.tx_act_port.connect(tx_dut_fifo.blocking_get_export);
    // env_tx model -> scoreboard
    model.tx_out_port.connect(tx_mdl_fifo.analysis_export);
    scoreboard.tx_exp_port.connect(tx_mdl_fifo.blocking_get_export);

    // env_rx drive -> model
    env_rx.i_agt.drv.drv2mdl_port.connect(rx_drv2mdl_fifo.blocking_put_export);
    model.rx_in_port.connect(rx_drv2mdl_fifo.blocking_get_export);
    // env_tx monitor -> scoreboard(rx -> tx)
    env_tx.o_agt.mon.ap_port.connect(rx_dut_fifo.analysis_export);
    scoreboard.rx_act_port.connect(rx_dut_fifo.blocking_get_export);
    // env_rx model -> scoreboard
    model.rx_out_port.connect(rx_mdl_fifo.analysis_export);
    scoreboard.rx_exp_port.connect(rx_mdl_fifo.blocking_get_export);

	// coverage
	env_rx.i_agt.mon.cov_port.connect(cov.analysis_export);
    env_tx.i_agt.mon.cov_port.connect(cov.analysis_export);
endfunction