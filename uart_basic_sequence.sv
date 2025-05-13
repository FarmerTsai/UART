class uart_basic_sequence extends uvm_sequence #(uart_trans);  
    `uvm_object_utils(uart_basic_sequence);

    uart_trans utrans;
    
    function new (string name = "uart_basic_sequence"); 
        super.new(name);
    endfunction

    task body();
        if(starting_phase != null)
            starting_phase.raise_objection(this);

        for(int i = 0; i < 20; i++) begin
            utrans = uart_trans::type_id::create("utrans");
            if(i == 1) begin // for min
                utrans.tx_data = 8'h00;                
            end
            else if(i == 2) begin // for max
                utrans.tx_data = 8'hFF;
            end
            else if( i >= 3 && i <= 10) begin // for consecutive inverse data
                randcase
                    1: utrans.tx_data = 8'hAA;
                    1: utrans.tx_data = 8'h55;
                endcase
            end
            else begin
                if(!utrans.randomize())
                    `uvm_error("uart_basic_sequence", "Randomize failed!");
            end

            start_item(utrans);
            finish_item(utrans);
        end

        if(starting_phase != null)
            starting_phase.drop_objection(this);
    endtask
endclass