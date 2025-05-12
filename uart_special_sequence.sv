class uart_special_sequence extends uvm_sequence #(uart_trans);  
    `uvm_object_utils(uart_special_sequence);

    uart_trans utrans;
    
    function new (string name = "uart_special_sequence"); 
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        utrans = uart_trans::type_id::create("utrans");
        utrans.tx_data = 8'hAA;
        utrans.do_reset = 1; // reset UART DUT

        start_item(utrans);
        finish_item(utrans);

        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask
endclass