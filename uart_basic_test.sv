class uart_basic_test extends uart_base_test;  
    `uvm_component_utils(uart_basic_test);
    
    uart_env_top env_top;
    
    function new(string name, uvm_component parent);
    	super.new(name, parent);
    endfunction
endclass

task uart_basic_test::run_phase(uvm_phase);
	uart_sequence a_seq, b_seq;
		fork
			begin
				// sequence for env_a
				a_seq = uart_sequence::type_id::create("a_seq");
    			a_seq.starting_phase = phase;
    			a_seq.start(env_top.env_a.i_agt.sqr);
			end
			begin
				// sequence for env_b
				b_seq = uart_sequence::type_id::create("b_seq");
    			b_seq.starting_phase = phase;
    			b_seq.start(env_top.env_b.i_agt.sqr);
			end
		join
endtask