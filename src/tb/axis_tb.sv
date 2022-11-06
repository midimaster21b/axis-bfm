module axis_tb;

   logic clk  = 0;
   logic rstn = 0;

   logic tvalid;
   logic tready;
   logic [31:0] tdata;
   logic [7:0]	tstrb;
   logic [7:0]	tkeep;
   logic	tlast;
   logic	tid;
   logic [0:0]	tdest;
   logic [0:0]	tuser;

   axis_if connector(.aclk(clk), .aresetn(rstn));

   assign tvalid = connector.tvalid;
   assign tready = connector.tready;
   assign tdata  = connector.tdata;
   assign tstrb  = connector.tstrb;
   assign tkeep  = connector.tkeep;
   assign tlast  = connector.tlast;
   assign tid    = connector.tid;
   assign tdest  = connector.tdest;
   assign tuser  = connector.tuser;

   initial begin
      forever begin
	 #10 clk = ~clk;
      end
   end

   initial begin
      connector.tready = '0;
      #110;
      connector.tready = '1;
   end

   axis_master_bfm dut_master(connector);
   axis_slave_bfm  dut_slave(connector);
endmodule // axis_tb
