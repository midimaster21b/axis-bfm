module axis_slave_bfm(conn);
   axis_if conn;

   typedef struct {
      logic [$bits(conn.tdata)-1:0] tdata;
      logic [$bits(conn.tstrb)-1:0] tstrb;
      logic [$bits(conn.tkeep)-1:0] tkeep;
      logic			    tlast;
      logic			    tid;
      logic [$bits(conn.tdest)-1:0] tdest;
      logic [$bits(conn.tuser)-1:0] tuser;
   } axis_beat_t;

   typedef mailbox		    #(axis_beat_t) axis_inbox_t;

   axis_inbox_t axis_inbox = new();

   axis_beat_t empty_beat = '{default: '0};

   /**************************************************************************
    * Read a single valid beat from the bus and insert it into the mailbox.
    **************************************************************************/
   task read_beat;
      axis_beat_t temp;

      begin
	 // Set ready signal
	 conn.tready <= '1;

	 while (conn.tvalid != '1) begin
	    @(posedge conn.aclk);
	 end

	 // Write output beat
	 temp.tdata  <= conn.tdata;
	 temp.tstrb  <= conn.tstrb;
	 temp.tkeep  <= conn.tkeep;
	 temp.tlast  <= conn.tlast;
	 temp.tid    <= conn.tid;
	 temp.tdest  <= conn.tdest;
	 temp.tuser  <= conn.tuser;

	 axis_inbox.put(temp);

	 @(posedge conn.aclk);
	 // Set ready signal
	 conn.tready <= '0;

	 $timeformat(-9, 2, " ns", 20);
	 $display("%t: AXIS Slave - Read Data - '%x'", $time, temp.tdata);

      end
   endtask // read_beat


   /**************************************************************************
    * Get a beat from the mailbox when one is available. [Blocking]
    **************************************************************************/
   task get_beat;
      output logic [$bits(conn.tdata)-1:0] tdata;
      output logic [$bits(conn.tstrb)-1:0] tstrb;
      output logic [$bits(conn.tkeep)-1:0] tkeep;
      output logic			   tlast;
      output logic			   tid;
      output logic [$bits(conn.tdest)-1:0] tdest;
      output logic [$bits(conn.tuser)-1:0] tuser;

      axis_beat_t temp;

      begin
	 axis_inbox.get(temp);

	 // Write output beat
	 tdata  <= temp.tdata;
	 tstrb  <= temp.tstrb;
	 tkeep  <= temp.tkeep;
	 tlast  <= temp.tlast;
	 tid    <= temp.tid;
	 tdest  <= temp.tdest;
	 tuser  <= temp.tuser;
      end
   endtask


   /**************************************************************************
    * Get a simple beat from the mailbox when one is available. [Blocking]
    **************************************************************************/
   task get_simple_beat;
      output logic [$bits(conn.tdata)-1:0] tdata;
      output logic			   tlast;

      axis_beat_t temp;

      begin
	 axis_inbox.get(temp);

	 // Write output beat
	 tdata  <= temp.tdata;
	 tlast  <= temp.tlast;
      end
   endtask


   initial begin
      conn.tready  = '0;
      #1;

      forever begin
	 read_beat();
      end
   end

endmodule // axis_slave_bfm
