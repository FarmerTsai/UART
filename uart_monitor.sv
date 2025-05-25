class uart_mon extends uvm_monitor;
	`uvm_component_utils(uart_mon)
	
	virtual uart_if vif;
	uvm_analysis_port #(uart_trans) tx2scb_port; // tx output to scoreboard
	uvm_analysis_port #(uart_trans) rx2mdl_port; // rx input to model
	uvm_analysis_port #(uart_trans) dut2scb_port; // dut to scoreboard
	uvm_analysis_port #(uart_trans) cov_port;

	bit is_o_agt = 0;
	
	function new(string name = "uart_mon", uvm_component parent);
		super.new(name, parent);
	endfunction

	extern function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
endclass

function void uart_mon::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(get_name() == "mon" && get_parent().get_name() == "o_agt") begin
		is_o_agt = 1;
	end else begin
		is_o_agt = 0;
	end

	if(!uvm_config_db #(virtual uart_if)::get(this, "", "a_if", vif)) begin
		`uvm_error("uart_monitor", "virtual interface must be set for vif")
	end

	if(!is_o_agt) begin
		tx2scb_port = new("tx2scb_port", this);
	end
	else if(is_o_agt) begin
		rx2mdl_port = new("rx2mdl_port", this);
		dut2scb_port = new("dut2scb_port", this);
	end
	cov_port = new("cov_port", this);
endfunction

task uart_mon::run_phase(uvm_phase phase);
	uart_trans mtrans;
	uart_trans ctrans;
	
	fork
		// i_agt.mon: tx output to scoreboard
		if(!is_o_agt) begin
			forever begin
				@(posedge vif.clk);
				if(vif.tx_en) begin
					// capture tx output data
				end
			end
		end

		if(is_o_agt) begin
			// o_agt.mon: rx input to model
			forever begin
				@(posedge vif.clk);
				if(vif.tx_en) begin
					// capture rx serial data
				end
			end
			// o_agt.mon: DUT rx_data to scoreboard
			forever begin
    			@(posedge vif.clk);
				if(vif.rx_ready) begin
					mtrans = uart_trans::type_id::create("mtrans");
					mtrans.rx_data = vif.rx_data;
					`uvm_info("uart_monitor", $sformatf("Captured RX data: %0h", mtrans.rx_data), UVM_MEDIUM);

					// for error test
					/*if($urandom_range(0, 100) < 10) begin
						`uvm_warning("uart_monitor", "Drop this RX data!!!");
					end
					else
      					dut2scb_port.write(mtrans);*/
				
					dut2scb_port.write(mtrans);
				end
    		end
		end

		// coverage
		forever begin
			@(posedge vif.clk);
			ctrans = uart_trans::type_id::create("ctrans");
			ctrans.tx_data = vif.tx_data;
			ctrans.baud_tr = vif.BAUD_RATE;
			if(!is_o_agt)
				cov_port.write(ctrans);
		end
	join
endtask