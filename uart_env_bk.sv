class uart_env extends uvm_env;
    `uvm_component_utils(uart_env);
    
    uart_agent i_agt;
	uart_agent o_agt;
	uart_model model;
	uart_scoreboard scoreboard;
	uart_coverage cov;

	uvm_tlm_analysis_fifo #(uart_trans) drv2mdl_fifo; // driver -> model
	uvm_tlm_analysis_fifo #(uart_trans) exp_fifo; // model -> scoreboard
	uvm_tlm_analysis_fifo #(uart_trans) act_fifo; // monitor -> scoreboard
    
    function new(string name = "", uvm_component parent);
    	super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);

    	i_agt = uart_agent::type_id::create("i_agt", this);
		i_agt.is_active = UVM_ACTIVE;
		o_agt = uart_agent::type_id::create("o_agt", this);
		o_agt.is_active = UVM_PASSIVE;

		model = uart_model::type_id::create("model", this);
		scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
		cov = uart_coverage::type_id::create("cov", this);

		drv2mdl_fifo = new("drv2mdl_fifo", this);
		exp_fifo = new("exp_fifo", this);
		act_fifo = new("act_fifo", this);
    endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		// connect monitor -> scoreboard
		o_agt.mon.ap_port.connect(act_fifo.analysis_export);

		// driver -> model
		i_agt.drv.drv2mdl_port.connect(drv2mdl_fifo.blocking_put_export);
		model.in_port.connect(drv2mdl_fifo.blocking_get_export);
		
		// connect model -> scoreboard
		model.out_port.connect(exp_fifo.analysis_export);

		// connect scoreboard port
		scoreboard.act_port.connect(act_fifo.blocking_get_export);
		scoreboard.exp_port.connect(exp_fifo.blocking_get_export);

		// coverage
		i_agt.mon.ap_port.connect(cov.analysis_export);
	endfunction
    
endclass