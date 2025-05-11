class uart_agent extends uvm_agent;	
    `uvm_component_utils(uart_agent);
	  
	uart_sequencer sqr;
    uart_driver    drv;
    uart_mon mon;

    bit is_tx; // 1, is env_tx: 0, is env_rx

    uvm_analysis_port #(uart_trans) ap_port;

    virtual uart_if vif;
    
    function new(string name = "uart_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);

        uvm_config_db #(bit)::set(this, "drv", "is_tx", is_tx);

        if(is_active == UVM_ACTIVE) begin
            sqr = uart_sequencer::type_id::create("sqr", this);
            drv = uart_driver::type_id::create("drv", this);
        end
        
        mon = uart_mon::type_id::create("mon", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);           
        end

        ap_port = mon.ap_port;
    endfunction

endclass