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
   } axis_beat;

   axis_beat empty_beat = '{default: '0};
   axis_beat not_empty_beat = '{
				tvalid: '1,
				// tdata: 32'hABCD,
				tdata: 8'hAA,
				tstrb: '1,
				tkeep: '1,
				tlast: '1,
				tid: '0,
				tdest: '0,
				tuser: '0
				};

   task write_beat;
      input axis_beat temp;

      begin
	 // Wait for device ready
	 while (conn.tready != '1) begin
	    @(posedge conn.aclk);
	 end

	 // Write output beat
	 conn.tvalid <= temp.tvalid;
	 conn.tdata  <= temp.tdata;
	 conn.tstrb  <= temp.tstrb;
	 conn.tkeep  <= temp.tkeep;
	 conn.tlast  <= temp.tlast;
	 conn.tid    <= temp.tid;
	 conn.tdest  <= temp.tdest;
	 conn.tuser  <= temp.tuser;

	 @(posedge conn.aclk);
      end
   endtask // write_beat


   initial begin
      conn.tvalid = '0;
      conn.tdata  = '0;
      conn.tstrb  = '0;
      conn.tkeep  = '0;
      conn.tlast  = '0;
      conn.tid    = '0;
      conn.tdest  = '0;
      conn.tuser  = '0;

      #1;

      write_beat(empty_beat);
      write_beat(not_empty_beat);

   end

endmodule // axis_master_bfm
