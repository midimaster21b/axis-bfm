# AXIS Bus Functional Model (BFM)

A simple AXIS BFM.

## Usage

### FuseSoC Testbench

```
asdf install                      # Install all tool versions specified in .tool-versions
python -m venv .pyenv             # Create a python virtual environment
source ./.pyenv/bin/activate      # Activate the python virtual environment
pip install -r requirements.txt   # Install the python requirements for this module
fusesoc --cores-root . run --target=sim midimaster21b:bfm:axis:0.2.0  # Run the simulation
```

### Simulation

See the simulation file in `./src/tb/axis_tb.sv` for an example usage of the BFMs.

For each interface you'll need

1. An interface connector `axis_if connector(.aclk(clk), .aresetn(rstn));`
1. Instantiate the BFMs:
   - ```axis_master_bfm dut_master(connector);
	axis_slave_bfm  dut_slave(connector);```
1. Write to the master BFM `dut_master.write(.tdata(32'h1234ABCD), .tstrb(8'hFF), .tkeep(8'hFF));`
