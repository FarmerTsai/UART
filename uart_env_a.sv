class uart_env_a extends uvm_env;
    `uvm_component_utils(uart_env_a);
    
    uart_agent i_agt;
	uart_agent o_agt;

	virtual uart_if vif;
    
    function new(string name = "", uvm_component parent);
    	super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);

    	i_agt = uart_agent::type_id::create("i_agt", this);
		i_agt.is_active = UVM_ACTIVE;
		i_agt.is_a = 1;

		o_agt = uart_agent::type_id::create("o_agt", this);
		o_agt.is_active = UVM_PASSIVE;

		if(!uvm_config_db #(virtual uart_if)::get(this, "", "uart_if", vif)) begin
			`uvm_fatal("uart_env_a", "virtual interface must be set!");
		end
    endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction
    
endclass