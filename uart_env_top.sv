class uart_env_top extends uvm_env;
    `uvm_component_utils(uart_env_top);

    uart_env_a env_a;
    uart_env_b env_b;
    uart_model model;
    uart_scoreboard scoreboard;
    uart_coverage cov;

    uvm_tlm_analysis_fifo #(uart_trans) a_drv2mdl_fifo; // env_a drv -> model
    uvm_tlm_analysis_fifo #(uart_trans) a_mdl_fifo; // env_a model -> scoreboard
    uvm_tlm_analysis_fifo #(uart_trans) a_dut_fifo; // env_a monitor -> scoreboard

    uvm_tlm_analysis_fifo #(uart_trans) b_drv2mdl_fifo; // env_b drv -> model
    uvm_tlm_analysis_fifo #(uart_trans) b_mdl_fifo; // env_b model -> scoreboard
    uvm_tlm_analysis_fifo #(uart_trans) b_dut_fifo; // env_b monitor -> scoreboard

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function void uart_env_top::build_phase(uvm_phase phase);
    super.build_phase(phase);

    env_a = uart_env_a::type_id::create("env_a", this);
    env_b = uart_env_b::type_id::create("env_b", this);
    model = uart_model::type_id::create("model", this);
    scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
    cov = uart_coverage::type_id::create("cov", this);

    a_drv2mdl_fifo = new("a_drv2mdl_fifo", this);
    a_mdl_fifo = new("a_mdl_fifo", this);
    a_dut_fifo = new("a_dut_fifo", this);

    b_drv2mdl_fifo = new("b_drv2mdl_fifo", this);
    b_mdl_fifo = new("b_mdl_fifo", this);
    b_dut_fifo = new("b_dut_fifo", this);
endfunction

function void uart_env_top::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // env_a drive -> model
    env_a.i_agt.drv.drv2mdl_port.connect(a_drv2mdl_fifo.blocking_put_export);
    model.a_in_port.connect(a_drv2mdl_fifo.blocking_get_export);
    // env_b monitor -> scoreboard(env_a.tx -> env_b.rx)
    env_b.o_agt.mon.ap_port.connect(a_dut_fifo.analysis_export);
    scoreboard.a_act_port.connect(a_dut_fifo.blocking_get_export);
    // env_a model -> scoreboard
    model.a_out_port.connect(a_mdl_fifo.analysis_export);
    scoreboard.a_exp_port.connect(a_mdl_fifo.blocking_get_export);

    // env_b drive -> model
    env_b.i_agt.drv.drv2mdl_port.connect(b_drv2mdl_fifo.blocking_put_export);
    model.b_in_port.connect(b_drv2mdl_fifo.blocking_get_export);
    // env_a monitor -> scoreboard(env_b.tx -> env_a.rx)
    env_a.o_agt.mon.ap_port.connect(b_dut_fifo.analysis_export);
    scoreboard.b_act_port.connect(b_dut_fifo.blocking_get_export);
    // env_b model -> scoreboard
    model.b_out_port.connect(b_mdl_fifo.analysis_export);
    scoreboard.b_exp_port.connect(b_mdl_fifo.blocking_get_export);

	// coverage
	env_a.i_agt.mon.cov_port.connect(cov.analysis_export);
    env_b.i_agt.mon.cov_port.connect(cov.analysis_export);
endfunction