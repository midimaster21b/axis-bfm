module axis_master_bfm(conn);
   axis_if conn;

   typedef struct {
      logic tvalid;
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
   axis_beat_t temp_beat;

   /**************************************************************************
    * Writes a beat to the AXIS BFM output lines
    **************************************************************************/
   task write_beat;
      input axis_beat_t temp;

      begin
	 // Write output beat
	 conn.tvalid <= temp.tvalid;
	 conn.tdata  <= temp.tdata;
	 conn.tstrb  <= temp.tstrb;
	 conn.tkeep  <= temp.tkeep;
	 conn.tlast  <= temp.tlast;
	 conn.tid    <= temp.tid;
	 conn.tdest  <= temp.tdest;
	 conn.tuser  <= temp.tuser;

      end
   endtask // write_beat


   /**************************************************************************
    * Add a beat to the queue of AXIS beats to be written
    **************************************************************************/
   task put_beat;
      input logic tvalid;
      input logic [$bits(conn.tdata)-1:0] tdata;
      input logic [$bits(conn.tstrb)-1:0] tstrb;
      input logic [$bits(conn.tkeep)-1:0] tkeep;
      input logic			  tlast;
      input logic			  tid;
      input logic [$bits(conn.tdest)-1:0] tdest;
      input logic [$bits(conn.tuser)-1:0] tuser;

      axis_beat_t temp;

      begin
	 temp.tvalid = tvalid;
	 temp.tdata  = tdata;
	 temp.tstrb  = tstrb;
	 temp.tkeep  = tkeep;
	 temp.tlast  = tlast;
	 temp.tid    = tid;
	 temp.tdest  = tdest;
	 temp.tuser  = tuser;

	 // Add output beat to mailbox
	 axis_inbox.put(temp);

      end
   endtask // put_beat


   /**************************************************************************
    * Add a basic beat to the queue of AXIS beats to be written. A basic beat
    * only requires data and last to be specified.
    **************************************************************************/
   task put_simple_beat;
      input logic [$bits(conn.tdata)-1:0] tdata;
      input logic			  tlast;

      begin
	 put_beat(.tvalid('1),
		  .tdata(tdata),
		  .tstrb('1),
		  .tkeep('1),
		  .tlast(tlast),
		  .tid('0),
		  .tdest('0),
		  .tuser('0));
      end
   endtask // put_simple_beat


   /**************************************************************************
    * Add a simple beat with a tuser value to the queue of AXIS beats to be
    * written.
    **************************************************************************/
   task put_user_beat;
      input logic [$bits(conn.tdata)-1:0] tdata;
      input logic			  tlast;
      input logic [$bits(conn.tuser)-1:0] tuser;

      begin
	 put_beat(.tvalid('1),
		  .tdata(tdata),
		  .tstrb('1),
		  .tkeep('1),
		  .tlast(tlast),
		  .tid('0),
		  .tdest('0),
		  .tuser(tuser));
      end
   endtask // put_user_beat


   initial begin
      $timeformat(-9, 2, " ns", 20);

      conn.tvalid = '0;
      conn.tdata  = '0;
      conn.tstrb  = '0;
      conn.tkeep  = '0;
      conn.tlast  = '0;
      conn.tid    = '0;
      conn.tdest  = '0;
      conn.tuser  = '0;

      #1;

      forever begin
	 if(axis_inbox.try_get(temp_beat) != 0) begin
	    write_beat(temp_beat);

	    $display("%t: AXIS Master - Write Data - '%x'", $time, temp_beat.tdata);

	    @(negedge conn.aclk)
	    if(conn.tready == '0) begin
	       wait(conn.tready == '1);
	    end

	    // Wait for device ready
	    @(posedge conn.aclk && conn.tready == '1);

	 end else begin
	    write_beat(empty_beat);

	    // Wait for the next clock cycle
	    @(posedge conn.aclk);

	 end
      end
   end

endmodule // axis_master_bfm
