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