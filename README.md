UART_UVM
20250511 add a bidirectional UART DUT UVM environment
uart_test
│
└── uart_env
    ├── uart_env_tx
    │   ├── i_agent
    │   │   ├── uart_sequencer
    │   │   └── uart_driver
    │   └── o_agent
    │       └── uart_monitor
    │
    ├── uart_env_rx
    │   ├── i_agent
    │   │   ├── uart_sequencer
    │   │   └── uart_driver
    │   └── o_agent
    │       └── uart_monitor
    │
    ├── uart_model
    │   ├── tx_in_port  <--  uart_env_tx.i_agent.driver
    │   ├── rx_in_port  <--  uart_env_rx.i_agent.driver
    │   ├── tx_out_port -->  scoreboard (tx side)
    │   └── rx_out_port -->  scoreboard (rx side)
    │
    ├── scoreboard
    │
    └── model