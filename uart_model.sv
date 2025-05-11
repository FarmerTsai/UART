/*
Date: 20250506
Author: Ethan
Brief: A basic model to mimic the behavior of the UART DUT
*/

class uart_model extends uvm_component;
    `uvm_component_utils(uart_model);

    uvm_blocking_get_port #(uart_trans) tx_in_port; // from env_tx driver
    uvm_blocking_get_port #(uart_trans) rx_in_port; // from env_rx driver
    uvm_analysis_port #(uart_trans) tx_out_port; // env_tx to scoreboard
    uvm_analysis_port #(uart_trans) rx_out_port; // env_rx to scoreboard

    function new(string name = "uart_model", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        tx_in_port = new("tx_in_port", this);
        tx_out_port = new("tx_out_port", this);

        rx_in_port = new("rx_in_port", this);
        rx_out_port = new("rx_out_port", this);
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
        // env_tx -> env_rx
        forever begin
            tx_in_port.get(in_tran);
            `uvm_info("uart_model", $sformatf("env_tx: Got from driver tx_data = %0h", in_tran.tx_data), UVM_MEDIUM);

            encode_bits = encode(in_tran.tx_data);
            decode_byte = decode(encode_bits);
            
            out_tran = uart_trans::type_id::create("out_tran");
            //out_tran.rx_data = in_tran.tx_data;
            out_tran.rx_data = decode_byte;

            `uvm_info("uart_model", $sformatf("env_tx: Send to scoreboard rx_data = %0h", out_tran.rx_data), UVM_MEDIUM);
            tx_out_port.write(out_tran);
        end
        // env_rx -> env_tx
        forever begin
            rx_in_port.get(in_tran);
            `uvm_info("uart_model", $sformatf("env_rx: Got from driver tx_data = %0h", in_tran.tx_data), UVM_MEDIUM);

            encode_bits = encode(in_tran.tx_data);
            decode_byte = decode(encode_bits);

            out_tran = uart_trans::type_id::create("out_tran");
            //out_tran.rx_data = in_tran.tx_data;
            out_tran.rx_data = decode_byte;

            `uvm_info("uart_model", $sformatf("env_rx: Send to scoreboard rx_data = %0h", out_tran.rx_data), UVM_MEDIUM);
            rx_out_port.write(out_tran);
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

    for(int i= 0 ; i < 8; i++) begin
        data[i] = out[i + 1]; // only tx_data
    end

    return data;
endfunction