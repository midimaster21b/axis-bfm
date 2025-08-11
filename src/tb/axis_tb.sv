module axis_tb;

   parameter int NUM_FIFO_BYTES_P     = 4;
   parameter int NUM_FIFO_USER_BITS_P = 4;
   parameter int NUM_FIFO_DEST_BITS_P = 4;
   parameter int NUM_FIFO_ID_BITS_P   = 4;

   logic clk  = 0;
   logic rstn = 0;

   logic tvalid;
   logic tready;
   logic [31:0] tdata;
   logic [3:0]	tstrb;
   logic [3:0]	tkeep;
   logic	tlast;
   logic [3:0]	tid;
   logic [3:0]	tdest;
   logic [3:0]	tuser;


   logic [31:0] test_tdata;
   logic [3:0]	test_tstrb;
   logic [3:0]	test_tkeep;
   logic	test_tlast;
   logic [3:0]	test_tid;
   logic [3:0]	test_tdest;
   logic [3:0]	test_tuser;

   // axis_if connector(.aclk(clk), .aresetn(rstn));
   axis_if #(.TDATA_BYTES(NUM_FIFO_BYTES_P), .TDEST_BITS(NUM_FIFO_DEST_BITS_P), .TID_BITS(NUM_FIFO_ID_BITS_P), .TUSER_BITS(NUM_FIFO_USER_BITS_P)) connector(.aclk(clk), .aresetn(rstn));

   assign tvalid = connector.tvalid;
   assign tready = connector.tready;
   assign tdata  = connector.tdata;
   assign tstrb  = connector.tstrb;
   assign tkeep  = connector.tkeep;
   assign tlast  = connector.tlast;
   assign tid    = connector.tid;
   assign tdest  = connector.tdest;
   assign tuser  = connector.tuser;

   always #10 clk = ~clk;

   initial begin
      $display("============================");
      $display("======== TEST START ========");
      $display("============================");

      #200ns;
      rstn = '1;
      #200ns;

      dut_slave.expect_beat(.tdata(32'h1234ABCD), .tstrb(4'hF), .tkeep(4'hF));
      // dut_master.write(.tdata(32'h1234ABCD), .tstrb(4'hF), .tkeep(4'hF));
      dut_master.write(.tdata(32'h1234ABCD), .tstrb(4'hF), .tkeep(4'hF));

      // This is a blocking task
      dut_slave.read(.tdata(test_tdata), .tstrb(test_tstrb), .tkeep(test_tkeep), .tlast(test_tlast), .tid(test_tid), .tdest(test_tdest), .tuser(test_tuser));
   end // initial begin

   // Timeout
   initial begin
      #1ms;

      $display("============================");
      $display("======= TEST TIMEOUT =======");
      $display("============================");
      $finish;
   end

   axis_master_bfm dut_master(connector);
   axis_slave_bfm  dut_slave(connector);
endmodule // axis_tb
