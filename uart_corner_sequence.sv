class uart_corner_sequence extends uvm_sequence #(uart_trans);  
    `uvm_object_utils(uart_corner_sequence);

    uart_trans utrans;
    
    function new (string name = "uart_corner_sequence"); 
        super.new(name);
    endfunction

    virtual task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        for(int i = 0; i < 20; i++) begin
            utrans = uart_trans::type_id::create("utrans");
            randcase
                2: utrans.tx_data = 8'h00;
                2: utrans.tx_data = 8'hFF;
                1: utrans.tx_data = 8'h55;
                1: utrans.tx_data = 8'hAA;
            endcase

            start_item(utrans);
            finish_item(utrans);
        end

        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask
endclass