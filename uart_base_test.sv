class uart_base_test extends uvm_test;  
    `uvm_component_utils(uart_base_test);
    
    uart_env_top env_top;
    
    function new(string name, uvm_component parent);
    	super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    	env_top = uart_env_top::type_id::create("env_top", this);
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
endclass