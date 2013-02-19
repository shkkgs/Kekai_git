///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: nf2_core.v 5145 2009-03-03 01:47:05Z grg $
//
// Module: nf2_core.v
// Project: NetFPGA
// Description: Core module for a NetFPGA design.
//                
// This is instantiated within the nf2_top module. 
// This should contain internal logic only - not I/O buffers or pads.
//
///////////////////////////////////////////////////////////////////////////////
`include "NF_2.1_defines.v"
`include "reg_defines_reference_router.v"
`include "registers.v"
module nf2_core #(
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
	
		// JTAG Interface
		
		input  wire [26:0]  control_port_address,   
		input  wire         control_port_read,       
		output wire [31:0]  control_port_readdata,    
		input  wire         control_port_write,      
		input  wire [31:0]  control_port_writedata,  
		output wire         control_port_waitrequest, 
	
		output 		[7:0] gmac_tx_data_1_out,
		output 		gmac_tx_dvld_1_out,
		input 		gmac_tx_ack_1_out,
		output      end_of_packet_1_out,
		output      start_of_packet_1_out,
		  
		input 		[7:0] gmac_rx_data_1_in,
		input 		gmac_rx_dvld_1_in,
		input 		gmac_rx_frame_error_1_in, 
		
		output 		[7:0] gmac_tx_data_2_out,
		output 		gmac_tx_dvld_2_out,
		input 		gmac_tx_ack_2_out,
		output      end_of_packet_2_out,
		output      start_of_packet_2_out,
		  
		input 		[7:0] gmac_rx_data_2_in,
		input 		gmac_rx_dvld_2_in,
		input 		gmac_rx_frame_error_2_in, 
		
		output 		[7:0] gmac_tx_data_3_out,
		output 		gmac_tx_dvld_3_out,
		input 		gmac_tx_ack_3_out,
		output      end_of_packet_3_out,
		output      start_of_packet_3_out,
		  
		input 		[7:0] gmac_rx_data_3_in,
		input 		gmac_rx_dvld_3_in,
		input 		gmac_rx_frame_error_3_in, 
		
		output 		[7:0] gmac_tx_data_0_out,
		output 		gmac_tx_dvld_0_out,
		input 		gmac_tx_ack_0_out,
		output      end_of_packet_0_out,
		output      start_of_packet_0_out,
		  
		input 		[7:0] gmac_rx_data_0_in,
		input 		gmac_rx_dvld_0_in,
		input 		gmac_rx_frame_error_0_in, 

    //  input        tx_rgmii_clk_int,
   //   input        rx_rgmii_0_clk_int,
    //  input        rx_rgmii_1_clk_int,
    //  input        rx_rgmii_2_clk_int,
    //  input        rx_rgmii_3_clk_int,

      // core clock
      input        core_clk_int,
		input 		 statemac_clk,
      // misc
      input        reset
		//output wire ready_out

   );


	
	
   //------------- local parameters --------------
   localparam DATA_WIDTH = 64;
   localparam CTRL_WIDTH = DATA_WIDTH/8;
   localparam NUM_QUEUES = 8;
   localparam PKT_LEN_CNT_WIDTH = 11;
   //---------------- Wires/regs ------------------

   // FIXME
   assign        nf2_err = 1'b 0;

   // Do NOT disable resets
   assign disable_reset = 1'b0;
      
   wire [NUM_QUEUES-1:0]              out_wr;
   wire [NUM_QUEUES-1:0]              out_rdy;
   wire [DATA_WIDTH-1:0]              out_data [NUM_QUEUES-1:0];
   wire [CTRL_WIDTH-1:0]              out_ctrl [NUM_QUEUES-1:0];
   
   wire [NUM_QUEUES-1:0]              in_wr;
   wire [NUM_QUEUES-1:0]              in_rdy;
   wire [DATA_WIDTH-1:0]              in_data [NUM_QUEUES-1:0];
   wire [CTRL_WIDTH-1:0]              in_ctrl [NUM_QUEUES-1:0];

   wire                               wr_0_req;
   wire [`SRAM_ADDR_WIDTH-1:0]        wr_0_addr;
   wire [DATA_WIDTH+CTRL_WIDTH-1:0]   wr_0_data;
   wire                               wr_0_ack;
   
   wire                               rd_0_req;
   wire [`SRAM_ADDR_WIDTH-1:0]        rd_0_addr;
   wire [DATA_WIDTH+CTRL_WIDTH-1:0]   rd_0_data;
   wire                               rd_0_vld;
   wire                               rd_0_ack;
   
   wire [`SRAM_ADDR_WIDTH-1:0]        sram_addr;

   wire [`CPCI_NF2_ADDR_WIDTH-1:0]    cpci_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]    cpci_reg_rd_data;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]    cpci_reg_wr_data;

   wire                                core_reg_req;
   wire                                core_reg_rd_wr_L;
   wire                                core_reg_ack;
   wire [`CORE_REG_ADDR_WIDTH-1:0]     core_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     core_reg_wr_data;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     core_reg_rd_data;
   
   wire [3:0]                          core_4mb_reg_req;
   wire [3:0]                          core_4mb_reg_rd_wr_L;
   wire [3:0]                          core_4mb_reg_ack;
   wire [4 * `BLOCK_SIZE_1M_REG_ADDR_WIDTH-1:0] core_4mb_reg_addr;
   wire [4 * `CPCI_NF2_DATA_WIDTH-1:0] core_4mb_reg_wr_data;
   wire [4 * `CPCI_NF2_DATA_WIDTH-1:0] core_4mb_reg_rd_data;
   
   wire [15:0]                         core_256kb_0_reg_req;
   wire [15:0]                         core_256kb_0_reg_rd_wr_L;
   wire [15:0]                         core_256kb_0_reg_ack;
   wire [16 * `BLOCK_SIZE_64k_REG_ADDR_WIDTH-1:0] core_256kb_0_reg_addr;
   wire [16 * `CPCI_NF2_DATA_WIDTH-1:0] core_256kb_0_reg_wr_data;
   wire [16 * `CPCI_NF2_DATA_WIDTH-1:0] core_256kb_0_reg_rd_data;

   wire                                sram_reg_req;
   wire                                sram_reg_rd_wr_L;
   wire                                sram_reg_ack;
   wire [`SRAM_REG_ADDR_WIDTH-1:0]     sram_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     sram_reg_wr_data; 
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     sram_reg_rd_data;
   
   wire                                udp_reg_req;
   wire                                udp_reg_rd_wr_L;
   wire                                udp_reg_ack;
   wire [`UDP_REG_ADDR_WIDTH-1:0]      udp_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     udp_reg_wr_data;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     udp_reg_rd_data;
   
   wire                                dram_reg_req;
   wire                                dram_reg_rd_wr_L;
   wire                                dram_reg_ack;
   wire [`DRAM_REG_ADDR_WIDTH-1:0]     dram_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     dram_reg_wr_data; 
   wire [`CPCI_NF2_DATA_WIDTH-1:0]     dram_reg_rd_data;
   
   wire [7:0] gmii_txd_int[(NUM_QUEUES / 2) - 1:0];
   wire       gmii_tx_en_int[(NUM_QUEUES / 2) - 1:0];
   wire       gmii_tx_er_int[(NUM_QUEUES / 2) - 1:0];
   wire       gmii_crs_int[(NUM_QUEUES / 2) - 1:0];
   wire       gmii_col_int[(NUM_QUEUES / 2) - 1:0];
   wire [7:0] gmii_rxd_reg[(NUM_QUEUES / 2) - 1:0];
   wire       gmii_rx_dv_reg[(NUM_QUEUES / 2) - 1:0];
   wire       gmii_rx_er_reg[(NUM_QUEUES / 2) - 1:0];
   wire       eth_link_status[(NUM_QUEUES / 2) - 1:0];
   wire [1:0] eth_clock_speed[(NUM_QUEUES / 2) - 1:0];
   wire       eth_duplex_status[(NUM_QUEUES / 2) - 1:0];
   wire       rx_rgmii_clk_int[(NUM_QUEUES / 2) - 1:0];

   wire [`MAC_GRP_REG_ADDR_WIDTH-1:0] mac_grp_reg_addr[3:0];
   wire [3:0]                         mac_grp_reg_req;
   wire [3:0]                         mac_grp_reg_rd_wr_L;
   wire [3:0]                         mac_grp_reg_ack;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]    mac_grp_reg_wr_data[3:0];
   wire [`CPCI_NF2_DATA_WIDTH-1:0]    mac_grp_reg_rd_data[3:0];

   wire [`CPU_QUEUE_REG_ADDR_WIDTH-1:0] cpu_queue_reg_addr[3:0];
   wire [3:0]                         cpu_queue_reg_req;
   wire [3:0]                         cpu_queue_reg_rd_wr_L;
   wire [3:0]                         cpu_queue_reg_ack;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]    cpu_queue_reg_wr_data[3:0];
   wire [`CPCI_NF2_DATA_WIDTH-1:0]    cpu_queue_reg_rd_data[3:0];

   wire [3:0]                         cpu_q_dma_pkt_avail;
   wire [3:0]                         cpu_q_dma_rd;
   wire [`DMA_DATA_WIDTH-1:0]         cpu_q_dma_rd_data [3:0];
   wire [`DMA_CTRL_WIDTH-1:0]         cpu_q_dma_rd_ctrl[3:0];
   
   wire [3:0]                         cpu_q_dma_nearly_full;
   wire [3:0]                         cpu_q_dma_wr;
   wire [`DMA_DATA_WIDTH-1:0]         cpu_q_dma_wr_data[3:0];
   wire [`DMA_CTRL_WIDTH-1:0]         cpu_q_dma_wr_ctrl[3:0];
	
	wire [7:0] 									gmac_tx_data_out[(NUM_QUEUES / 2) - 1:0];
	wire 											gmac_tx_dvld_out[(NUM_QUEUES / 2) - 1:0];
	wire 											gmac_tx_ack_out[(NUM_QUEUES / 2) - 1:0];
	wire [7:0] 									gmac_rx_data_in[(NUM_QUEUES / 2) - 1:0];
	wire 											gmac_rx_dvld_in[(NUM_QUEUES / 2) - 1:0];
	wire 											gmac_rx_frame_error_in[(NUM_QUEUES / 2) - 1:0];
	wire                                end_of_packet[(NUM_QUEUES / 2) - 1:0];
	wire                                start_of_packet[(NUM_QUEUES / 2) - 1:0];
	wire 											tx_rgmii_clk_int;
	
	wire out_ack;
	wire jtag_rd_wr_L;
	reg jtag_rd_wr_L_reg;
	//reg control_port_waitrequest_reg;
	reg [31:0] control_port_readdata_reg;
	reg jtag_req_reg;

   //---------------------------------------------
   //
   // MAC rx and tx queues
   //
   //---------------------------------------------

   // Note: uses register block 8-11
   generate
      genvar i;
      for(i=0; i<NUM_QUEUES/2; i=i+1) begin: mac_groups
         nf2_mac_grp #(
            .DATA_WIDTH(DATA_WIDTH), 
            .ENABLE_HEADER(1),
            .PORT_NUMBER(2 * i),
            .STAGE_NUMBER(`IO_QUEUE_STAGE_NUM)
         )
         nf2_mac_grp
           (// register interface
            .mac_grp_reg_req        (core_256kb_0_reg_req[`WORD(`MAC_GRP_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_ack        (core_256kb_0_reg_ack[`WORD(`MAC_GRP_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_rd_wr_L    (core_256kb_0_reg_rd_wr_L[`WORD(`MAC_GRP_0_BLOCK_ADDR + i,1)]),

            .mac_grp_reg_addr       (core_256kb_0_reg_addr[`WORD(`MAC_GRP_0_BLOCK_ADDR + i,
                                     `BLOCK_SIZE_64k_REG_ADDR_WIDTH)]),

            .mac_grp_reg_rd_data    (core_256kb_0_reg_rd_data[`WORD(`MAC_GRP_0_BLOCK_ADDR + i,
                                     `CPCI_NF2_DATA_WIDTH)]),
            .mac_grp_reg_wr_data    (core_256kb_0_reg_wr_data[`WORD(`MAC_GRP_0_BLOCK_ADDR + i,
                                     `CPCI_NF2_DATA_WIDTH)]),
            // output to data path interface
            .out_wr                 (in_wr[i*2]),
            .out_rdy                (in_rdy[i*2]),
            .out_data               (in_data[i*2]),
            .out_ctrl               (in_ctrl[i*2]),
            // input from data path interface
            .in_wr                  (out_wr[i*2]),
            .in_rdy                 (out_rdy[i*2]),
            .in_data                (out_data[i*2]),
            .in_ctrl                (out_ctrl[i*2]),
            // pins
//            .gmii_tx_d              (gmii_txd_int[i]),
//            .gmii_tx_en             (gmii_tx_en_int[i]),
//            .gmii_tx_er             (gmii_tx_er_int[i]),
//            .gmii_crs               (gmii_crs_int[i]),
//            .gmii_col               (gmii_col_int[i]),
//            .gmii_rx_d              (gmii_rxd_reg[i]),
//            .gmii_rx_dv             (gmii_rx_dv_reg[i]),
//            .gmii_rx_er             (gmii_rx_er_reg[i]),
		
				.gmac_tx_data_out(gmac_tx_data_out[i]),
				.gmac_tx_dvld_out(gmac_tx_dvld_out[i]),
				.gmac_tx_ack_out(gmac_tx_ack_out[i]),
				.end_of_packet(end_of_packet[i]),
		      .start_of_packet(start_of_packet[i]),
		  
				.gmac_rx_data_in(gmac_rx_data_in[i]),
				.gmac_rx_dvld_in(gmac_rx_dvld_in[i]),
				.gmac_rx_frame_error_in(gmac_rx_frame_error_in[i]),
				
            // misc
            .txgmiimiiclk           (tx_rgmii_clk_int),
            .rxgmiimiiclk           (rx_rgmii_clk_int[i]),
            .clk                    (core_clk_int),
            .reset                  (reset)
            );
      end // block: mac_groups
      
   endgenerate


//   //---------------------------------------------
//   //
//   // CPU Queues
//   //
//   //---------------------------------------------
//
//   //
//   // Note: uses register block 12-15
//   generate
//
//      genvar k;
//
//      for(k=0; k<NUM_QUEUES/2; k=k+1) begin: cpu_queues
//
//         // TEMPORARY CODE TO ADD/REMOVE LENGTH/SRC HEADERS
//         //
//         // REMOVE THIS CODE WHEN THE CPU QUEUES HAVE BEEN UPDATED!
//         wire [DATA_WIDTH - 1:0] rx_data;
//         wire [CTRL_WIDTH - 1:0] rx_ctrl;
//         wire                    rx_wr;
//         wire                    rx_rdy;
//
//         wire [DATA_WIDTH - 1:0] tx_data;
//         wire [CTRL_WIDTH - 1:0] tx_ctrl;
//         wire                    tx_wr;
//         wire                    tx_rdy;
//
//
//         // CPU DMA QUEUE 
//         cpu_dma_queue
//         #(.DATA_WIDTH(DATA_WIDTH),
//           .CTRL_WIDTH(CTRL_WIDTH)
//           ) cpu_dma_queue_i
//
//           (
///********************************
//            .out_data               (in_data[2*k+1]),
//            .out_ctrl               (in_ctrl[2*k+1]),
//            .out_wr                 (in_wr[2*k+1]),
//            .out_rdy                (in_rdy[2*k+1]),
//
//            .in_data                (out_data[2*k+1]),
//            .in_ctrl                (out_ctrl[2*k+1]),
//            .in_wr                  (out_wr[2*k+1]),
//            .in_rdy                 (out_rdy[2*k+1]),
//********************************/
//            .out_data               (rx_data),
//            .out_ctrl               (rx_ctrl),
//            .out_wr                 (rx_wr),
//            .out_rdy                (rx_rdy),
//
//            .in_data                (tx_data),
//            .in_ctrl                (tx_ctrl),
//            .in_wr                  (tx_wr),
//            .in_rdy                 (tx_rdy),
//
//            // --- DMA rd rxfifo interface
//            .cpu_q_dma_pkt_avail    (cpu_q_dma_pkt_avail[k]),
//            
//            .cpu_q_dma_rd           (cpu_q_dma_rd[k]),
//            .cpu_q_dma_rd_data      (cpu_q_dma_rd_data[k]),
//            .cpu_q_dma_rd_ctrl      (cpu_q_dma_rd_ctrl[k]),
//            
//            // DMA wr txfifo interface
//            .cpu_q_dma_nearly_full  (cpu_q_dma_nearly_full[k]),
//            
//            .cpu_q_dma_wr           (cpu_q_dma_wr[k]),
//            .cpu_q_dma_wr_data      (cpu_q_dma_wr_data[k]), 
//            .cpu_q_dma_wr_ctrl      (cpu_q_dma_wr_ctrl[k]),
//            
//            .reg_req                (core_256kb_0_reg_req[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + k,1)]),
//            .reg_ack                (core_256kb_0_reg_ack[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + k,1)]),
//            .reg_rd_wr_L            (core_256kb_0_reg_rd_wr_L[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + k,1)]),
//            .reg_addr               (core_256kb_0_reg_addr[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + k,
//                                     `BLOCK_SIZE_64k_REG_ADDR_WIDTH)]),
//            .reg_rd_data            (core_256kb_0_reg_rd_data[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + k,
//                                     `CPCI_NF2_DATA_WIDTH)]),
//            .reg_wr_data            (core_256kb_0_reg_wr_data[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + k,
//                                     `CPCI_NF2_DATA_WIDTH)]),
//            // --- Misc
//            .reset                  (reset),
//            .clk                    (core_clk_int)
//            );
//
//         add_rm_hdr #(
//            .DATA_WIDTH(DATA_WIDTH), 
//            .PORT_NUMBER(2 * k + 1),
//            .STAGE_NUMBER(`IO_QUEUE_STAGE_NUM)
//         ) add_rm_hdr (
//            .rx_in_data                (rx_data),
//            .rx_in_ctrl                (rx_ctrl),
//            .rx_in_wr                  (rx_wr),
//            .rx_in_rdy                 (rx_rdy),
//            
//            .rx_out_data               (in_data[2*k+1]),
//            .rx_out_ctrl               (in_ctrl[2*k+1]),
//            .rx_out_wr                 (in_wr[2*k+1]),
//            .rx_out_rdy                (in_rdy[2*k+1]),
//
//            .tx_in_data                (out_data[2*k+1]),
//            .tx_in_ctrl                (out_ctrl[2*k+1]),
//            .tx_in_wr                  (out_wr[2*k+1]),
//            .tx_in_rdy                 (out_rdy[2*k+1]),
//            
//            .tx_out_data               (tx_data),
//            .tx_out_ctrl               (tx_ctrl),
//            .tx_out_wr                 (tx_wr),
//            .tx_out_rdy                (tx_rdy),
//            
//            // --- Misc
//            .reset                     (reset),
//            .clk                       (core_clk_int)
//         );
//
//      end // block: cpu_queues
//      
//   endgenerate
//   

//   //---------------------------------------------
//   //
//   // JTAG interface
//   //
//   //---------------------------------------------
//

		jtag_bus jtag_bus 
		(
			.jtag_rd_wr_L(jtag_rd_wr_L),
			
			.jtag_addr(control_port_address),
			.jtag_wr_data(control_port_writedata),
			.jtag_rd_data(control_port_readdata),
         .jtag_req(jtag_req),                
        .fifo_empty        (cpci_reg_fifo_empty ),
        .fifo_rd_en        (cpci_reg_fifo_rd_en ),
        .bus_rd_wr_L       (cpci_reg_rd_wr_L),
        .bus_addr          (cpci_reg_addr),
        .bus_wr_data       (cpci_reg_wr_data),
        .bus_rd_data       (cpci_reg_rd_data),
        .bus_rd_vld        (cpci_reg_rd_vld),

        .reset           (reset),
        .core_clk        (core_clk_int)
        );

		  always@(*) begin
			if(control_port_read) begin
				jtag_rd_wr_L_reg = 1'b1;
			end
			if(control_port_write) begin
				jtag_rd_wr_L_reg = 1'b0;
			end
		  end
		  
		 always@(control_port_read,control_port_write) begin
			if (reset)begin
				jtag_req_reg = 1'b0;
			end	
			else begin
				if(control_port_read || control_port_write) begin
					jtag_req_reg = 1'b1;
				end
				else 
					jtag_req_reg = 1'b0;
			end	
		 end
		  
//		  
//		  always@(posedge core_clk_int) begin
//			if (control_port_read || control_port_write) begin
//				control_port_waitrequest_reg = 1'b1;
//			end
//			else
//				control_port_waitrequest_reg = 1'b0;
//		  end		
//		  
//		  assign control_port_waitrequest = control_port_waitrequest_reg;
		  assign jtag_rd_wr_L = jtag_rd_wr_L_reg;
		  assign jtag_req = jtag_req_reg;
		//  assign control_port_readdata = control_port_readdata_reg;

   // synthesis attribute keep_hierarchy of cpci_bus is false;

//   //--------------------------------------------------
//   //
//   // --- SRAM CONTROLLERS
//   // note: register access is unimplemented yet
//   //--------------------------------------------------
//
//   wire [DATA_WIDTH+CTRL_WIDTH-1:0] sram_wr_data;
//   wire [DATA_WIDTH+CTRL_WIDTH-1:0] sram_rd_data;
//   wire                             sram_tri_en;
//   wire [CTRL_WIDTH-1:0]            sram_bw;
//   wire                             sram_we;
//
//   generate
//   if(DATA_WIDTH==64) begin: sram64
//      (* keep_hierarchy = "false" *) sram_arbiter
//        #(.SRAM_DATA_WIDTH(DATA_WIDTH+CTRL_WIDTH))
//      sram_arbiter
//        (// --- Requesters   (read and/or write)
//         .wr_0_req           (wr_0_req),
//         .wr_0_addr          (wr_0_addr),
//         .wr_0_data          (wr_0_data),
//         .wr_0_ack           (wr_0_ack),
//                             
//         .rd_0_req           (rd_0_req),
//         .rd_0_addr          (rd_0_addr),
//         .rd_0_data          (rd_0_data),
//         .rd_0_ack           (rd_0_ack),
//         .rd_0_vld           (rd_0_vld),
//                             
//         // --- sram access
//         .sram_addr          (sram_addr),
//         .sram_wr_data       (sram_wr_data),
//         .sram_rd_data       (sram_rd_data),
//         .sram_we            (sram_we),
//         .sram_bw            (sram_bw),
//         .sram_tri_en        (sram_tri_en),
//                             
//         // --- register interface
//         .sram_reg_req       (sram_reg_req),
//         .sram_reg_rd_wr_L   (sram_reg_rd_wr_L),
//         .sram_reg_addr      (sram_reg_addr),
//         .sram_reg_wr_data   (sram_reg_wr_data),
//         .sram_reg_rd_data   (sram_reg_rd_data),
//         .sram_reg_ack       (sram_reg_ack),
//
//         // --- Misc
//         .reset              (reset),
//         .clk                (core_clk_int)
//         );
//      
//      assign sram1_wr_data = sram_wr_data[`SRAM_DATA_WIDTH - 1:0];
//      assign sram2_wr_data = sram_wr_data[2 * `SRAM_DATA_WIDTH - 1:`SRAM_DATA_WIDTH];
//      assign sram_rd_data = {sram2_rd_data, sram1_rd_data};
//      assign sram1_we     = sram_we;
//      assign sram2_we     = sram_we;
//      assign sram1_bw     = sram_bw[3:0];
//      assign sram2_bw     = sram_bw[7:4];
//      assign sram1_addr   = sram_addr;
//      assign sram2_addr   = sram_addr;
//      assign sram1_tri_en  = sram_tri_en;
//      assign sram2_tri_en  = sram_tri_en;
//
//   end // block: sram64
//   else if(DATA_WIDTH==32) begin:sram32
//      (* keep_hierarchy = "false" *) sram_arbiter
//        #(.SRAM_DATA_WIDTH(DATA_WIDTH+CTRL_WIDTH))
//      sram_arbiter
//        (// --- Requesters   (read and/or write)
//         .wr_0_req           (wr_0_req),
//         .wr_0_addr          (wr_0_addr),
//         .wr_0_data          (wr_0_data),
//         .wr_0_ack           (wr_0_ack),
//                             
//         .rd_0_req           (rd_0_req),
//         .rd_0_addr          (rd_0_addr),
//         .rd_0_data          (rd_0_data),
//         .rd_0_ack           (rd_0_ack),
//         .rd_0_vld           (rd_0_vld),
//                             
//          // --- sram_access
//         .sram_addr          (sram_addr),
//         .sram_wr_data       (sram_wr_data),
//         .sram_rd_data       (sram_rd_data),
//         .sram_we            (sram_we),
//         .sram_bw            (sram_bw),
//         .sram_tri_en        (sram_tri_en),
//
//         // --- register interface
//         .sram_reg_req       (sram_reg_req),
//         .sram_reg_rd_wr_L   (sram_reg_rd_wr_L),
//         .sram_reg_addr      (sram_reg_addr),
//         .sram_reg_wr_data   (sram_reg_wr_data),
//         .sram_reg_rd_data   (sram_reg_rd_data),
//         .sram_reg_ack       (sram_reg_ack),
//
//          // --- Misc
//         .reset              (reset),
//         .clk                (core_clk_int)
//         );
//
//      assign sram1_wr_data = sram_wr_data;
//      assign sram2_wr_data = 36'b0;
//      assign sram_rd_data = sram1_rd_data;
//      assign sram1_we     = sram_we;
//      assign sram2_we     = ~ 1'b0; // Active low
//      assign sram1_bw     = sram_bw;
//      assign sram2_bw     = ~ 1'b0; // Active low
//      assign sram1_addr   = sram_addr;
//      assign sram2_addr   = 'h0;
//      assign sram1_tri_en  = sram_tri_en;
//      assign sram2_tri_en  = 1'b0;
//
//   end // block: sram32
//   endgenerate
//   
//   assign    sram1_zz = 1'b0;   
//   assign    sram2_zz = 1'b0;


   //--------------------------------------------------
   //
   // --- DDR test
   //
   //--------------------------------------------------
/*   ddr2_test ddr2_test(
               .done             (dram_done),
               .success          (dram_success),
               .cmd              (ddr2_cmd),
               .cmd_ack          (ddr2_cmd_ack),
               .addr             (ddr2_addr),
               .bank_addr        (ddr2_bank_addr),
               .burst_done       (ddr2_burst_done),
               .rd_data          (ddr2_rd_data),
               .rd_data_valid    (ddr2_rd_data_valid),
               .wr_data          (ddr2_wr_data),
               .wr_data_mask     (ddr2_wr_data_mask),
               .config1          (ddr2_config1),
               .config2          (ddr2_config2),
               .init_val         (ddr2_init_val),
               .ar_done          (ddr2_ar_done),
               .auto_ref_req     (ddr2_auto_ref_req),
               .reset            (ddr2_reset),
               .clk              (clk_ddr_200),
               .clk90            (clk90_ddr_200),
               .ctrl_reg_req     (1'b0),
               .ctrl_reg_rd_wr_L (1'b1),
               .ctrl_reg_addr    (10'h0),
               .ctrl_reg_wr_data (0),
               .ctrl_reg_rd_data (),
               .ctrl_reg_ack     (),
               .dram_reg_req     (dram_req),
               .dram_reg_rd_wr_L (dram_rd_wr_L),
               .dram_reg_addr    (dram_addr),
               .dram_reg_wr_data (dram_wr_data),
               .dram_reg_rd_data (dram_rd_data),
               .dram_reg_ack     (dram_ack),
               .clk_core_125     (core_clk_int),
               .reset_core       (reset)
            );
*/
   //-------------------------------------------------
   // User data path
   //-------------------------------------------------

   user_data_path
     #(.DATA_WIDTH(DATA_WIDTH),
       .CTRL_WIDTH(CTRL_WIDTH),
       .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
       .NUM_OUTPUT_QUEUES(NUM_QUEUES),
       .NUM_INPUT_QUEUES(NUM_QUEUES)) user_data_path
       (.in_data_0 (in_data[0]),
        .in_ctrl_0 (in_ctrl[0]),
        .in_wr_0 (in_wr[0]),
        .in_rdy_0 (in_rdy[0]),

        .in_data_1 (in_data[1]),
        .in_ctrl_1 (in_ctrl[1]),
        .in_wr_1 (in_wr[1]),
        .in_rdy_1 (in_rdy[1]),

        .in_data_2 (in_data[2]),
        .in_ctrl_2 (in_ctrl[2]),
        .in_wr_2 (in_wr[2]),
        .in_rdy_2 (in_rdy[2]),

        .in_data_3 (in_data[3]),
        .in_ctrl_3 (in_ctrl[3]),
        .in_wr_3 (in_wr[3]),
        .in_rdy_3 (in_rdy[3]),
        
        .in_data_4 (in_data[4]),
        .in_ctrl_4 (in_ctrl[4]),
        .in_wr_4 (in_wr[4]),
        .in_rdy_4 (in_rdy[4]),

        .in_data_5 (in_data[5]),
        .in_ctrl_5 (in_ctrl[5]),
        .in_wr_5 (in_wr[5]),
        .in_rdy_5 (in_rdy[5]),

        .in_data_6 (in_data[6]),
        .in_ctrl_6 (in_ctrl[6]),
        .in_wr_6 (in_wr[6]),
        .in_rdy_6 (in_rdy[6]),

        .in_data_7 (in_data[7]),
        .in_ctrl_7 (in_ctrl[7]),
        .in_wr_7 (in_wr[7]),
        .in_rdy_7 (in_rdy[7]),

        /****  not used
         // --- Interface to SATA
         .in_data_5 (in_data[5]),
         .in_ctrl_5 (in_ctrl[5]),
         .in_wr_5 (in_wr[5]),
         .in_rdy_5 (in_rdy[5]),

         // --- Interface to the loopback queue
         .in_data_6 (in_data[6]),
         .in_ctrl_6 (in_ctrl[6]),
         .in_wr_6 (in_wr[6]),
         .in_rdy_6 (in_rdy[6]),

         // --- Interface to a user queue
         .in_data_7 (in_data[7]),
         .in_ctrl_7 (in_ctrl[7]),
         .in_wr_7 (in_wr[7]),
         .in_rdy_7 (in_rdy[7]),
         *****/

        // interface to MAC, CPU tx queues
        .out_data_0 (out_data[0]),
        .out_ctrl_0 (out_ctrl[0]),
        .out_wr_0 (out_wr[0]),
        .out_rdy_0 (out_rdy[0]),
        
        .out_data_1 (out_data[1]),
        .out_ctrl_1 (out_ctrl[1]),
        .out_wr_1 (out_wr[1]),
        .out_rdy_1 (out_rdy[1]),
        
        .out_data_2 (out_data[2]),
        .out_ctrl_2 (out_ctrl[2]),
        .out_wr_2 (out_wr[2]),
        .out_rdy_2 (out_rdy[2]),
        
        .out_data_3 (out_data[3]),
        .out_ctrl_3 (out_ctrl[3]),
        .out_wr_3 (out_wr[3]),
        .out_rdy_3 (out_rdy[3]),
        
        .out_data_4 (out_data[4]),
        .out_ctrl_4 (out_ctrl[4]),
        .out_wr_4 (out_wr[4]),
        .out_rdy_4 (out_rdy[4]),
        
        .out_data_5 (out_data[5]),
        .out_ctrl_5 (out_ctrl[5]),
        .out_wr_5 (out_wr[5]),
        .out_rdy_5 (out_rdy[5]),
        
        .out_data_6 (out_data[6]),
        .out_ctrl_6 (out_ctrl[6]),
        .out_wr_6 (out_wr[6]),
        .out_rdy_6 (out_rdy[6]),
        
        .out_data_7 (out_data[7]),
        .out_ctrl_7 (out_ctrl[7]),
        .out_wr_7 (out_wr[7]),
        .out_rdy_7 (out_rdy[7]),

        /****  not used
         // --- Interface to SATA
         .out_data_5 (out_data[5]),
         .out_ctrl_5 (out_ctrl[5]),
         .out_wr_5 (out_wr[5]),
         .out_rdy_5 (out_rdy[5]),

         // --- Interface to the loopback queue
         .out_data_6 (out_data[6]),
         .out_ctrl_6 (out_ctrl[6]),
         .out_wr_6 (out_wr[6]),
         .out_rdy_6 (out_rdy[6]),

         // --- Interface to a user queue
         .out_data_7 (out_data[7]),
         .out_ctrl_7 (out_ctrl[7]),
         .out_wr_7 (out_wr[7]),
         .out_rdy_7 (out_rdy[7]),
         *****/

        // interface to SRAM
        .wr_0_addr (wr_0_addr),
        .wr_0_req (wr_0_req),
        .wr_0_ack (wr_0_ack),
        .wr_0_data (wr_0_data),
		  
        .rd_0_ack (rd_0_ack),
        .rd_0_data (rd_0_data),
        .rd_0_vld (rd_0_vld),
        .rd_0_addr (rd_0_addr),
        .rd_0_req (rd_0_req),

        // interface to DRAM
        /* TBD */

        // register interface
        .reg_req                 (udp_reg_req),
        .reg_ack                 (udp_reg_ack),
        .reg_rd_wr_L             (udp_reg_rd_wr_L),
        .reg_addr                (udp_reg_addr),
        .reg_rd_data             (udp_reg_rd_data),
        .reg_wr_data             (udp_reg_wr_data),
        
        // misc
        .reset (reset),
        .clk (core_clk_int),
		  .statemac_clk(statemac_clk)
		  //.ready_out(ready_out)
		  );


   sram	sram_inst 
	(
	.clock ( core_clk_int ),
	.data ( wr_0_data ),
	.rdaddress ( rd_0_addr ),
	.rden ( rd_0_req ),
	.wraddress ( wr_0_addr ),
	.wren ( wr_0_req ),
	.q ( rd_0_data )
	);

 parameter IDLE_WR_ACK =0, WRITE_WR_ACK = 1;
 parameter IDLE_RD_ACK = 0, READ_RD_ACK = 1;
	
	reg wr_0_ack_next,rd_0_ack_next,rd_0_vld_next;
	reg wr_0_ack_reg,rd_0_ack_reg,rd_0_vld_reg;
	reg [1:0] state_WR_ACK,state_WR_ACK_next;
	reg [1:0] state_RD_ACK,state_RD_ACK_next;
	
	always@(posedge core_clk_int) begin
		if (reset) begin
			wr_0_ack_reg <= 0;
			state_WR_ACK <= IDLE_WR_ACK;
		end
		else begin
			wr_0_ack_reg <= wr_0_ack_next;
			state_WR_ACK <= state_WR_ACK_next;
		end
	end	
		
	always@(posedge core_clk_int) begin
		if (reset) begin
			rd_0_ack_reg <= 0;
			rd_0_vld_reg <= 0;
			state_RD_ACK <= IDLE_RD_ACK;
		end
		else begin
			rd_0_ack_reg <= rd_0_ack_next;
			rd_0_vld_reg <= rd_0_vld_next;
			state_RD_ACK <= state_RD_ACK_next;
		end
	end	
	
	always@(*) begin
		state_WR_ACK_next = state_WR_ACK;
		wr_0_ack_next = wr_0_ack_reg;
		
		case(state_WR_ACK)
		
			IDLE_WR_ACK: begin
				wr_0_ack_next <= 1'b0;
				if(wr_0_req)begin
					state_WR_ACK_next = WRITE_WR_ACK;
				end
			end
			
			WRITE_WR_ACK: begin
				wr_0_ack_next <= 1'b1;
				if(rd_0_req)begin
					state_WR_ACK_next = WRITE_WR_ACK;
				end
				else 
					state_WR_ACK_next = IDLE_WR_ACK;
			end	
			
			default: begin
				state_WR_ACK_next = IDLE_WR_ACK;
			end
			
		endcase
	end
	
	always@(*) begin
		state_RD_ACK_next = state_RD_ACK;
		rd_0_ack_next = rd_0_ack_reg;
		rd_0_vld_next = rd_0_vld_reg;
		
		case(state_RD_ACK)
			IDLE_RD_ACK: begin
				rd_0_ack_next <= 1'b0;
				rd_0_vld_next <= 1'b0;
				if(rd_0_req)begin
					state_RD_ACK_next = READ_RD_ACK;
				end
			end
			
			READ_RD_ACK: begin
				rd_0_ack_next <= 1'b1;
				rd_0_vld_next <= 1'b1;
				if(rd_0_req)begin
					state_RD_ACK_next = READ_RD_ACK;
				end
				else 
					state_RD_ACK_next = IDLE_RD_ACK;
			end	
			
			default: begin
				state_RD_ACK_next = IDLE_RD_ACK;
			end
			
		endcase
	end
	
	assign rd_0_ack = rd_0_ack_reg;
	assign wr_0_ack = wr_0_ack_reg;
	assign rd_0_vld = rd_0_vld_reg;
   //-------------------------------------------------
   //
   // register address decoder, register bus mux and demux 
   //
   //-----------------------------------------------
	
	parameter IDLE_STATE_WAIT = 2'b00,WRITE_STATE_WAIT = 2'b01,READ_STATE_WAIT =2'b10;
	reg [1:0] state_wait,state_wait_next;
	reg control_port_wait_reg,control_port_wait_reg_next;
	
	always@(posedge core_clk_int) begin
		if (reset) begin
			state_wait <= IDLE_STATE_WAIT;
			control_port_wait_reg <= 1'b0;
		end
		else begin
			state_wait <= state_wait_next;
			control_port_wait_reg <= control_port_wait_reg_next;
		end
	end
	
	always@(*)begin
		state_wait_next = state_wait;
		control_port_wait_reg_next = control_port_wait_reg;
		case (state_wait) 
			IDLE_STATE_WAIT: begin
				if(control_port_write) begin
					control_port_wait_reg_next = 1'b1;
					state_wait_next = WRITE_STATE_WAIT;
				end
				if(control_port_read) begin
					control_port_wait_reg_next = 1'b1;
					state_wait_next = READ_STATE_WAIT;
				end
			end
			WRITE_STATE_WAIT: begin
				if(out_ack) begin
					control_port_wait_reg_next = 1'b0;
					state_wait_next = IDLE_STATE_WAIT;
				end
			end
			READ_STATE_WAIT: begin
				if(cpci_reg_rd_vld) begin
					control_port_wait_reg_next = 1'b0;
					state_wait_next = IDLE_STATE_WAIT;
				end
			end
		endcase
	end
	
	assign control_port_waitrequest = control_port_wait_reg_next;
   
   nf2_reg_grp nf2_reg_grp_u 
     (// interface to cpci_bus      
      .fifo_empty        (cpci_reg_fifo_empty),
      .fifo_rd_en        (cpci_reg_fifo_rd_en),
      .bus_rd_wr_L       (cpci_reg_rd_wr_L),
      .bus_addr          (cpci_reg_addr),
      .bus_wr_data       (cpci_reg_wr_data),
      .bus_rd_data       (cpci_reg_rd_data),
      .bus_rd_vld        (cpci_reg_rd_vld),
		.out_ack           (out_ack),

      // interface to core
      .core_reg_req           (core_reg_req),
      .core_reg_rd_wr_L       (core_reg_rd_wr_L),
      .core_reg_addr          (core_reg_addr),
      .core_reg_wr_data       (core_reg_wr_data),
      .core_reg_rd_data       (core_reg_rd_data),
      .core_reg_ack           (core_reg_ack),

      // interface to SRAM
      .sram_reg_req           (sram_reg_req),
      .sram_reg_rd_wr_L       (sram_reg_rd_wr_L),
      .sram_reg_addr          (sram_reg_addr),
      .sram_reg_wr_data       (sram_reg_wr_data),
      .sram_reg_rd_data       (sram_reg_rd_data),
      .sram_reg_ack           (sram_reg_ack),

      // interface to user data path
      .udp_reg_req            (udp_reg_req),
      .udp_reg_rd_wr_L        (udp_reg_rd_wr_L),
      .udp_reg_addr           (udp_reg_addr),
      .udp_reg_wr_data        (udp_reg_wr_data),
      .udp_reg_rd_data        (udp_reg_rd_data),
      .udp_reg_ack            (udp_reg_ack),
      
      // interface to DRAM
      .dram_reg_req           (dram_reg_req),
      .dram_reg_rd_wr_L       (dram_reg_rd_wr_L),
      .dram_reg_addr          (dram_reg_addr),
      .dram_reg_wr_data       (dram_reg_wr_data),
      .dram_reg_rd_data       (dram_reg_rd_data),
      .dram_reg_ack           (dram_reg_ack),

      // misc
      .clk                    (core_clk_int),
      .reset                  (reset)
      
      );


   reg_grp #(
      .REG_ADDR_BITS(`CORE_REG_ADDR_WIDTH),
      .NUM_OUTPUTS(4)
   ) core_4mb_reg_grp
   (
      // Upstream register interface
      .reg_req             (core_reg_req), 
      .reg_rd_wr_L         (core_reg_rd_wr_L),
      .reg_addr            (core_reg_addr), 
      .reg_wr_data         (core_reg_wr_data),  

      .reg_ack             (core_reg_ack),  
      .reg_rd_data         (core_reg_rd_data),
      
      
      // Downstream register interface
      .local_reg_req       (core_4mb_reg_req),
      .local_reg_rd_wr_L   (core_4mb_reg_rd_wr_L),
      .local_reg_addr      (core_4mb_reg_addr),
      .local_reg_wr_data   (core_4mb_reg_wr_data),

      .local_reg_ack       (core_4mb_reg_ack),
      .local_reg_rd_data   (core_4mb_reg_rd_data),
      
      
      //-- misc
      .clk                 (core_clk_int),
      .reset               (reset)
   );

   reg_grp #(
      .REG_ADDR_BITS(`CORE_REG_ADDR_WIDTH - 2),
      .NUM_OUTPUTS(16)
   ) core_256kb_0_reg_grp
   (
      // Upstream register interface
      .reg_req             (core_4mb_reg_req[`WORD(1,1)]), 
      .reg_ack             (core_4mb_reg_ack[`WORD(1,1)]),  
      .reg_rd_wr_L         (core_4mb_reg_rd_wr_L[`WORD(1,1)]),
      .reg_addr            (core_4mb_reg_addr[`WORD(1, `BLOCK_SIZE_1M_REG_ADDR_WIDTH)]), 

      .reg_rd_data         (core_4mb_reg_rd_data[`WORD(1, `CPCI_NF2_DATA_WIDTH)]),
      .reg_wr_data         (core_4mb_reg_wr_data[`WORD(1, `CPCI_NF2_DATA_WIDTH)]),  
      
      
      // Downstream register interface
      .local_reg_req       (core_256kb_0_reg_req),
      .local_reg_rd_wr_L   (core_256kb_0_reg_rd_wr_L),
      .local_reg_addr      (core_256kb_0_reg_addr),
      .local_reg_wr_data   (core_256kb_0_reg_wr_data),

      .local_reg_ack       (core_256kb_0_reg_ack),
      .local_reg_rd_data   (core_256kb_0_reg_rd_data),
      
      
      //-- misc
      .clk                 (core_clk_int),
      .reset               (reset)
   );

   //--------------------------------------------------
   //
   // --- Device ID register
   //
   //     Provides a set of registers to uniquely identify the design
   //     - Design/Device ID
   //     - Revision
   //     - Description
   //
   //--------------------------------------------------

   device_id_reg 
`ifdef DEVICE_ID
   #(
      .DEVICE_ID(`DEVICE_ID),
      .REVISION(`DEVICE_REVISION),
      .DEVICE_STR(`DEVICE_STR)
   ) 
`endif
   device_id_reg (
      // Register interface signals
      .reg_req          (core_256kb_0_reg_req[`WORD(`DEV_ID_BLOCK_ADDR,1)]),
      .reg_ack          (core_256kb_0_reg_ack[`WORD(`DEV_ID_BLOCK_ADDR,1)]),
      .reg_rd_wr_L      (core_256kb_0_reg_rd_wr_L[`WORD(`DEV_ID_BLOCK_ADDR,1)]),
      .reg_addr         (core_256kb_0_reg_addr[`WORD(`DEV_ID_BLOCK_ADDR,`DEV_ID_REG_ADDR_WIDTH)]),
      .reg_rd_data      (core_256kb_0_reg_rd_data[`WORD(`DEV_ID_BLOCK_ADDR,`CPCI_NF2_DATA_WIDTH)]),
      .reg_wr_data      (core_256kb_0_reg_wr_data[`WORD(`DEV_ID_BLOCK_ADDR,`CPCI_NF2_DATA_WIDTH)]),

      //
      .clk              (core_clk_int),
      .reset            (reset)
   );






   //--------------------------------------------------
   //
   // --- Dummy logic for Spartan reprogramming
   //
   //--------------------------------------------------
   
//   assign cpci_rp_en = 1'b0;
//   assign cpci_rp_prog_b = 1'b1;
//   assign cpci_rp_din = cpci_rp_cclk && cpci_rp_done && cpci_rp_init_b;



   //--------------------------------------------------
   //
   // --- NF2 MDIO controller
   //
   //--------------------------------------------------

//   nf2_mdio nf2_mdio (
//        .phy_reg_req     (core_256kb_0_reg_req[`WORD(`MDIO_BLOCK_ADDR,1)]),
//        .phy_reg_rd_wr_L (core_256kb_0_reg_rd_wr_L[`WORD(`MDIO_BLOCK_ADDR,1)]),
//        .phy_reg_ack     (core_256kb_0_reg_ack[`WORD(`MDIO_BLOCK_ADDR, 1)]),
//        .phy_reg_addr    (core_256kb_0_reg_addr[`WORD(`MDIO_BLOCK_ADDR, `MDIO_REG_ADDR_WIDTH)]),
//        .phy_reg_rd_data (core_256kb_0_reg_rd_data[`WORD(`MDIO_BLOCK_ADDR, `CPCI_NF2_DATA_WIDTH)]),
//        .phy_reg_wr_data (core_256kb_0_reg_wr_data[`WORD(`MDIO_BLOCK_ADDR, `CPCI_NF2_DATA_WIDTH)]),
//        .phy_mdc         (phy_mdc),
//        .phy_mdata_out   (phy_mdata_out),
//        .phy_mdata_tri   (phy_mdata_tri),
//        .phy_mdata_in    (phy_mdata_in),
//        .reset           (reset),
//        .clk             (core_clk_int)
//        );


//   //--------------------------------------------------
//   //
//   // --- NF2 DMA controller
//   //
//   //--------------------------------------------------
//
//   nf2_dma
//     #(.NUM_CPU_QUEUES (NUM_QUEUES/2),
//       .PKT_LEN_CNT_WIDTH (PKT_LEN_CNT_WIDTH), 
//       .USER_DATA_PATH_WIDTH (DATA_WIDTH)
//       ) nf2_dma 
//       (
//         // --- signals to/from CPU rx queues
//         .cpu_q_dma_pkt_avail          (cpu_q_dma_pkt_avail),
//
//         // ---- signals to/from CPU rx queue 0
//         .cpu_q_dma_rd_0               ( cpu_q_dma_rd[0] ),
//         .cpu_q_dma_rd_data_0          ( cpu_q_dma_rd_data[0] ), 
//         .cpu_q_dma_rd_ctrl_0          ( cpu_q_dma_rd_ctrl[0] ),
//
//         // ---- signals to/from CPU rx queue 1
//         .cpu_q_dma_rd_1               ( cpu_q_dma_rd[1] ),
//         .cpu_q_dma_rd_data_1          ( cpu_q_dma_rd_data[1] ), 
//         .cpu_q_dma_rd_ctrl_1          ( cpu_q_dma_rd_ctrl[1] ),
//
//         // ---- signals to/from CPU rx queue 2
//         .cpu_q_dma_rd_2               ( cpu_q_dma_rd[2] ),
//         .cpu_q_dma_rd_data_2          ( cpu_q_dma_rd_data[2] ), 
//         .cpu_q_dma_rd_ctrl_2          ( cpu_q_dma_rd_ctrl[2] ),
//
//         // ---- signals to/from CPU rx queue 3
//         .cpu_q_dma_rd_3               ( cpu_q_dma_rd[3] ),
//         .cpu_q_dma_rd_data_3          ( cpu_q_dma_rd_data[3] ), 
//         .cpu_q_dma_rd_ctrl_3          ( cpu_q_dma_rd_ctrl[3] ),
//
//         // signals to/from CPU tx queues
//         .cpu_q_dma_nearly_full        (cpu_q_dma_nearly_full),
//
//         // signals to/from CPU tx queue 0
//         .cpu_q_dma_wr_0               ( cpu_q_dma_wr[0] ),
//         .cpu_q_dma_wr_data_0          ( cpu_q_dma_wr_data[0] ), 
//         .cpu_q_dma_wr_ctrl_0          ( cpu_q_dma_wr_ctrl[0] ),
//
//         // signals to/from CPU tx queue 1
//         .cpu_q_dma_wr_1               ( cpu_q_dma_wr[1] ),
//         .cpu_q_dma_wr_data_1          ( cpu_q_dma_wr_data[1] ), 
//         .cpu_q_dma_wr_ctrl_1          ( cpu_q_dma_wr_ctrl[1] ),
//
//         // signals to/from CPU tx queue 2
//         .cpu_q_dma_wr_2               ( cpu_q_dma_wr[2] ),
//         .cpu_q_dma_wr_data_2          ( cpu_q_dma_wr_data[2] ), 
//         .cpu_q_dma_wr_ctrl_2          ( cpu_q_dma_wr_ctrl[2] ),
//
//         // signals to/from CPU tx queue 3
//         .cpu_q_dma_wr_3               ( cpu_q_dma_wr[3] ),
//         .cpu_q_dma_wr_data_3          ( cpu_q_dma_wr_data[3] ), 
//         .cpu_q_dma_wr_ctrl_3          ( cpu_q_dma_wr_ctrl[3] ),
//
//         // --- signals to/from CPCI pins
//         .dma_op_code_req              (dma_op_code_req),
//         .dma_op_queue_id              (dma_op_queue_id),
//         .dma_op_code_ack              (dma_op_code_ack),
//
//         // DMA TX data and flow control 
//         .dma_vld_c2n                  (dma_vld_c2n),
//         .dma_data_c2n                 (dma_data_c2n),
//         .dma_dest_q_nearly_full_n2c   (dma_q_nearly_full_n2c),
//
//         // DMA RX data and flow control 
//         .dma_vld_n2c                  (dma_vld_n2c),
//         .dma_data_n2c                 (dma_data_n2c),
//         .dma_dest_q_nearly_full_c2n   (dma_q_nearly_full_c2n),
//
//         // enable to drive tri-state bus 
//         .dma_data_tri_en              (dma_data_tri_en),
//
//         // ----from reg_grp dma interface
//         .dma_reg_req                  (core_256kb_0_reg_req[`WORD(`DMA_BLOCK_ADDR,1)]),
//         .dma_reg_rd_wr_L              (core_256kb_0_reg_rd_wr_L[`WORD(`DMA_BLOCK_ADDR,1)]),
//         .dma_reg_ack                  (core_256kb_0_reg_ack[`WORD(`DMA_BLOCK_ADDR, 1)]),
//         .dma_reg_addr                 (core_256kb_0_reg_addr[`WORD(`DMA_BLOCK_ADDR, `DMA_REG_ADDR_WIDTH)]),
//         .dma_reg_rd_data              (core_256kb_0_reg_rd_data[`WORD(`DMA_BLOCK_ADDR, `CPCI_NF2_DATA_WIDTH)]),
//         .dma_reg_wr_data              (core_256kb_0_reg_wr_data[`WORD(`DMA_BLOCK_ADDR, `CPCI_NF2_DATA_WIDTH)]),
//        
//         //--- misc
//         .reset                        (reset),
//         .clk                          (core_clk_int),
//         .cpci_clk                     (cpci_clk_int)
//        );

   // synthesis attribute keep_hierarchy of nf2_dma is false;

   //--------------------------------------------------
   //
   // --- Unused register signals
   //
   //--------------------------------------------------

   unused_reg #(
      .REG_ADDR_WIDTH(`BLOCK_SIZE_1M_REG_ADDR_WIDTH)
   ) unused_reg_core_4mb_0 (
      // Register interface signals
      .reg_req             (core_4mb_reg_req[`WORD(0,1)]), 
      .reg_ack             (core_4mb_reg_ack[`WORD(0,1)]),  
      .reg_rd_wr_L         (core_4mb_reg_rd_wr_L[`WORD(0,1)]),
      .reg_addr            (core_4mb_reg_addr[`WORD(0, `BLOCK_SIZE_1M_REG_ADDR_WIDTH)]), 

      .reg_rd_data         (core_4mb_reg_rd_data[`WORD(0, `CPCI_NF2_DATA_WIDTH)]),
      .reg_wr_data         (core_4mb_reg_wr_data[`WORD(0, `CPCI_NF2_DATA_WIDTH)]),  

      //
      .clk           (core_clk_int),
      .reset         (reset)
   );

   unused_reg #(
      .REG_ADDR_WIDTH(`BLOCK_SIZE_1M_REG_ADDR_WIDTH)
   ) unused_reg_core_4mb_2 (
      // Register interface signals
      .reg_req             (core_4mb_reg_req[`WORD(2,1)]), 
      .reg_ack             (core_4mb_reg_ack[`WORD(2,1)]),  
      .reg_rd_wr_L         (core_4mb_reg_rd_wr_L[`WORD(2,1)]),
      .reg_addr            (core_4mb_reg_addr[`WORD(2, `BLOCK_SIZE_1M_REG_ADDR_WIDTH)]), 

      .reg_rd_data         (core_4mb_reg_rd_data[`WORD(2, `CPCI_NF2_DATA_WIDTH)]),
      .reg_wr_data         (core_4mb_reg_wr_data[`WORD(2, `CPCI_NF2_DATA_WIDTH)]),  

      //
      .clk           (core_clk_int),
      .reset         (reset)
   );

   unused_reg #(
      .REG_ADDR_WIDTH(`BLOCK_SIZE_1M_REG_ADDR_WIDTH)
   ) unused_reg_core_4mb_3 (
      // Register interface signals
      .reg_req             (core_4mb_reg_req[`WORD(3,1)]), 
      .reg_ack             (core_4mb_reg_ack[`WORD(3,1)]),  
      .reg_rd_wr_L         (core_4mb_reg_rd_wr_L[`WORD(3,1)]),
      .reg_addr            (core_4mb_reg_addr[`WORD(3, `BLOCK_SIZE_1M_REG_ADDR_WIDTH)]), 

      .reg_rd_data         (core_4mb_reg_rd_data[`WORD(3, `CPCI_NF2_DATA_WIDTH)]),
      .reg_wr_data         (core_4mb_reg_wr_data[`WORD(3, `CPCI_NF2_DATA_WIDTH)]),  

      //
      .clk           (core_clk_int),
      .reset         (reset)
   );

   generate
      //genvar i;
      for (i = 0; i < 16; i = i + 1) begin: unused_reg_core_256kb_0 
         if (!(i >= `MAC_GRP_0_BLOCK_ADDR && 
               i <  `MAC_GRP_0_BLOCK_ADDR + NUM_QUEUES/2) && 
             !(i >= `CPU_QUEUE_0_BLOCK_ADDR && 
               i <  `CPU_QUEUE_0_BLOCK_ADDR + NUM_QUEUES/2) && 
             i != `DEV_ID_BLOCK_ADDR && 
             i != `DMA_BLOCK_ADDR && 
             i != `MDIO_BLOCK_ADDR) 
            unused_reg #(
               .REG_ADDR_WIDTH(`BLOCK_SIZE_64k_REG_ADDR_WIDTH)
            ) unused_reg_core_256kb_0_x (
               // Register interface signals
               .reg_req             (core_256kb_0_reg_req[`WORD(i,1)]), 
               .reg_ack             (core_256kb_0_reg_ack[`WORD(i,1)]),  
               .reg_rd_wr_L         (core_256kb_0_reg_rd_wr_L[`WORD(i,1)]),
               .reg_addr            (core_256kb_0_reg_addr[`WORD(i, `BLOCK_SIZE_64k_REG_ADDR_WIDTH)]), 

               .reg_rd_data         (core_256kb_0_reg_rd_data[`WORD(i, `CPCI_NF2_DATA_WIDTH)]),
               .reg_wr_data         (core_256kb_0_reg_wr_data[`WORD(i, `CPCI_NF2_DATA_WIDTH)]),  

               //
               .clk           (core_clk_int),
               .reset         (reset)
            );
      end
   endgenerate

   //--------------------------------------------------
   //
   // --- Logic Analyzer signals
   //
   //--------------------------------------------------

//   reg [31:0] tmp_debug;
//
//   always @(posedge core_clk_int) begin
//      tmp_debug  <= cpci_debug_data;
//      debug_data <= tmp_debug;
//   end


//   INV invert_clk(.I(core_clk_int), .O(not_core_clk_int));
//
//   FDDRRSE debug_clk_0_ddr_iob
//     (.Q  (debug_clk[0]),
//      .D0 (1'b0),
//      .D1 (1'b1),
//      .C0 (core_clk_int),
//      .C1 (not_core_clk_int),
//      .CE (1'b1),
//      .R  (1'b0),
//      .S  (1'b0)
//      );
//
//   FDDRRSE debug_clk_1_ddr_iob
//     (.Q  (debug_clk[1]),
//      .D0 (1'b0),
//      .D1 (1'b1),
//      .C0 (core_clk_int),
//      .C1 (not_core_clk_int),
//      .CE (1'b1),
//      .R  (1'b0),
//      .S  (1'b0)
//      );
      

	   assign        tx_rgmii_clk_int = core_clk_int;
      assign        rx_rgmii_0_clk_int = core_clk_int;
      assign        rx_rgmii_1_clk_int = core_clk_int;
      assign        rx_rgmii_2_clk_int = core_clk_int;
      assign        rx_rgmii_3_clk_int = core_clk_int;

   //--------------------------------------------------
   //
   // --- MAC signal encapsulation/decapsulation
   //
   //--------------------------------------------------

   // --- Mac 0
	

	
		assign gmac_tx_data_0_out = gmac_tx_data_out[0];
		assign gmac_tx_dvld_0_out = gmac_tx_dvld_out[0];
		assign gmac_tx_ack_out[0]  = gmac_tx_ack_0_out;
		assign end_of_packet_0_out = end_of_packet[0];
		assign start_of_packet_0_out = start_of_packet[0];
		
		  
		assign gmac_rx_data_in[0]				=	gmac_rx_data_0_in;
		assign gmac_rx_dvld_in[0] 				=	gmac_rx_dvld_0_in;
		assign gmac_rx_frame_error_in[0] 	=	gmac_rx_frame_error_0_in; 
		
		assign gmac_tx_data_1_out = gmac_tx_data_out[1];
		assign gmac_tx_dvld_1_out = gmac_tx_dvld_out[1];
		assign gmac_tx_ack_out[1]  = gmac_tx_ack_1_out;
		assign end_of_packet_1_out = end_of_packet[1];
		assign start_of_packet_1_out = start_of_packet[1];
		  
		assign gmac_rx_data_in[1]				=	gmac_rx_data_1_in;
		assign gmac_rx_dvld_in[1] 				=	gmac_rx_dvld_1_in;
		assign gmac_rx_frame_error_in[1] 	=	gmac_rx_frame_error_1_in; 
		
		assign gmac_tx_data_2_out = gmac_tx_data_out[2];
		assign gmac_tx_dvld_2_out = gmac_tx_dvld_out[2];
		assign gmac_tx_ack_out[2]  = gmac_tx_ack_2_out;
		assign end_of_packet_2_out = end_of_packet[2];
		assign start_of_packet_2_out = start_of_packet[2];
		  
		assign gmac_rx_data_in[2]				=	gmac_rx_data_2_in;
		assign gmac_rx_dvld_in[2] 				=	gmac_rx_dvld_2_in;
		assign gmac_rx_frame_error_in[2] 	=	gmac_rx_frame_error_2_in; 
		
		assign gmac_tx_data_3_out = gmac_tx_data_out[3];
		assign gmac_tx_dvld_3_out = gmac_tx_dvld_out[3];
		assign gmac_tx_ack_out[3]  = gmac_tx_ack_3_out;
		assign end_of_packet_3_out = end_of_packet[3];
		assign start_of_packet_3_out = start_of_packet[3];
		  
		assign gmac_rx_data_in[3]				=	gmac_rx_data_3_in;
		assign gmac_rx_dvld_in[3] 				=	gmac_rx_dvld_3_in;
		assign gmac_rx_frame_error_in[3] 	=	gmac_rx_frame_error_3_in; 
	

	
//   assign gmii_0_txd_int         = gmii_txd_int[0];
//   assign gmii_0_tx_en_int       = gmii_tx_en_int[0];
//   assign gmii_0_tx_er_int       = gmii_tx_er_int[0];
//
//   assign gmii_crs_int[0]        = gmii_0_crs_int;
//   assign gmii_col_int[0]        = gmii_0_col_int;
//   assign gmii_rxd_reg[0]        = gmii_0_rxd_reg;
//   assign gmii_rx_dv_reg[0]      = gmii_0_rx_dv_reg;
//   assign gmii_rx_er_reg[0]      = gmii_0_rx_er_reg;
//   assign eth_link_status[0]     = eth_link_0_status;
//   assign eth_clock_speed[0]     = eth_clock_0_speed;
//   assign eth_duplex_status[0]   = eth_duplex_0_status;
   assign rx_rgmii_clk_int[0]    = rx_rgmii_0_clk_int;

   // --- Mac 1
//   assign gmii_1_txd_int         = gmii_txd_int[1];
//   assign gmii_1_tx_en_int       = gmii_tx_en_int[1];
//   assign gmii_1_tx_er_int       = gmii_tx_er_int[1];
//
//   assign gmii_crs_int[1]        = gmii_1_crs_int;
//   assign gmii_col_int[1]        = gmii_1_col_int;
//   assign gmii_rxd_reg[1]        = gmii_1_rxd_reg;
//   assign gmii_rx_dv_reg[1]      = gmii_1_rx_dv_reg;
//   assign gmii_rx_er_reg[1]      = gmii_1_rx_er_reg;
//   assign eth_link_status[1]     = eth_link_1_status;
//   assign eth_clock_speed[1]     = eth_clock_1_speed;
//   assign eth_duplex_status[1]   = eth_duplex_1_status;
   assign rx_rgmii_clk_int[1]    = rx_rgmii_1_clk_int;

   // --- Mac 2
//   assign gmii_2_txd_int         = gmii_txd_int[2];
//   assign gmii_2_tx_en_int       = gmii_tx_en_int[2];
//   assign gmii_2_tx_er_int       = gmii_tx_er_int[2];
//
//   assign gmii_crs_int[2]        = gmii_2_crs_int;
//   assign gmii_col_int[2]        = gmii_2_col_int;
//   assign gmii_rxd_reg[2]        = gmii_2_rxd_reg;
//   assign gmii_rx_dv_reg[2]      = gmii_2_rx_dv_reg;
//   assign gmii_rx_er_reg[2]      = gmii_2_rx_er_reg;
//   assign eth_link_status[2]     = eth_link_2_status;
//   assign eth_clock_speed[2]     = eth_clock_2_speed;
//   assign eth_duplex_status[2]   = eth_duplex_2_status;
   assign rx_rgmii_clk_int[2]    = rx_rgmii_2_clk_int;

   // --- Mac 3
//   assign gmii_3_txd_int         = gmii_txd_int[3];
//   assign gmii_3_tx_en_int       = gmii_tx_en_int[3];
//   assign gmii_3_tx_er_int       = gmii_tx_er_int[3];
//
//   assign gmii_crs_int[3]        = gmii_3_crs_int;
//   assign gmii_col_int[3]        = gmii_3_col_int;
//   assign gmii_rxd_reg[3]        = gmii_3_rxd_reg;
//   assign gmii_rx_dv_reg[3]      = gmii_3_rx_dv_reg;
//   assign gmii_rx_er_reg[3]      = gmii_3_rx_er_reg;
//   assign eth_link_status[3]     = eth_link_3_status;
//   assign eth_clock_speed[3]     = eth_clock_3_speed;
//   assign eth_duplex_status[3]   = eth_duplex_3_status;
   assign rx_rgmii_clk_int[3]    = rx_rgmii_3_clk_int;

endmodule // nf2_core