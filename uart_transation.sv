class uart_trans extends uvm_sequence_item;         
	rand bit [7:0] tx_data;
	bit [7:0] rx_data;

	bit do_reset;

	`uvm_object_utils_begin(uart_trans)
		`uvm_field_int(tx_data, UVM_ALL_ON);
		`uvm_field_int(rx_data, UVM_ALL_ON);
	`uvm_object_utils_end
   
	function new (string name = "uart_trans");
    	super.new(name);
	endfunction  
endclass