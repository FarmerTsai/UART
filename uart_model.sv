/*
Date: 20250506
Author: Ethan
Brief: A basic model to mimic the behavior of the UART DUT
*/

class uart_model extends uvm_component;
    `uvm_component_utils(uart_model);

    uvm_blocking_get_port #(uart_trans) a_in_port; // from env_a driver
    uvm_analysis_port #(uart_trans) a_out_port; // env_a to scoreboard

    uvm_blocking_get_port #(uart_trans) b_in_port; // from env_b driver    
    uvm_analysis_port #(uart_trans) b_out_port; // env_b to scoreboard

    function new(string name = "uart_model", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        a_in_port = new("a_in_port", this);
        a_out_port = new("a_out_port", this);

        b_in_port = new("b_in_port", this);
        b_out_port = new("b_out_port", this);
    endfunction

    extern virtual task run_phase(uvm_phase phase);
    extern virtual function bit[9:0] encode(byte); // parallel to sequence
    extern virtual function byte decode(bit[9:0]); // sequence to parallel
endclass

task uart_model::run_phase(uvm_phase phase);
    uart_trans in_tran, out_tran;
    bit [9:0] encode_bits;
    byte decode_byte;
    super.run_phase(phase);

    fork
        // env_a -> env_b
        forever begin
            a_in_port.get(in_tran);
            `uvm_info("uart_model", $sformatf("env_a: Got from driver tx_data = %0h", in_tran.tx_data), UVM_MEDIUM);

            encode_bits = encode(in_tran.tx_data);
            decode_byte = decode(encode_bits);
            
            out_tran = uart_trans::type_id::create("out_tran");
            //out_tran.rx_data = in_tran.tx_data;
            out_tran.rx_data = decode_byte;

            `uvm_info("uart_model", $sformatf("env_a: Send to scoreboard rx_data = %0h", out_tran.rx_data), UVM_MEDIUM);
            a_out_port.write(out_tran);
        end

        // env_b -> env_a
        forever begin
            b_in_port.get(in_tran);
            `uvm_info("uart_model", $sformatf("env_b: Got from driver tx_data = %0h", in_tran.tx_data), UVM_MEDIUM);

            encode_bits = encode(in_tran.tx_data);
            decode_byte = decode(encode_bits);

            out_tran = uart_trans::type_id::create("out_tran");
            //out_tran.rx_data = in_tran.tx_data;
            out_tran.rx_data = decode_byte;

            `uvm_info("uart_model", $sformatf("env_b: Send to scoreboard rx_data = %0h", out_tran.rx_data), UVM_MEDIUM);
            b_out_port.write(out_tran);
        end
    join
endtask

function bit[9:0] uart_model::encode(byte in);
    bit [9:0] bits;

    bits[0] = 1'b0; // start bit
    for(int i = 0; i < 8; i++) begin // tx_data
        bits[i + 1] = in[i]; // bits[1] = tx_data[0]
    end
    bits[9] = 1'b1; // stop bit;

    return bits;
endfunction

function byte uart_model::decode(bit [9:0] out);
    byte data;

    for(int i= 0 ; i < 10; i++) begin
        if(i == 0) begin
            assert (out[i] == 0) 
            else  `uvm_error("uart_model", $sformatf("start bit is not 0!"));
        end            
        else if(i == 9) begin
            assert (out[i] == 1) 
            else  `uvm_error("uart_model", $sformatf("stop bit is not 1!"));
        end            
        else
            data[i - 1] = out[i]; // only tx_data
    end

    return data;
endfunction