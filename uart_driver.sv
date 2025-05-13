class uart_driver extends uvm_driver #(uart_trans);
    `uvm_component_utils(uart_driver);

    uvm_blocking_put_port #(uart_trans) drv2mdl_port;

    virtual uart_if a_if;
    virtual uart_if b_if;

    bit is_a;
    reg [7:0] data;
    int no_transactions;

    function new(string name = "uart_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv2mdl_port = new("put_port", this);

        `uvm_info("uart_driver", "build_phase is called", UVM_LOW);
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "a_if", a_if))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for a_if!");
        end
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "b_if", b_if))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for b_if!");
        end
        if(!uvm_config_db #(bit)::get(this, "", "is_a", is_a))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for is_a!");
        end
    endfunction

    extern virtual task run_phase(uvm_phase phase);
endclass

task uart_driver::run_phase(uvm_phase phase);
    uart_trans a_req, b_req;

    // env_a
    if(is_a) begin
        `uvm_info(get_full_name(), $sformatf("is_a = %0d", is_a), UVM_MEDIUM);
        // reset
        a_if.rst_n <= 0;
        @(posedge a_if.clk);
        a_if.rst_n <= 1;

        forever begin
            seq_item_port.get_next_item(a_req);
            `uvm_info("uart_driver", $sformatf("env_a: Got item from sequencer tx_data = %0h", a_req.tx_data), UVM_MEDIUM);

            @(posedge a_if.clk);
            a_if.tx_data <= a_req.tx_data;
            //tx_if.tx_data <= tx_if.tx_data << 1; // for error test
            a_if.tx_en <= 1;

            if(a_req.do_reset == 1) begin
                repeat(10) @(posedge a_if.clk); // wait transmission begin
                a_if.rst_n <= 0;
                @(posedge a_if.clk);
                a_if.rst_n <= 1;
            end
            
            @(posedge a_if.clk);
            a_if.tx_en <= 0;
            drv2mdl_port.put(a_req); // to model
            // wait env_b dut receive data
            //wait(b_if.rx_ready == 1);
            repeat(a_if.DIV * 10) @(posedge a_if.clk); // DIV * (1 start bit + 8 data bit + 1 stop bit)
            $display("env_a: A sequence is finish!");

            repeat(10) @(posedge a_if.clk);

            seq_item_port.item_done();
        end
    end

    // env_b
    else if(!is_a) begin
        `uvm_info(get_full_name(), $sformatf("is_a = %0d", is_a), UVM_MEDIUM);
        // reset
        b_if.rst_n <= 0;
        @(posedge b_if.clk);
        b_if.rst_n <= 1;

        forever begin
            seq_item_port.get_next_item(b_req);
            `uvm_info("uart_driver", $sformatf("env_b: Got item from sequencer tx_data = %0h", b_req.tx_data), UVM_MEDIUM);

            @(posedge b_if.clk);
            b_if.tx_data <= b_req.tx_data;
            b_if.tx_en <= 1;

            if(b_req.do_reset == 1) begin
                repeat(10) @(posedge b_if.clk); // wait transmission begin
                b_if.rst_n <= 0;
                @(posedge b_if.clk);
                b_if.rst_n <= 1;
            end

            @(posedge b_if.clk);
            b_if.tx_en <= 0;
            drv2mdl_port.put(b_req); // to model
            // wait env_a dut receive data
            //wait(a_if.rx_ready == 1);
            repeat(b_if.DIV * 10) @(posedge b_if.clk); // DIV * (1 start bit + 8 data bit + 1 stop bit)
            $display("env_b: A sequence is finish!");

            repeat(10) @(posedge b_if.clk);

            seq_item_port.item_done();
        end
    end
    
endtask