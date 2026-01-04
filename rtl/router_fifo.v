module router_fifo (
    input clock,
    input resetn,
    input write_en,
    input read_en,
    input soft_reset,
    input [7:0] data_in,
    input lfd_state,
    output reg empty,
    output reg full,
    output reg [7:0] data_out
);
  integer i;
  reg [6:0] count;
  reg [8:0] fifo_memory[0:15];
  reg [4:0] write_ptr, read_ptr;
  reg fifo_full, fifo_empty;
  reg delay_lfd_state;
  always @(*) begin
    fifo_empty = (write_ptr[4:0] == read_ptr[4:0]);
    fifo_full  = (write_ptr[4] != read_ptr[4] && write_ptr[3:0] == read_ptr[3:0]);
  end
  always @(posedge clock) begin
    if (!resetn) delay_lfd_state <= 1'b0;
    else delay_lfd_state <= lfd_state;
  end
  always @(posedge clock) begin
    if (!resetn) begin
      for (i = 0; i < 16; i = i + 1) fifo_memory[i] <= 9'd0;
      count <= 7'd0;
      data_out <= 8'd0;
      empty <= 1'b1;
      full <= 1'b0;
      read_ptr <= 5'd0;
      write_ptr <= 5'd0;
    end else if (soft_reset) begin
      for (i = 0; i < 16; i = i + 1) fifo_memory[i] <= 9'd0;
      data_out <= 8'bz;
      count <= 7'd0;
      write_ptr <= 5'd0;
      read_ptr <= 5'd0;
      empty <= 1'b1;
      full <= 1'b0;
    end else begin
      if ((write_en) && !(fifo_full)) begin
        fifo_memory[write_ptr] <= {delay_lfd_state, data_in};
        write_ptr <= write_ptr + 5'd1;
      end
      if ((read_en) && !(fifo_empty)) begin
        if (fifo_memory[read_ptr][8]) begin
          ///if LFD is high
          data_out <= fifo_memory[read_ptr][7:0];
          //check the length of the payload here [7:2] ->down count for counter(length+1) if payload length is 4 then read 4+1(pb) , 5 locations
          count <= fifo_memory[read_ptr][7:2] + 7'd1;
          read_ptr <= read_ptr + 5'd1;
        end else begin
          //if MSB is low then this flow
          if (count > 0) begin
            data_out <= fifo_memory[read_ptr][7:0];
            count <= count - 7'd1;
            read_ptr <= read_ptr + 5'd1;
          end else begin
            data_out <= 8'b0;
          end
        end
      end
    end
    empty <= fifo_empty;
    full  <= fifo_full;
  end
endmodule

