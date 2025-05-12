# UART_UVM

## UART
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