class uart_driver extends uvm_driver #(uart_trans);
    `uvm_component_utils(uart_driver);

    uvm_analysis_port #(uart_trans) drv2scb_port;

    virtual uart_if a_if;
    virtual uart_if b_if;

    reg [7:0] data;
    int no_transactions;

    function new(string name = "uart_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv2scb_port = new("put_port", this);

        `uvm_info("uart_driver", "build_phase is called", UVM_LOW);
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "a_if", a_if))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for a_if!");
        end
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "b_if", b_if))begin
            `uvm_fatal("uart_driver", "virtual interface must be set for b_if!");
        end
    endfunction

    extern virtual task run_phase(uvm_phase phase);
endclass

task uart_driver::run_phase(uvm_phase phase);
    uart_trans a_req;

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
        drv2scb_port.put(a_req); // to model
        // wait env_b dut receive data
        //wait(b_if.rx_ready == 1);
        repeat(a_if.DIV * 10) @(posedge a_if.clk); // DIV * (1 start bit + 8 data bit + 1 stop bit)
        $display("env_a: A sequence is finish!");

        repeat(10) @(posedge a_if.clk);

        seq_item_port.item_done();
    end   
endtask