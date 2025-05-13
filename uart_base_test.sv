class uart_base_test extends uvm_test;  
    `uvm_component_utils(uart_base_test);
    
    uart_env_top env_top;

	virtual uart_if a_if;
	virtual uart_if b_if;

	int BAUD_RATE = 100000;
	int CLK_FREQ = 1000000;
    
    function new(string name, uvm_component parent);
    	super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual uart_if)::get(this, "", "a_if", a_if))
			`uvm_fatal("uart_base_test", "virtual interface must be set for a_if!");
		if(!uvm_config_db #(virtual uart_if)::get(this, "", "b_if", b_if))
			`uvm_fatal("uart_base_test", "virtual interface must be set for b_if!");
		a_if.DIV = CLK_FREQ / BAUD_RATE;
		b_if.DIV = CLK_FREQ / BAUD_RATE;
		
    	env_top = uart_env_top::type_id::create("env_top", this);
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
endclass

//parameter BAUD_RATE = 100000; // for test
//parameter CLK_FREQ = 1000000; // 1MHZ
//parameter DIV = CLK_FREQ / BAUD_RATE; // 10