module axis_slave_bfm(conn);
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
   } axis_beat;

   axis_beat empty_beat = '{default: '0};

   task read_beat;
      output axis_beat temp;

      begin

	 // Set ready signal
	 conn.tready <= '1;

	 while (conn.tvalid != '1) begin
	    @(posedge conn.aclk);
	 end

	 // Write output beat
	 temp.tvalid <= conn.tvalid;
	 temp.tdata  <= conn.tdata;
	 temp.tstrb  <= conn.tstrb;
	 temp.tkeep  <= conn.tkeep;
	 temp.tlast  <= conn.tlast;
	 temp.tid    <= conn.tid;
	 temp.tdest  <= conn.tdest;
	 temp.tuser  <= conn.tuser;

	 @(posedge conn.aclk);
	 // Set ready signal
	 conn.tready <= '0;

	 $timeformat(-9, 2, " ns", 20);
	 $display("%t: AXIS Slave - Read Data - '%x'", $time, temp.tdata);

      end
   endtask // write_beat


   initial begin
      conn.tready  = '0;
      #1;
      read_beat(empty_beat);

   end

endmodule // axis_slave_bfm
