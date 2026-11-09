`timescale 1ns / 1ps

module acm_hex8_axi #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 6,
    parameter integer DEFAULT_SCAN_DIV   = 6250,
    parameter integer DEFAULT_SERIAL_DIV = 25,
    parameter integer DEFAULT_BRIGHTNESS = 255,
    parameter         OUTPUT_MODE = "Parallel",
    parameter         USE_BOARD_FLOW = "false",
    parameter         GPIO_BOARD_INTERFACE = "Custom"
) (
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI, PROTOCOL AXI4LITE, DATA_WIDTH 32, ADDR_WIDTH 6, FREQ_HZ 50000000" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWADDR" *) input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWPROT" *) input  wire [2:0] s_axi_awprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWVALID" *) input  wire s_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREADY" *) output wire s_axi_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WDATA" *) input  wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WSTRB" *) input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WVALID" *) input  wire s_axi_wvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WREADY" *) output wire s_axi_wready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BRESP" *) output wire [1:0] s_axi_bresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BVALID" *) output wire s_axi_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BREADY" *) input  wire s_axi_bready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARADDR" *) input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARPROT" *) input  wire [2:0] s_axi_arprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARVALID" *) input  wire s_axi_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARREADY" *) output wire s_axi_arready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RDATA" *) output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RRESP" *) output wire [1:0] s_axi_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RVALID" *) output wire s_axi_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RREADY" *) input  wire s_axi_rready,

    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_CLK, ASSOCIATED_BUSIF S_AXI, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 50000000" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXI_CLK CLK" *) input wire s_axi_aclk,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_RST, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S_AXI_RST RST" *) input wire s_axi_aresetn,

    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_A" *)
    (* X_INTERFACE_MODE = "master PARALLEL" *) output wire parallel_seg_a_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_B" *) output wire parallel_seg_b_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_C" *) output wire parallel_seg_c_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_D" *) output wire parallel_seg_d_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_E" *) output wire parallel_seg_e_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_F" *) output wire parallel_seg_f_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_G" *) output wire parallel_seg_g_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL SEG_DP" *) output wire parallel_seg_dp_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL DIGIT_A" *) output wire parallel_digit_a_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL DIGIT_B" *) output wire parallel_digit_b_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_parallel_rtl:1.0 PARALLEL DIGIT_C" *) output wire parallel_digit_c_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_serial_rtl:1.0 SERIAL DIO" *)
    (* X_INTERFACE_MODE = "master SERIAL" *) output wire serial_dio_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_serial_rtl:1.0 SERIAL SCLK" *) output wire serial_sclk_o,
    (* X_INTERFACE_INFO = "xiaomeige.com:interface:acm_hex8_serial_rtl:1.0 SERIAL RCLK" *) output wire serial_rclk_o
);

    localparam [5:0] REG_CONTROL    = 6'h00;
    localparam [5:0] REG_SCAN_DIV   = 6'h04;
    localparam [5:0] REG_SERIAL_DIV = 6'h08;
    localparam [5:0] REG_BRIGHTNESS = 6'h0c;
    localparam [5:0] REG_SEG03      = 6'h10;
    localparam [5:0] REG_SEG47      = 6'h14;

    reg [31:0] control_reg, scan_div_reg, serial_div_reg, brightness_reg;
    reg [31:0] segment03_reg, segment47_reg;
    reg [C_S_AXI_ADDR_WIDTH-1:0] awaddr_reg;
    reg [C_S_AXI_DATA_WIDTH-1:0] wdata_reg;
    reg [(C_S_AXI_DATA_WIDTH/8)-1:0] wstrb_reg;
    reg aw_pending, w_pending, bvalid_reg;
    reg rvalid_reg;
    reg [31:0] rdata_reg;

    wire write_fire = aw_pending && w_pending && !bvalid_reg;
    assign s_axi_awready = !aw_pending && !bvalid_reg;
    assign s_axi_wready  = !w_pending && !bvalid_reg;
    assign s_axi_bvalid  = bvalid_reg;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_arready = !rvalid_reg;
    assign s_axi_rvalid  = rvalid_reg;
    assign s_axi_rdata   = rdata_reg;
    assign s_axi_rresp   = 2'b00;

    function automatic [31:0] merge_wstrb;
        input [31:0] old_value;
        input [31:0] new_value;
        input [3:0] strobes;
        integer i;
        begin
            merge_wstrb = old_value;
            for (i = 0; i < 4; i = i + 1)
                if (strobes[i]) merge_wstrb[i*8 +: 8] = new_value[i*8 +: 8];
        end
    endfunction

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            aw_pending <= 1'b0;
            w_pending <= 1'b0;
            bvalid_reg <= 1'b0;
            rvalid_reg <= 1'b0;
            control_reg <= 32'h00000001;
            scan_div_reg <= DEFAULT_SCAN_DIV;
            serial_div_reg <= DEFAULT_SERIAL_DIV;
            brightness_reg <= DEFAULT_BRIGHTNESS;
            segment03_reg <= 32'h00000000;
            segment47_reg <= 32'h00000000;
        end else begin
            if (s_axi_awready && s_axi_awvalid) begin awaddr_reg <= s_axi_awaddr; aw_pending <= 1'b1; end
            if (s_axi_wready && s_axi_wvalid) begin wdata_reg <= s_axi_wdata; wstrb_reg <= s_axi_wstrb; w_pending <= 1'b1; end
            if (write_fire) begin
                case (awaddr_reg[5:0])
                    REG_CONTROL:    control_reg    <= merge_wstrb(control_reg, wdata_reg, wstrb_reg);
                    REG_SCAN_DIV:   scan_div_reg   <= merge_wstrb(scan_div_reg, wdata_reg, wstrb_reg);
                    REG_SERIAL_DIV: serial_div_reg <= merge_wstrb(serial_div_reg, wdata_reg, wstrb_reg);
                    REG_BRIGHTNESS: brightness_reg <= merge_wstrb(brightness_reg, wdata_reg, wstrb_reg);
                    REG_SEG03:      segment03_reg  <= merge_wstrb(segment03_reg, wdata_reg, wstrb_reg);
                    REG_SEG47:      segment47_reg  <= merge_wstrb(segment47_reg, wdata_reg, wstrb_reg);
                    default: ;
                endcase
                aw_pending <= 1'b0;
                w_pending <= 1'b0;
                bvalid_reg <= 1'b1;
            end else if (bvalid_reg && s_axi_bready) begin
                bvalid_reg <= 1'b0;
            end

            if (s_axi_arready && s_axi_arvalid) begin
                case (s_axi_araddr[5:0])
                    REG_CONTROL:    rdata_reg <= control_reg;
                    REG_SCAN_DIV:   rdata_reg <= scan_div_reg;
                    REG_SERIAL_DIV: rdata_reg <= serial_div_reg;
                    REG_BRIGHTNESS: rdata_reg <= brightness_reg;
                    REG_SEG03:      rdata_reg <= segment03_reg;
                    REG_SEG47:      rdata_reg <= segment47_reg;
                    default:        rdata_reg <= 32'h00000000;
                endcase
                rvalid_reg <= 1'b1;
            end else if (rvalid_reg && s_axi_rready) begin
                rvalid_reg <= 1'b0;
            end
        end
    end

    reg [31:0] scan_count;
    reg [2:0] scan_digit;
    reg scan_tick;
    reg [7:0] segments_value;
    reg [2:0] digit_select_value;
    reg [7:0] pwm_counter;
    wire [7:0] current_segment =
        (scan_digit == 3'd0) ? segment03_reg[7:0]   :
        (scan_digit == 3'd1) ? segment03_reg[15:8]  :
        (scan_digit == 3'd2) ? segment03_reg[23:16] :
        (scan_digit == 3'd3) ? segment03_reg[31:24] :
        (scan_digit == 3'd4) ? segment47_reg[7:0]   :
        (scan_digit == 3'd5) ? segment47_reg[15:8]  :
        (scan_digit == 3'd6) ? segment47_reg[23:16] : segment47_reg[31:24];
    // On the PCB HEX_SEL7 is the leftmost digit and HEX_SEL0 is the
    // rightmost digit.  Keep the software model intuitive: logical digit 0
    // is leftmost, so reverse only the physical digit-select index.
    wire [2:0] physical_digit_index = 3'd7 - scan_digit;

    wire [7:0] effective_brightness = brightness_reg[7:0];
    wire parallel_digit_visible = control_reg[0] && (current_segment != 8'h00) &&
        ((effective_brightness == 8'hff) || (pwm_counter < effective_brightness));

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            scan_count <= 0;
            scan_digit <= 0;
            scan_tick <= 0;
            segments_value <= 0;
            digit_select_value <= 0;
            pwm_counter <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1'b1;
            scan_tick <= 1'b0;
            if (scan_count >= ((scan_div_reg < 2) ? 1 : scan_div_reg - 1)) begin
                scan_count <= 0;
                scan_digit <= scan_digit + 1'b1;
                scan_tick <= 1'b1;
            end else begin
                scan_count <= scan_count + 1'b1;
            end
            if (parallel_digit_visible) begin
                segments_value <= current_segment;
                digit_select_value <= physical_digit_index;
            end else begin
                segments_value <= 8'h00;
                digit_select_value <= physical_digit_index;
            end
        end
    end

    reg [15:0] serial_shift;
    reg [4:0] serial_bits;
    reg [31:0] serial_count;
    reg serial_busy, serial_clk, serial_latch, serial_data;
    reg [7:0] serial_pwm_accum [0:7];
    integer serial_digit_index;
    // ACM-HEX8 uses common-anode digits.  The selected digit is active high,
    // while segment A..G/DP are active low (see the 74HC238/74HC244 and
    // 74HC595 paths in the module schematic).  Software-facing segment bytes
    // remain conventional active-high seven-segment patterns; invert only at
    // the physical pins.
    wire [7:0] physical_segments_n = ~segments_value;
    wire [7:0] current_segment_n = ~current_segment;
    wire [7:0] digit_onehot = control_reg[0] ? (8'b1 << physical_digit_index) : 8'h00;
    wire [8:0] serial_pwm_sum = {1'b0, serial_pwm_accum[scan_digit]} +
        {1'b0, effective_brightness};
    wire serial_digit_visible = control_reg[0] && (current_segment != 8'h00) &&
        ((effective_brightness == 8'hff) || serial_pwm_sum[8]);
    assign {parallel_digit_c_o, parallel_digit_b_o, parallel_digit_a_o,
            parallel_seg_dp_o, parallel_seg_g_o, parallel_seg_f_o, parallel_seg_e_o,
            parallel_seg_d_o, parallel_seg_c_o, parallel_seg_b_o, parallel_seg_a_o} =
           {digit_select_value, physical_segments_n};
    assign {serial_rclk_o, serial_sclk_o, serial_dio_o} =
           {serial_latch, serial_clk, serial_data};
    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            serial_shift <= 16'hff00;
            serial_bits <= 0;
            serial_count <= 0;
            serial_busy <= 0;
            serial_clk <= 0;
            serial_latch <= 0;
            serial_data <= 0;
            for (serial_digit_index = 0; serial_digit_index < 8;
                 serial_digit_index = serial_digit_index + 1)
                serial_pwm_accum[serial_digit_index] <= 0;
        end else begin
            serial_latch <= 1'b0;
            if (scan_tick && !serial_busy) begin
                if (effective_brightness == 8'hff)
                    serial_pwm_accum[scan_digit] <= 0;
                else
                    serial_pwm_accum[scan_digit] <= serial_pwm_sum[7:0];
                serial_shift <= serial_digit_visible
                    ? {current_segment_n, digit_onehot} : 16'hff00;
                serial_bits <= 5'd16;
                serial_count <= 0;
                serial_busy <= 1'b1;
                serial_clk <= 1'b0;
                serial_data <= serial_digit_visible ? current_segment_n[7] : 1'b1;
            end else if (serial_busy) begin
                if (serial_count >= ((serial_div_reg < 2) ? 1 : serial_div_reg - 1)) begin
                    serial_count <= 0;
                    if (!serial_clk) begin
                        serial_clk <= 1'b1;
                    end else begin
                        serial_clk <= 1'b0;
                        if (serial_bits == 1) begin
                            serial_bits <= 0;
                            serial_busy <= 1'b0;
                            serial_latch <= 1'b1;
                        end else begin
                            serial_bits <= serial_bits - 1'b1;
                            serial_shift <= {serial_shift[14:0], 1'b0};
                            serial_data <= serial_shift[14];
                        end
                    end
                end else begin
                    serial_count <= serial_count + 1'b1;
                end
            end
        end
    end

    wire _unused = &{1'b0, s_axi_awprot, s_axi_arprot};
endmodule
