class uart_mon extends uvm_monitor;
	`uvm_component_utils(uart_mon)
	
	virtual uart_if mif;
	uvm_analysis_port #(uart_trans) ap_port;
	uvm_analysis_port #(uart_trans) cov_port;

	bit is_o_agt = 0;
	
	function new(string name = "uart_mon", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
	  	super.build_phase(phase);

		if(get_name() == "mon" && get_parent().get_name() == "o_agt") begin
			is_o_agt = 1;
		end else begin
			is_o_agt = 0;
		end

	  	ap_port = new("ap_port", this);
		cov_port = new("cov_port", this);

		// env_a
		if(get_parent().get_parent().get_name() == "env_a") begin
			if(!uvm_config_db #(virtual uart_if)::get(this, "", "a_if", mif)) begin
		    	`uvm_error("env_a.mon", "virtual interface must be set for mif")
			end
		end
		// env_b
		else
			if(!uvm_config_db #(virtual uart_if)::get(this, "", "b_if", mif)) begin
		    	`uvm_error("env_b.mon", "virtual interface must be set for mif")
			end
		
	endfunction
	
	extern virtual task run_phase(uvm_phase phase);
endclass

task uart_mon::run_phase(uvm_phase phase);
	uart_trans mtrans;
	uart_trans ctrans;
	
	fork
		forever begin
    		@(posedge mif.clk);
			if(mif.rx_ready) begin
				mtrans = uart_trans::type_id::create("mtrans");
				mtrans.rx_data = mif.rx_data;
				if(is_o_agt)
					`uvm_info("uart_monitor", $sformatf("Captured RX data: %0h", mtrans.rx_data), UVM_MEDIUM);

				// for error test
				/*if($urandom_range(0, 100) < 10) begin
					`uvm_warning("uart_monitor", "Drop this RX data!!!");
				end
				else
      				ap_port.write(mtrans);*/
				
				ap_port.write(mtrans);
			end
    	end
		
		// coverage
		forever begin
			@(posedge mif.clk);
			ctrans = uart_trans::type_id::create("ctrans");
			ctrans.tx_data = mif.tx_data;
			ctrans.baud_tr = mif.BAUD_RATE;
			if(!is_o_agt)
				cov_port.write(ctrans);
		end
	join
endtask