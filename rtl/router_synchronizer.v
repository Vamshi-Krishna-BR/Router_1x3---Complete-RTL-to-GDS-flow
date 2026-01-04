module router_synchronizer (
    input clock,
    input resetn,
    input detect_add,
    input [1:0] data_in,
    input write_enb_reg,
    input [2:0] read_en,
    input empty_0,
    input empty_1,
    input empty_2,
    input full_0,
    input full_1,
    input full_2,
    output reg [2:0] write_enb,
    output reg [2:0] soft_reset,
    output reg fifo_full,
    output reg [2:0] vld_out
);
  integer i;
  parameter MAX_TIME = 30;
  reg [1:0] temp_reg;
  reg [4:0] counter  [2:0];
  always @(posedge clock) begin
    if (!resetn) begin
      temp_reg <= 2'd0;
      for (i = 0; i < 3; i = i + 1) counter[i] <= 5'd1;
      soft_reset <= 3'd0;
    end else begin
      if (detect_add)
        temp_reg <= data_in;///keep the output port address, detect_add is sent from the fsm, only if detect_add is high we capture the data_in->meaning we obtain the output port.
      if (write_enb_reg) begin  //control signal from FSM //generating write_enable only if write_enb_reg is high
        case (temp_reg)
          2'd0: write_enb <= 3'b001;
          2'd1: write_enb <= 3'b010;
          2'd2: write_enb <= 3'b100;
          default: write_enb <= 3'b000;
        endcase
      end else begin
        write_enb <= 3'b000;
      end
      vld_out[0] <= ~empty_0;
      vld_out[1] <= ~empty_1;
      vld_out[2] <= ~empty_2;
      for (i = 0; i < 3; i = i + 1) begin
        if (vld_out[i]) begin
          if (read_en[i]) begin
            counter[i] <= 5'd1;
            soft_reset[i] <= 1'b0;
          end else if (counter[i] != MAX_TIME) begin
            soft_reset[i] <= 1'b0;
            counter[i] <= counter[i] + 5'd1;
          end else begin
            counter[i] <= 5'd1;
            soft_reset[i] <= 1'b1;
          end
        end else begin
          counter[i] <= counter[i] + 5'd1;
          soft_reset[i] <= 1'b0;
        end
      end
    end
    case (temp_reg)
      2'd0: fifo_full <= full_0;  //these fifo_full signals are sent to the registers and the fsm 
      2'd1: fifo_full <= full_1;
      2'd2: fifo_full <= full_2;
      default: fifo_full <= 1'b0;
    endcase
  end
endmodule

