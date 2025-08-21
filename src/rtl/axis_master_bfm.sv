module axis_master_bfm #(parameter
			 BFM_NAME="m_axis"
			 ) (conn);
   axis_if conn;

   // NOTE: This needs to be consistent with the offset ordering in the
   // interface assignments in the bottom section.
   typedef struct packed {
      logic [conn.NUM_DATA_BITS-1:0] tdata;
      logic [conn.NUM_STRB_BITS-1:0] tstrb;
      logic [conn.NUM_KEEP_BITS-1:0] tkeep;
      logic                          tlast;
      logic [conn.NUM_ID_BITS-1:0  ] tid;
      logic [conn.NUM_DEST_BITS-1:0] tdest;
      logic [conn.NUM_USER_BITS-1:0] tuser;
   } axis_beat_t;

   typedef mailbox		    #(axis_beat_t) axis_inbox_t;

   axis_inbox_t axis_inbox  = new();
   // axis_inbox_t axis_expect = new();

   /**************************************************************************
    * Add a beat to the queue of AXIS beats to be written
    **************************************************************************/
   task write (
		input logic [conn.NUM_DATA_BITS-1:0] tdata = 0,
		input logic [conn.NUM_STRB_BITS-1:0] tstrb = 0,
		input logic [conn.NUM_KEEP_BITS-1:0] tkeep = 0,
		input logic                          tlast = 0,
		input logic [conn.NUM_ID_BITS-1:0  ] tid = 0,
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
	 $display("%t: %s - Write Data - Data: %X, Keep: %x, Last: %x, User: %x", $time, BFM_NAME, temp.tdata, temp.tkeep, temp.tlast, temp.tuser);
	 $display("%t: %s - Write Data - Data: %X", $time, BFM_NAME, temp);
	 m_axis.put_simple_beat(temp);

      end
   endtask // write


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
   handshake_if     #(.DATA_BITS(HS_BUS_WIDTH)) axis_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_master #(.IFACE_NAME(BFM_NAME), .VERBOSE("FALSE")) m_axis (axis_conn);

   assign conn.tvalid     = axis_conn.valid;
   assign axis_conn.ready = conn.tready;
   assign conn.tdata      = axis_conn.data[TDATA_WIDTH+TDATA_BASE-1:TDATA_BASE];
   assign conn.tstrb      = axis_conn.data[TSTRB_WIDTH+TSTRB_BASE-1:TSTRB_BASE];
   assign conn.tkeep      = axis_conn.data[TKEEP_WIDTH+TKEEP_BASE-1:TKEEP_BASE];
   assign conn.tlast      = axis_conn.data[TLAST_WIDTH+TLAST_BASE-1:TLAST_BASE];
   assign conn.tid        = axis_conn.data[TID_WIDTH  +TID_BASE  -1:TID_BASE  ];
   assign conn.tdest      = axis_conn.data[TDEST_WIDTH+TDEST_BASE-1:TDEST_BASE];
   assign conn.tuser      = axis_conn.data[TUSER_WIDTH+TUSER_BASE-1:TUSER_BASE];

endmodule // axis_master_bfm
