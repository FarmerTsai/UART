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
    	uart_sequence tx_seq, rx_seq;
		fork
			begin
				tx_seq = uart_sequence::type_id::create("tx_seq");
    			if(!tx_seq.randomize()) 
    				`uvm_error("", "Randomize failed")
    			tx_seq.starting_phase = phase;
    			tx_seq.start(env_top.env_tx.i_agt.sqr);
			end
			begin
				rx_seq = uart_sequence::type_id::create("rx_seq");
    			if( !rx_seq.randomize() ) 
    				`uvm_error("", "Randomize failed")
    			rx_seq.starting_phase = phase;
    			rx_seq.start(env_top.env_rx.i_agt.sqr);
			end
		join
    endtask
     
endclass