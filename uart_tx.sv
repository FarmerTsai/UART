`timescale 1ns/1ps
module uart_tx (
    input clk, // system clock
    input rst_n, // asynchronous active low reset
    //input parity_mode, // 0: even, 1: odd
    input tx_en,
    input [7:0] tx_data,

    output reg uart_txd, // uart transmittion data
    output reg tx_done // pull high when tx_data is send finish
);
// clk parameter
//parameter BAUD_RATE = 9600;
//parameter CLK_FREQ = 50000000; // 50MHZ
//parameter DIV = CLK_FREQ / BAUD_RATE;
// 1 start bit + 8 data bit + 1 stop bit
// => 10 bit, need 5208 * 10 clock

parameter BAUD_RATE = 100000; // for test
parameter CLK_FREQ = 1000000; // 1MHZ
parameter DIV = CLK_FREQ / BAUD_RATE; // 10

// FSM parameter
parameter IDLE = 0;
parameter START = 1;
parameter SEND = 2;
parameter STOP = 3;

reg [1:0] cur_state, next_state;
reg [31:0] count;
reg [3:0] bit_cnt; // send bit counter

// FSM
// update FSM state
always@(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        cur_state <= IDLE;
    end else begin
        cur_state <= next_state;
    end
end

// next state logic
always@(*) begin
    case (cur_state)
        IDLE: begin
            //$display("FSM is in IDLE state");
            if(tx_en)
                next_state = START;
            else
                next_state = IDLE; 
        end
        START: begin
            //$display("FSM is in START state");
            if(count == DIV - 1)
                next_state = SEND;
            else
                next_state = START; 
        end
        SEND:begin
            //$display("FSM is in SEND state");
            if(bit_cnt == 7 && count == DIV - 1) // add parity bit
                next_state = STOP;
            else
                next_state = SEND;
        end
        STOP: begin
            //$display("FSM is in STOP state");
            if(count == DIV - 1)
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

// count send bit
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        bit_cnt <= 0;
    else if(cur_state == SEND && count == DIV -1)
        bit_cnt <= bit_cnt + 1;
    else if(cur_state != SEND)
        bit_cnt <= 0;
end

// count parity
/*wire parity_bit;
assign parity_bit = (parity_mode)? ~^tx_data:^tx_data;*/

// send data
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        uart_txd <= 1;
    else begin
        case(cur_state)
            IDLE: begin
                uart_txd <= 1;
            end
            START: begin
                uart_txd <= 0;
            end
            SEND: begin
                if(bit_cnt < 8)
                    uart_txd <= tx_data[bit_cnt];
                /*else if(bit_cnt == 8)
                    uart_txd <= parity_bit;*/
                else
                    uart_txd <= 1;
            end
            STOP: begin
                uart_txd <= 1;
            end
            default: uart_txd <= 1;
        endcase
    end
end

// pull up tx_done when send data finish
/*reg [3:0] tx_done_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tx_done <= 1'b0;
        tx_done_cnt <= 0;
    end
    else if(cur_state == STOP && count == DIV - 1) begin
        tx_done <= 1'b1;
        tx_done_cnt <= DIV - 1;
    end
    else if(tx_done_cnt > 0)
        tx_done_cnt <= tx_done_cnt - 1;
    else
        tx_done <= 1'b0; 
end*/

// pull up tx_done when send data finish
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tx_done <= 1'b0;
    end
    else if(cur_state == STOP && count == DIV - 1) begin
        tx_done <= 1'b1;
    end
    else
        tx_done <= 1'b0; 
end
    
endmodule