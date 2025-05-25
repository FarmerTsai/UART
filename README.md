# UART_UVM

## UART
- A basic UART for test UVM
- **Start bit**: 1 bit
- **Data bit**: 8 bits
- **Stop bit**: 1 bit

## UVM Environment
- Use two env to control two UART DUTs, can transmission data to each other

## Update Log
### 20250511 
- Added a bidirectional UART DUT UVM environment
### 20250512
- change env_tx/rx to env_a/b
### 20250513
- add basic/corner/special test & sequence
- add model reset, and can detect that DUT dose not actually reset in special case
- can random BAUD RATE and set DIV in config_db
### 20250514
- add BAUD RATE coverage

### 20250525
- according to supervisor's instructions, some features will be modify
- remove env_top, and create the env based on DUT number
- i_agt monitor will capture tx signal, including start bit and stop bit
- o_agt monitor will capture rx input and pass to the model

### 20250526
- will change to multi env and every env will have independent model, scoreboard
- DUT will not send data to another DUT