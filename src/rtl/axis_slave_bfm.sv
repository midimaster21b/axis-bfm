module axis_slave_bfm #(parameter
			ALWAYS_READY=1,
			FAIL_ON_MISMATCH=0,
			BFM_NAME="s_axis"
			) (conn);
   axis_if conn;

   typedef struct packed {
      logic [conn.NUM_DATA_BITS-1:0] tdata;
      logic [conn.NUM_STRB_BITS-1:0] tstrb;
      logic [conn.NUM_KEEP_BITS-1:0] tkeep;
      logic			     tlast;
      logic [conn.NUM_ID_BITS-1:0  ] tid;
      logic [conn.NUM_DEST_BITS-1:0] tdest;
      logic [conn.NUM_USER_BITS-1:0] tuser;
   } axis_beat_t;

   typedef mailbox		    #(axis_beat_t) axis_inbox_t;

   axis_inbox_t axis_inbox  = new();
   axis_inbox_t axis_expect = new();

   /**************************************************************************
    * Read a valid AXIS beat [BLOCKING]
    *
    * Output a validly read AXIS beat the output lines as soon as one is
    * available.
    **************************************************************************/
   task read (
	       output logic [conn.NUM_DATA_BITS-1:0] tdata,
	       output logic [conn.NUM_STRB_BITS-1:0] tstrb,
	       output logic [conn.NUM_KEEP_BITS-1:0] tkeep,
	       output logic			     tlast,
	       output logic [conn.NUM_ID_BITS-1:0  ] tid,
	       output logic [conn.NUM_DEST_BITS-1:0] tdest,
	       output logic [conn.NUM_USER_BITS-1:0] tuser
	       );

      axis_beat_t temp;

      begin
	 // Get beat from mailbox
	 s_axis.get_beat(temp);

	 // Output that a beat was received
	 $timeformat(-9, 2, " ns", 20);
	 $display("%t: %s - Received Data - Data: %X, Keep: %x, Last: %x, User: %x", $time, BFM_NAME, temp.tdata, temp.tkeep, temp.tlast, temp.tuser);

	 // Output the beat information to data lines
	 tdata = temp.tdata;
	 tstrb = temp.tstrb;
	 tkeep = temp.tkeep;
	 tlast = temp.tlast;
	 tid   = temp.tid;
	 tdest = temp.tdest;
	 tuser = temp.tuser;
      end
   endtask // write


   /**************************************************************************
    * Add a beat to the queue of AXIS beats to be expected
    **************************************************************************/
   task expect_beat (
		input logic [conn.NUM_DATA_BITS-1:0] tdata = 0,
		input logic [conn.NUM_STRB_BITS-1:0] tstrb = 0,
		input logic [conn.NUM_KEEP_BITS-1:0] tkeep = 0,
		input logic			     tlast = 0,
		input logic [conn.NUM_ID_BITS-1:0]   tid = 0,
		input logic [conn.NUM_DEST_BITS-1:0] tdest = 0,
		input logic [conn.NUM_USER_BITS-1:0] tuser = 0
	       );

      axis_beat_t temp;

      begin
	 temp.tdata  = tdata;
	 temp.tstrb  = tstrb;
	 temp.tkeep  = tkeep;
	 temp.tlast  = tlast;
	 temp.tid    = tid;
	 temp.tdest  = tdest;
	 temp.tuser  = tuser;

	 // Add output beat to mailbox
	 $timeformat(-9, 2, " ns", 20);
	 $display("%t: %s - Expecting Data - Data: %X, Keep: %x, Last: %x, User: %x", $time, BFM_NAME, temp.tdata, temp.tkeep, temp.tlast, temp.tuser);
	 s_axis.expect_beat(temp);

      end
   endtask // expect_beat

   ////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////
   // Interface connections
   ////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////
   localparam TUSER_WIDTH = conn.NUM_USER_BITS > 0 ? conn.NUM_USER_BITS : 1;
   localparam TDEST_WIDTH = conn.NUM_DEST_BITS > 0 ? conn.NUM_DEST_BITS : 1;
   localparam TID_WIDTH   = conn.NUM_ID_BITS   > 0 ? conn.NUM_ID_BITS   : 1;
   localparam TLAST_WIDTH = conn.NUM_LAST_BITS > 0 ? conn.NUM_LAST_BITS : 1;
   localparam TKEEP_WIDTH = conn.NUM_KEEP_BITS > 0 ? conn.NUM_KEEP_BITS : 1;
   localparam TSTRB_WIDTH = conn.NUM_STRB_BITS > 0 ? conn.NUM_STRB_BITS : 1;
   localparam TDATA_WIDTH = conn.NUM_DATA_BITS > 0 ? conn.NUM_DATA_BITS : 1;

   localparam TUSER_BASE = 0;
   localparam TDEST_BASE = TUSER_BASE + TUSER_WIDTH;
   localparam TID_BASE   = TDEST_BASE + TDEST_WIDTH;
   localparam TLAST_BASE = TID_BASE   + TID_WIDTH;
   localparam TKEEP_BASE = TLAST_BASE + TLAST_WIDTH;
   localparam TSTRB_BASE = TKEEP_BASE + TKEEP_WIDTH;
   localparam TDATA_BASE = TSTRB_BASE + TSTRB_WIDTH;

   localparam HS_BUS_WIDTH = TUSER_WIDTH + TDEST_WIDTH + TID_WIDTH + TLAST_WIDTH + TKEEP_WIDTH + TSTRB_WIDTH + TDATA_WIDTH;

   // Write address channel
   handshake_if    #(.DATA_BITS(HS_BUS_WIDTH)) axis_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.IFACE_NAME(BFM_NAME), .ALWAYS_READY('1), .FAIL_ON_MISMATCH(FAIL_ON_MISMATCH), .VERBOSE("FALSE")) s_axis (axis_conn);

   assign axis_conn.valid                                     = conn.tvalid;
   assign conn.tready                                         = axis_conn.ready;
   assign axis_conn.data[TDATA_WIDTH+TDATA_BASE-1:TDATA_BASE] = conn.tdata;
   assign axis_conn.data[TSTRB_WIDTH+TSTRB_BASE-1:TSTRB_BASE] = conn.tstrb;
   assign axis_conn.data[TKEEP_WIDTH+TKEEP_BASE-1:TKEEP_BASE] = conn.tkeep;
   assign axis_conn.data[TLAST_WIDTH+TLAST_BASE-1:TLAST_BASE] = conn.tlast;
   assign axis_conn.data[TID_WIDTH  +TID_BASE  -1:TID_BASE  ] = conn.tid;
   assign axis_conn.data[TDEST_WIDTH+TDEST_BASE-1:TDEST_BASE] = conn.tdest;
   assign axis_conn.data[TUSER_WIDTH+TUSER_BASE-1:TUSER_BASE] = conn.tuser;


endmodule // axis_slave_bfm
