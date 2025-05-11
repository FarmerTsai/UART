class uart_driver extends uvm_driver #(uart_trans);
    `uvm_component_utils(uart_driver);

    uvm_blocking_put_port #(uart_trans) drv2mdl_port;

    virtual uart_if tx_if;
    virtual uart_if rx_if;

    bit is_tx;
    reg [7:0] data;
    int no_transactions;

    function new(string name = "uart_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv2mdl_port = new("put_port", this);

        `uvm_info("uart_driver", "build_phase is called", UVM_LOW);
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "tx_if", tx_if))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for vif!");
        end
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "rx_if", rx_if))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for rx_if!");
        end
        if(!uvm_config_db #(bit)::get(this, "", "is_tx", is_tx))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for is_tx!");
        end
    endfunction

    extern virtual task run_phase(uvm_phase phase);
endclass

task uart_driver::run_phase(uvm_phase phase);
    uart_trans tx_req, rx_req;

    // env_tx
    if(is_tx) begin
        `uvm_info(get_full_name(), $sformatf("is_tx = %0d", is_tx), UVM_MEDIUM);
        forever begin
            seq_item_port.get_next_item(tx_req);
            `uvm_info("uart_driver", $sformatf("env_tx: Got item from sequencer tx_data = %0h", tx_req.tx_data), UVM_MEDIUM);

            @(posedge tx_if.clk);
            tx_if.tx_data <= tx_req.tx_data;
            //tx_if.tx_data <= tx_if.tx_data << 1; // for error test
            tx_if.tx_en <= 1;
            //tx_if.parity_mode <= tx_req.parity_mode;

            @(posedge tx_if.clk);
            tx_if.tx_en <= 0;
            drv2mdl_port.put(tx_req); // to model
            // wait env_rx receive data
            wait(rx_if.rx_ready == 1);
            $display("env_tx: A sequence is finish!");

            repeat(10) @(posedge tx_if.clk);

            seq_item_port.item_done();
        end
    end
    // env_rx
    else if(!is_tx) begin
        `uvm_info(get_full_name(), $sformatf("is_tx = %0d", is_tx), UVM_MEDIUM);
        forever begin
            seq_item_port.get_next_item(rx_req);
            `uvm_info("uart_driver", $sformatf("env_rx: Got item from sequencer tx_data = %0h", rx_req.tx_data), UVM_MEDIUM);

            @(posedge rx_if.clk);
            rx_if.tx_data <= rx_req.tx_data;
            rx_if.tx_en <= 1;
            //rx_if.parity_mode <= rx_req.parity_mode;

            @(posedge rx_if.clk);
            rx_if.tx_en <= 0;
            drv2mdl_port.put(rx_req); // to model
            // wait env_tx receive data
            wait(tx_if.rx_ready == 1);
            $display("env_rx: A sequence is finish!");

            repeat(10) @(posedge rx_if.clk);

            seq_item_port.item_done();
        end
    end
    
endtask