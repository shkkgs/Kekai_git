library verilog;
use verilog.vl_types.all;
entity ethernet_port_interface is
    port(
        clk             : in     vl_logic;
        statemac_clk    : in     vl_logic;
        reset           : in     vl_logic;
        control_port_address: in     vl_logic_vector(26 downto 0);
        control_port_read: in     vl_logic;
        control_port_readdata: out    vl_logic_vector(31 downto 0);
        control_port_write: in     vl_logic;
        control_port_writedata: in     vl_logic_vector(31 downto 0);
        control_port_waitrequest: out    vl_logic;
        sink_data0      : in     vl_logic_vector(7 downto 0);
        sink_ready0     : out    vl_logic;
        sink_valid0     : in     vl_logic;
        sink_error0     : in     vl_logic_vector(5 downto 0);
        sink_startofpacket0: in     vl_logic;
        sink_endofpacket0: in     vl_logic;
        source_data0    : out    vl_logic_vector(7 downto 0);
        source_ready0   : in     vl_logic;
        source_valid0   : out    vl_logic;
        source_error0   : out    vl_logic;
        source_startofpacket0: out    vl_logic;
        source_endofpacket0: out    vl_logic;
        sink_data1      : in     vl_logic_vector(7 downto 0);
        sink_ready1     : out    vl_logic;
        sink_valid1     : in     vl_logic;
        sink_error1     : in     vl_logic_vector(5 downto 0);
        sink_startofpacket1: in     vl_logic;
        sink_endofpacket1: in     vl_logic;
        source_data1    : out    vl_logic_vector(7 downto 0);
        source_ready1   : in     vl_logic;
        source_valid1   : out    vl_logic;
        source_error1   : out    vl_logic;
        source_startofpacket1: out    vl_logic;
        source_endofpacket1: out    vl_logic;
        sink_data2      : in     vl_logic_vector(7 downto 0);
        sink_ready2     : out    vl_logic;
        sink_valid2     : in     vl_logic;
        sink_error2     : in     vl_logic_vector(5 downto 0);
        sink_startofpacket2: in     vl_logic;
        sink_endofpacket2: in     vl_logic;
        source_data2    : out    vl_logic_vector(7 downto 0);
        source_ready2   : in     vl_logic;
        source_valid2   : out    vl_logic;
        source_error2   : out    vl_logic;
        source_startofpacket2: out    vl_logic;
        source_endofpacket2: out    vl_logic;
        sink_data3      : in     vl_logic_vector(7 downto 0);
        sink_ready3     : out    vl_logic;
        sink_valid3     : in     vl_logic;
        sink_error3     : in     vl_logic_vector(5 downto 0);
        sink_startofpacket3: in     vl_logic;
        sink_endofpacket3: in     vl_logic;
        source_data3    : out    vl_logic_vector(7 downto 0);
        source_ready3   : in     vl_logic;
        source_valid3   : out    vl_logic;
        source_error3   : out    vl_logic;
        source_startofpacket3: out    vl_logic;
        source_endofpacket3: out    vl_logic;
        txs_chip_select : out    vl_logic;
        txs_read        : out    vl_logic;
        txs_write       : out    vl_logic;
        txs_address     : out    vl_logic_vector(24 downto 0);
        txs_burst_count : out    vl_logic_vector(9 downto 0);
        txs_writedata   : out    vl_logic_vector(63 downto 0);
        txs_byteenable  : out    vl_logic_vector(7 downto 0);
        txs_read_valid  : in     vl_logic;
        txs_readdata    : in     vl_logic_vector(63 downto 0);
        txs_wait_request: in     vl_logic;
        rxm_read_bar_0_1: in     vl_logic;
        rxm_write_bar_0_1: in     vl_logic;
        rxm_address_bar_0_1: in     vl_logic_vector(27 downto 0);
        rxm_writedata_bar_0_1: in     vl_logic_vector(63 downto 0);
        rxm_byteenable_bar_0_1: in     vl_logic_vector(7 downto 0);
        rxm_burst_count_bar_0_1: in     vl_logic_vector(9 downto 0);
        rxm_wait_request_bar_0_1: out    vl_logic;
        rxm_readdata_bar_0_1: out    vl_logic_vector(63 downto 0);
        rxm_read_valid_bar_0_1: out    vl_logic
    );
end ethernet_port_interface;
