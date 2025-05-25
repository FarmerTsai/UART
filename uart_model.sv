/*
Date: 20250506
Author: Ethan
Brief: A basic model to mimic the behavior of the UART DUT
*/

class uart_model extends uvm_component;
    `uvm_component_utils(uart_model);

    int dut_num;

    uvm_blocking_get_port #(uart_trans) in_port[]; // from DUT rx input
    uvm_analysis_port #(uart_trans) out_port; // to scoreboard

    function new(string name = "uart_model", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // get dut amount
	    if(!uvm_config_db #(int)::get(this, "", "dut_num", dut_num))
		    `uvm_fatal("model", "dut_num must be set!");
        
        in_port = new[dut_num];
        for(int i = 0; i < dut_num; i++)
            in_port[i] = new($sformatf("in_port[%0d]", i), this);

        out_port = new("out_port", this);
    endfunction

    extern virtual task run_phase(uvm_phase phase);
    extern virtual function bit[9:0] encode(bit[9:0]); // parallel to sequence
    extern virtual function bit[9:0] decode(bit[9:0]); // sequence to parallel
endclass

task uart_model::run_phase(uvm_phase phase);
    uart_trans in_tran, out_tran;
    bit [9:0] encode_bits, decode_bits;
    super.run_phase(phase);

    fork
        // env_a -> env_b
        forever begin
            in_port[0].get(in_tran);
            `uvm_info("uart_model", $sformatf("env_a: Got from driver tx_data = %0h", in_tran.tx_data), UVM_MEDIUM);

            encode_bits = encode(in_tran.tx_data);
            decode_bits = decode(encode_bits);
            
            out_tran = uart_trans::type_id::create("out_tran");
            //out_tran.rx_data = in_tran.tx_data;
            if(in_tran.do_reset)
                out_tran.rx_data = 0;
            else
                out_tran.rx_data = decode_bits;

            `uvm_info("uart_model", $sformatf("env_a: Send to scoreboard rx_data = %0h", out_tran.rx_data), UVM_MEDIUM);
            out_port.write(out_tran);
        end
    join
endtask

function bit[9:0] uart_model::encode(bit[9:0] in);
    bit [9:0] bits;

    bits[0] = 1'b0; // start bit
    for(int i = 0; i < 8; i++) begin // tx_data
        bits[i + 1] = in[i]; // bits[1] = tx_data[0]
    end
    bits[9] = 1'b1; // stop bit;

    return bits;
endfunction

function bit[9:0] uart_model::decode(bit [9:0] out);
    bit[9:0] data;

    for(int i= 0 ; i < 10; i++) begin
        if(i == 0) begin
            assert (out[i] == 0) 
            else  `uvm_error("uart_model", $sformatf("start bit is not 0!"));
            data[i] = out[i];
        end            
        else if(i == 9) begin
            assert (out[i] == 1) 
            else  `uvm_error("uart_model", $sformatf("stop bit is not 1!"));
            data[i] = out[i];
        end            
        else
            data[i] = out[i]; // only tx_data
    end

    return data;
endfunction