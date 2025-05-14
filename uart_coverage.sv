class uart_coverage extends uvm_subscriber #(uart_trans);
    `uvm_component_utils(uart_coverage);

    uart_trans tr;

    covergroup uart_cov;
        option.comment = "Coverage for uart";

        tx_data_cp: coverpoint(tr.tx_data)
        {
            bins min = {0};
            bins bin0 = {[1:31]};
            bins bin1 = {[32:63]};
            bins bin2 = {[64:95]};
            bins bin3 = {[96:126]};
            bins mid = {127};
            bins bin4 = {[128:158]};
            bins bin5 = {[159:190]};
            bins bin6 = {[191:222]};
            bins bin7 = {[223:254]};
            bins max = {255};
        }

        baud_rate_cp: coverpoint(tr.baud_tr)
        {
            bins rate_0 = {4800};
            bins rate_1 = {9600};
            bins rate_2 = {19200};
            bins rate_3 = {38400};
            bins rate_4 = {57600};
            bins rate_5 = {115200};
        }

        data_baud_cross: cross tx_data_cp, baud_rate_cp;
    endgroup

    function new(string name = "uart_coverage", uvm_component parent);
        super.new(name, parent);
        uart_cov = new();
    endfunction

    function void write(uart_trans t);
        tr = t;
        uart_cov.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_full_name(), $sformatf("Coverage is %0.2f %%", uart_cov.get_coverage()), UVM_LOW);        
    endfunction

endclass