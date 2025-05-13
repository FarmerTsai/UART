class uart_basic_test extends uart_base_test;  
    `uvm_component_utils(uart_basic_test);

    function new(string name, uvm_component parent);
    	super.new(name, parent);
    endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
endclass

function void uart_basic_test::build_phase(uvm_phase phase);
	randcase
		1: BAUD_RATE = 4800;
		1: BAUD_RATE = 9600;
		1: BAUD_RATE = 19200;
		1: BAUD_RATE = 38400;
		1: BAUD_RATE = 57600;
		1: BAUD_RATE = 115200;
	endcase

	`uvm_info("uart_basic_test", $sformatf("Random BAUD RATE is: %0d", BAUD_RATE), UVM_LOW);
	super.build_phase(phase);
endfunction

task uart_basic_test::run_phase(uvm_phase phase);
	uart_basic_sequence a_seq, b_seq;
		fork
			begin
				// sequence for env_a
				a_seq = uart_basic_sequence::type_id::create("a_seq");
    			a_seq.starting_phase = phase;
    			a_seq.start(env_top.env_a.i_agt.sqr);
			end
			begin
				// sequence for env_b
				b_seq = uart_basic_sequence::type_id::create("b_seq");
    			b_seq.starting_phase = phase;
    			b_seq.start(env_top.env_b.i_agt.sqr);
			end
		join
endtask