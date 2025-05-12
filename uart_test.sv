class uart_test extends uvm_test;  
    `uvm_component_utils(uart_test);
    
    uart_env_top env_top;
    
    function new(string name = "uart_test", uvm_component parent);
    	super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    	env_top = uart_env_top::type_id::create("env_top", this);
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
    
    task run_phase(uvm_phase phase);
    	uart_sequence a_seq, b_seq;
		fork
			begin
				// sequence for env_a
				a_seq = uart_sequence::type_id::create("a_seq");
    			/*if(!a_seq.randomize()) // random should in sequence
    				`uvm_error("", "Randomize failed")*/
    			a_seq.starting_phase = phase;
    			a_seq.start(env_top.env_a.i_agt.sqr);
			end
			begin
				// sequence for env_b
				b_seq = uart_sequence::type_id::create("b_seq");
    			/*if( !b_seq.randomize() ) 
    				`uvm_error("", "Randomize failed")*/
    			b_seq.starting_phase = phase;
    			b_seq.start(env_top.env_b.i_agt.sqr);
			end
		join
    endtask
     
endclass