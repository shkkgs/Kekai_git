// ethernet_port_interface_0.v

// This file was auto-generated as part of a SOPC Builder generate operation.
// If you edit it your changes will probably be lost.

`timescale 1 ps / 1 ps
module ethernet_port_interface_0 (
		input  wire        clk,                      //               clock_reset.clk
		input  wire        reset,                    //         clock_reset_reset.reset
		input  wire [26:0] control_port_address,     //              control_port.address
		input  wire        control_port_read,        //                          .read
		output wire [31:0] control_port_readdata,    //                          .readdata
		input  wire        control_port_write,       //                          .write
		input  wire [31:0] control_port_writedata,   //                          .writedata
		output wire        control_port_waitrequest, //                          .waitrequest
		input  wire [7:0]  sink_data0,               //     avalon_streaming_sink.data
		output wire        sink_ready0,              //                          .ready
		input  wire        sink_valid0,              //                          .valid
		input  wire [5:0]  sink_error0,              //                          .error
		input  wire        sink_startofpacket0,      //                          .startofpacket
		input  wire        sink_endofpacket0,        //                          .endofpacket
		input  wire [7:0]  sink_data1,               //   avalon_streaming_sink_1.data
		output wire        sink_ready1,              //                          .ready
		input  wire        sink_valid1,              //                          .valid
		input  wire [5:0]  sink_error1,              //                          .error
		input  wire        sink_startofpacket1,      //                          .startofpacket
		input  wire        sink_endofpacket1,        //                          .endofpacket
		input  wire [7:0]  sink_data2,               //   avalon_streaming_sink_2.data
		output wire        sink_ready2,              //                          .ready
		input  wire        sink_valid2,              //                          .valid
		input  wire [5:0]  sink_error2,              //                          .error
		input  wire        sink_startofpacket2,      //                          .startofpacket
		input  wire        sink_endofpacket2,        //                          .endofpacket
		input  wire [7:0]  sink_data3,               //   avalon_streaming_sink_3.data
		output wire        sink_ready3,              //                          .ready
		input  wire        sink_valid3,              //                          .valid
		input  wire [5:0]  sink_error3,              //                          .error
		input  wire        sink_startofpacket3,      //                          .startofpacket
		input  wire        sink_endofpacket3,        //                          .endofpacket
		output wire [7:0]  source_data0,             //   avalon_streaming_source.data
		input  wire        source_ready0,            //                          .ready
		output wire        source_valid0,            //                          .valid
		output wire        source_error0,            //                          .error
		output wire        source_startofpacket0,    //                          .startofpacket
		output wire        source_endofpacket0,      //                          .endofpacket
		output wire [7:0]  source_data1,             // avalon_streaming_source_1.data
		input  wire        source_ready1,            //                          .ready
		output wire        source_valid1,            //                          .valid
		output wire        source_error1,            //                          .error
		output wire        source_startofpacket1,    //                          .startofpacket
		output wire        source_endofpacket1,      //                          .endofpacket
		output wire [7:0]  source_data2,             // avalon_streaming_source_2.data
		input  wire        source_ready2,            //                          .ready
		output wire        source_valid2,            //                          .valid
		output wire        source_error2,            //                          .error
		output wire        source_startofpacket2,    //                          .startofpacket
		output wire        source_endofpacket2,      //                          .endofpacket
		output wire [7:0]  source_data3,             // avalon_streaming_source_3.data
		input  wire        source_ready3,            //                          .ready
		output wire        source_valid3,            //                          .valid
		output wire        source_error3,            //                          .error
		output wire        source_startofpacket3,    //                          .startofpacket
		output wire        source_endofpacket3,      //                          .endofpacket
		input  wire        rxm_write_bar_0_1,        //                       rxm.write
		input  wire [27:0] rxm_address_bar_0_1,      //                          .address
		input  wire [63:0] rxm_writedata_bar_0_1,    //                          .writedata
		input  wire [7:0]  rxm_byteenable_bar_0_1,   //                          .byteenable
		output wire [63:0] rxm_readdata_bar_0_1,     //                          .readdata
		input  wire [9:0]  rxm_burst_count_bar_0_1,  //                          .burstcount
		output wire        rxm_wait_request_bar_0_1, //                          .waitrequest
		output wire        rxm_read_valid_bar_0_1,   //                          .readdatavalid
		input  wire        rxm_read_bar_0_1,         //                          .read
		output wire        txs_chip_select,          //             avalon_master.chipselect
		output wire        txs_write,                //                          .write
		output wire [24:0] txs_address,              //                          .address
		output wire [9:0]  txs_burst_count,          //                          .burstcount
		output wire [63:0] txs_writedata,            //                          .writedata
		output wire [7:0]  txs_byteenable,           //                          .byteenable
		input  wire        txs_read_valid,           //                          .readdatavalid
		input  wire [63:0] txs_readdata,             //                          .readdata
		input  wire        txs_wait_request,         //                          .waitrequest
		output wire        txs_read,                 //                          .read
		input  wire        statemac_clk              //               conduit_end.export
	);

	ethernet_port_interface ethernet_port_interface_0 (
		.clk                      (clk),                      //               clock_reset.clk
		.reset                    (reset),                    //         clock_reset_reset.reset
		.control_port_address     (control_port_address),     //              control_port.address
		.control_port_read        (control_port_read),        //                          .read
		.control_port_readdata    (control_port_readdata),    //                          .readdata
		.control_port_write       (control_port_write),       //                          .write
		.control_port_writedata   (control_port_writedata),   //                          .writedata
		.control_port_waitrequest (control_port_waitrequest), //                          .waitrequest
		.sink_data0               (sink_data0),               //     avalon_streaming_sink.data
		.sink_ready0              (sink_ready0),              //                          .ready
		.sink_valid0              (sink_valid0),              //                          .valid
		.sink_error0              (sink_error0),              //                          .error
		.sink_startofpacket0      (sink_startofpacket0),      //                          .startofpacket
		.sink_endofpacket0        (sink_endofpacket0),        //                          .endofpacket
		.sink_data1               (sink_data1),               //   avalon_streaming_sink_1.data
		.sink_ready1              (sink_ready1),              //                          .ready
		.sink_valid1              (sink_valid1),              //                          .valid
		.sink_error1              (sink_error1),              //                          .error
		.sink_startofpacket1      (sink_startofpacket1),      //                          .startofpacket
		.sink_endofpacket1        (sink_endofpacket1),        //                          .endofpacket
		.sink_data2               (sink_data2),               //   avalon_streaming_sink_2.data
		.sink_ready2              (sink_ready2),              //                          .ready
		.sink_valid2              (sink_valid2),              //                          .valid
		.sink_error2              (sink_error2),              //                          .error
		.sink_startofpacket2      (sink_startofpacket2),      //                          .startofpacket
		.sink_endofpacket2        (sink_endofpacket2),        //                          .endofpacket
		.sink_data3               (sink_data3),               //   avalon_streaming_sink_3.data
		.sink_ready3              (sink_ready3),              //                          .ready
		.sink_valid3              (sink_valid3),              //                          .valid
		.sink_error3              (sink_error3),              //                          .error
		.sink_startofpacket3      (sink_startofpacket3),      //                          .startofpacket
		.sink_endofpacket3        (sink_endofpacket3),        //                          .endofpacket
		.source_data0             (source_data0),             //   avalon_streaming_source.data
		.source_ready0            (source_ready0),            //                          .ready
		.source_valid0            (source_valid0),            //                          .valid
		.source_error0            (source_error0),            //                          .error
		.source_startofpacket0    (source_startofpacket0),    //                          .startofpacket
		.source_endofpacket0      (source_endofpacket0),      //                          .endofpacket
		.source_data1             (source_data1),             // avalon_streaming_source_1.data
		.source_ready1            (source_ready1),            //                          .ready
		.source_valid1            (source_valid1),            //                          .valid
		.source_error1            (source_error1),            //                          .error
		.source_startofpacket1    (source_startofpacket1),    //                          .startofpacket
		.source_endofpacket1      (source_endofpacket1),      //                          .endofpacket
		.source_data2             (source_data2),             // avalon_streaming_source_2.data
		.source_ready2            (source_ready2),            //                          .ready
		.source_valid2            (source_valid2),            //                          .valid
		.source_error2            (source_error2),            //                          .error
		.source_startofpacket2    (source_startofpacket2),    //                          .startofpacket
		.source_endofpacket2      (source_endofpacket2),      //                          .endofpacket
		.source_data3             (source_data3),             // avalon_streaming_source_3.data
		.source_ready3            (source_ready3),            //                          .ready
		.source_valid3            (source_valid3),            //                          .valid
		.source_error3            (source_error3),            //                          .error
		.source_startofpacket3    (source_startofpacket3),    //                          .startofpacket
		.source_endofpacket3      (source_endofpacket3),      //                          .endofpacket
		.rxm_write_bar_0_1        (rxm_write_bar_0_1),        //                       rxm.write
		.rxm_address_bar_0_1      (rxm_address_bar_0_1),      //                          .address
		.rxm_writedata_bar_0_1    (rxm_writedata_bar_0_1),    //                          .writedata
		.rxm_byteenable_bar_0_1   (rxm_byteenable_bar_0_1),   //                          .byteenable
		.rxm_readdata_bar_0_1     (rxm_readdata_bar_0_1),     //                          .readdata
		.rxm_burst_count_bar_0_1  (rxm_burst_count_bar_0_1),  //                          .burstcount
		.rxm_wait_request_bar_0_1 (rxm_wait_request_bar_0_1), //                          .waitrequest
		.rxm_read_valid_bar_0_1   (rxm_read_valid_bar_0_1),   //                          .readdatavalid
		.rxm_read_bar_0_1         (rxm_read_bar_0_1),         //                          .read
		.txs_chip_select          (txs_chip_select),          //             avalon_master.chipselect
		.txs_write                (txs_write),                //                          .write
		.txs_address              (txs_address),              //                          .address
		.txs_burst_count          (txs_burst_count),          //                          .burstcount
		.txs_writedata            (txs_writedata),            //                          .writedata
		.txs_byteenable           (txs_byteenable),           //                          .byteenable
		.txs_read_valid           (txs_read_valid),           //                          .readdatavalid
		.txs_readdata             (txs_readdata),             //                          .readdata
		.txs_wait_request         (txs_wait_request),         //                          .waitrequest
		.txs_read                 (txs_read),                 //                          .read
		.statemac_clk             (statemac_clk)              //               conduit_end.export
	);

endmodule
