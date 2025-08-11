module axis_tb;

   logic clk  = 0;
   logic rstn = 0;

   logic tvalid;
   logic tready;
   logic [31:0] tdata;
   logic [3:0]	tstrb;
   logic [3:0]	tkeep;
   logic	tlast;
   logic	tid;
   logic [0:0]	tdest;
   logic [0:0]	tuser;


   logic [31:0] test_tdata;
   logic [3:0]	test_tstrb;
   logic [3:0]	test_tkeep;
   logic	test_tlast;
   logic	test_tid;
   logic [0:0]	test_tdest;
   logic [0:0]	test_tuser;

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

   always #10 clk = ~clk;

   initial begin
      $display("============================");
      $display("======== TEST START ========");
      $display("============================");

      #5us;
      rstn = '1;
      #5us;

      dut_slave.expect_beat(.tdata(32'h1234ABCD), .tstrb(8'hFF), .tkeep(8'hFF));
      dut_master.write(.tdata(32'h1234ABCD), .tstrb(8'hFF), .tkeep(8'hFF));

      // This is a blocking task
      dut_slave.read(.tdata(test_tdata), .tstrb(test_tstrb), .tkeep(test_tkeep), .tlast(test_tlast), .tid(test_tid), .tdest(test_tdest), .tuser(test_tuser));

      #1ms;

      $display("============================");
      $display("======= TEST TIMEOUT =======");
      $display("============================");
      $finish;
   end

   axis_master_bfm dut_master(connector);
   axis_slave_bfm  dut_slave(connector);
endmodule // axis_tb
