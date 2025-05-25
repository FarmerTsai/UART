class uart_basic_test extends uart_base_test;  
    `uvm_component_utils(uart_basic_test);

	uart_model model;
	uart_scoreboard scoreboard;
	uart_coverage cov;
	uart_env envs[];
	int dut_num;

	uvm_tlm_analysis_fifo #(uart_trans) mdl2scb_fifo; // model to scoreboard

    function new(string name, uvm_component parent);
    	super.new(name, parent);
    endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
endclass

function void uart_basic_test::build_phase(uvm_phase phase);
	randcase
		1: BAUD_RATE = 4800;
		1: BAUD_RATE = 9600;
		1: BAUD_RATE = 19200;
		1: BAUD_RATE = 38400;
		1: BAUD_RATE = 57600;
		1: BAUD_RATE = 115200;
	endcase

	`uvm_info("uart_basic_test", $sformatf("Random BAUD RATE is: %0d", BAUD_RATE), UVM_LOW);
	super.build_phase(phase);

	// get dut amount
	if(!uvm_config_db #(int)::get(this, "", "dut_num", dut_num))
		`uvm_fatal("uart_basic_test", "dut_num must be set!");

	envs = new[dut_num];
	for(int i = 0; i < dut_num; i++) begin
		envs[i] = uart_env::type_id::create($sformatf("env[%0d]", i), this);
	end

	model = uart_model::type_id::create("model", this);
	scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
	cov = uart_coverage::type_id::create("cov", this);

	mdl2scb_fifo = new("mdl2scb_fifo", this);
endfunction

task uart_basic_test::run_phase(uvm_phase phase);
	super.run_phase(phase);

	for(int i = 0; i < dut_num; i++) begin
		uart_basic_sequence seq;
		seq = uart_basic_sequence::type_id::create($sformatf("seq_[%0d]", i));
		seq.starting_phase = phase;
		seq.start(envs[i].i_agt.sqr);
	end
endtask

function void uart_basic_test::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	for(int i = 0; i < dut_num; i++) begin
		scoreboard.tx_port[i].connect(envs[i].tx2scb_fifo.blocking_get_export);
		scoreboard.drv_port[i].connect(envs[i].drv2scb_fifo.blocking_get_export);
		scoreboard.rx_port[i].connect(envs[i].rx2scb_fifo.blocking_get_export);
		model.in_port[i].connect(envs[i].rx2mdl_fifo.blocking_get_export);
	end

	model.out_port.connect(mdl2scb_fifo.analysis_export);
	scoreboard.mdl_port.connect(mdl2scb_fifo.blocking_get_export);
endfunction

/*task uart_basic_test::run_phase(uvm_phase phase);
	uart_basic_sequence a_seq, b_seq;
		fork
			begin
				// sequence for env_a
				a_seq = uart_basic_sequence::type_id::create("a_seq");
    			a_seq.starting_phase = phase;
    			a_seq.start(env_top.env_a.i_agt.sqr);
			end
			begin
				// sequence for env_b
				b_seq = uart_basic_sequence::type_id::create("b_seq");
    			b_seq.starting_phase = phase;
    			b_seq.start(env_top.env_b.i_agt.sqr);
			end
		join
endtask*/