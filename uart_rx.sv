module uart_rx(
    input clk,
    input rst_n,
    //input parity_mode, // 0: even, 1: odd
    input uart_rxd, // receive pin

    output reg [7:0] rx_data, // receive data
    output reg rx_ready // receive finish
    //output reg parity_error // 0: parity pass, 1: parity error
);
// clk parameter
//parameter BAUD_RATE = 9600;
//parameter CLK_FREQ = 50000000; // 50MHZ
//parameter DIV = CLK_FREQ / BAUD_RATE;

parameter BAUD_RATE = 100000; // for test
parameter CLK_FREQ = 1000000; // 1MHZ
parameter DIV = CLK_FREQ / BAUD_RATE; // 10

// FSM parameter
parameter IDLE = 0;
parameter START = 1;
parameter RECEIVE = 2;
parameter STOP = 3;

reg [1:0] cur_state, next_state;
reg [31:0] count;
reg [3:0] bit_cnt; // receive bit counter, 8 bit
reg parity_bit;

// uart_rxd edge detect
reg uart_rxd_d;
wire uart_rxd_neg = (uart_rxd_d == 1 && uart_rxd == 0); // cehck start bit

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        uart_rxd_d <= 1;
    else
        uart_rxd_d <= uart_rxd;
end

// update FSM state
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cur_state <= IDLE;
    else
        cur_state <= next_state;
end

// next state logic
always @(*) begin
    case(cur_state)
        IDLE: begin
            if(uart_rxd_neg) // start 
                next_state = START;
            else
                next_state = IDLE;
        end
        START: begin
            if(count == DIV - 1)
                next_state = RECEIVE;
            else
                next_state = START; 
        end
        RECEIVE: begin
            if(bit_cnt == 7 && count == DIV - 1) // finish receive
                next_state = STOP;
            else
                next_state = RECEIVE; 
        end
        STOP: begin
            if(count == DIV - 1 && uart_rxd == 1'b1)
                next_state = IDLE;
            else
                next_state = STOP;                
        end 
        default: next_state = IDLE;
    endcase
end

// count
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        count <= 0;
    else if(cur_state != IDLE) begin
        if(count == DIV - 1)
            count <= 0;
        else
            count <= count + 1; 
    end else
        count <= 0;
end

// receive bit count
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        bit_cnt <= 0;
    else if(cur_state == RECEIVE && count == DIV - 1 && bit_cnt < 8)
        bit_cnt <= bit_cnt + 1;
    else if(cur_state == STOP && count == DIV - 1)
        bit_cnt <= 0;
end

// receive data process
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_data <= 0;
        //parity_bit <= 0;
    end
    else if(cur_state == RECEIVE && count == DIV/2 - 1) begin
        // bit_cnt start with 0
        if(bit_cnt < 8)
            rx_data[bit_cnt] <= uart_rxd;
        /*else if(bit_cnt == 8)
            parity_bit <= uart_rxd;*/
    end
end

// expected parity bit
/*wire exp_parity;
assign exp_parity = parity_mode? ~^rx_data:^rx_data;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        parity_error <= 0;
    else if(cur_state == STOP && count == DIV - 1)
        parity_error <= (exp_parity != parity_bit); 
end*/

// finish receive, handshake for future
/*reg [3:0] rx_ready_cnt; // to hold rx_ready
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_ready <= 0;
        rx_ready_cnt <= 0;
    end
    else if (cur_state == STOP && count == DIV - 1 && uart_rxd == 1'b1) begin // check stop bit
        rx_ready <= 1;
        rx_ready_cnt <= DIV - 1;
    end
    else if (rx_ready_cnt > 0)
        rx_ready_cnt <= rx_ready_cnt - 1;
    else
        rx_ready <= 0;
end*/

// finish receive
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_ready <= 0;
    end
    else if (cur_state == STOP && count == DIV - 1 && uart_rxd == 1'b1) begin // check stop bit
        rx_ready <= 1;
    end
    else
        rx_ready <= 0;
end

endmodule