module router_register (
    input clock,
    input resetn,
    input packet_valid,
    input fifo_full,
    input rst_int_reg,
    input detect_add,
    input ld_state,
    input laf_state,
    input lfd_state,
    input full_state,
    input [7:0] data_in,
    output reg parity_done,
    output reg low_packet_valid,
    output reg error,
    output reg [7:0] dout
);
  reg [7:0] header_byte_register;
  reg [7:0] fifo_full_state_register;
  reg [7:0] packet_parity_register;
  reg [7:0] internal_parity_register;
  reg parity_check_pending;

  /////parity_done -> indicates the parity is loaded to the FIFO, so when detect_add is high it means we are loading the first or the header byte , hence parity_done is reset.
  /////low_pkt_valid-> indicates that the register has recieved the parity byte from the source network.
  always @(posedge clock) begin
    if (!resetn) begin
      dout <= 8'b0;
      error <= 1'b0;
      parity_done <= 1'b0;
      low_packet_valid <= 1'b0;
      header_byte_register <= 8'd0;
      fifo_full_state_register <= 8'd0;
      packet_parity_register <= 8'b0;
      internal_parity_register <= 8'b0;

    end
    /////-----We are getting the rst_int_reg from the FSM after the check parity State, so if our parity is recived and loaded to the fifo we reset the low-packet_valid----------///////
    else if (rst_int_reg) begin
      low_packet_valid <= 1'b0;
      error <= 1'b0;
    end else begin
      ///----Header Operations-----//////
      if (packet_valid && detect_add) begin
        header_byte_register <= data_in;
        parity_done <= 1'b0;
        low_packet_valid <= 1'b0;
        internal_parity_register <= data_in;
        fifo_full_state_register <= 8'd0;
      end else if (lfd_state) begin
        dout <= header_byte_register;
      end 
      ///////////////////////////////LD STATES///////////////////////////////////////////////////////////////////
      else if ((ld_state)) begin
        if ((packet_valid) && !(fifo_full)) begin
          dout <= data_in;
          internal_parity_register <= internal_parity_register ^ data_in;
        end else if ((packet_valid) && (fifo_full)) begin
          fifo_full_state_register <= data_in;
        end else if (!(packet_valid) && !(fifo_full)) begin
          dout <= data_in;
          parity_done <= 1'b1;
          low_packet_valid <= 1'b1;
          packet_parity_register <= data_in;
          parity_check_pending <= 1'b1;
        end else if (!(packet_valid) && (fifo_full)) begin
          parity_done <= 1'b0;
          low_packet_valid <= 1'b1;
          packet_parity_register <= data_in;
        end
      end
      ////////////////////////////LAF STATES//////////////////////////////////////////////////////////////////////// 
      else if ((laf_state)) begin
        if ((low_packet_valid) && !(parity_done)) begin
          parity_done <= 1'b1;
          dout <= packet_parity_register;
        end else begin
          internal_parity_register <= internal_parity_register ^ fifo_full_state_register;
          dout <= fifo_full_state_register;
        end
      end 
      ////////////////ERROR CALCULATION//////////////////////////////////////////////////////////////////////////
      else if (parity_check_pending) begin
        error <= (internal_parity_register != packet_parity_register);
        parity_check_pending <= 1'b0;

      end
    end
  end
endmodule

