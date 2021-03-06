----------------------------------------------------------------------------------------------
--
--      Input file         : core.vhd
--      Design name        : core
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Top level entity of the integer unit
--
--
----------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config_Pkg.ALL;
USE work.core_Pkg.ALL;

ENTITY core IS
PORT
(
    imem_adr_o : OUT std_ulogic_vector(CFG_IMEM_SIZE - 1 DOWNTO 0);
    imem_ena_o : OUT std_ulogic;
    dmem_dat_o : OUT std_ulogic_vector(CFG_DMEM_WIDTH - 1 DOWNTO 0);
    dmem_adr_o : OUT std_ulogic_vector(CFG_DMEM_SIZE - 1 DOWNTO 0);
    dmem_sel_o : OUT std_ulogic_vector(3 DOWNTO 0);
    dmem_we_o : OUT std_ulogic;
    dmem_ena_o : OUT std_ulogic;
    imem_dat_i : IN std_ulogic_vector(CFG_IMEM_WIDTH - 1 DOWNTO 0);
    dmem_dat_i : IN std_ulogic_vector(CFG_DMEM_WIDTH - 1 DOWNTO 0);
    dmem_ena_i : IN std_ulogic;
    int_i  : IN std_ulogic;
    rst_i  : IN std_ulogic;
    clk_i  : IN std_ulogic
);
END core;

ARCHITECTURE arch OF core IS

    SIGNAL fetch_i : fetch_in_type;
    SIGNAL fetch_o : fetch_out_type;

    SIGNAL decode_i : decode_in_type;
    SIGNAL decode_o : decode_out_type;

    SIGNAL gprf_o : gprf_out_type;

    SIGNAL exec_i : execute_in_type;
    SIGNAL exec_o : execute_out_type;

    SIGNAL mem_i : mem_in_type;
    SIGNAL mem_o : mem_out_type;

    SIGNAL ena_i : std_ulogic;

BEGIN

    ena_i <= dmem_ena_i;

    fetch_i.hazard        <= decode_o.hazard;
    fetch_i.branch        <= exec_o.branch;
    fetch_i.branch_target <= exec_o.alu_result(CFG_IMEM_SIZE - 1 DOWNTO 0);

    fetch0 : fetch PORT MAP
    (
        fetch_o => fetch_o,
        imem_adr_o  => imem_adr_o,
        imem_ena_o  => imem_ena_o,
        fetch_i => fetch_i,
        rst_i   => rst_i,
        ena_i   => ena_i,
        clk_i   => clk_i
    );

    decode_i.program_counter   <= fetch_o.program_counter;
    decode_i.instruction       <= imem_dat_i;
    decode_i.ctrl_wb           <= mem_o.ctrl_wb;
    decode_i.ctrl_mem_wb       <= mem_o.ctrl_mem_wb;
    decode_i.mem_result        <= dmem_dat_i;
    decode_i.alu_result        <= mem_o.alu_result;
    decode_i.interrupt         <= int_i;
    decode_i.flush_id          <= exec_o.flush_id;

    decode0: decode GENERIC MAP
    (
        G_INTERRUPT  => CFG_INTERRUPT,
        G_USE_HW_MUL => CFG_USE_HW_MUL,
        G_USE_BARREL => CFG_USE_BARREL,
        G_DEBUG      => CFG_DEBUG
    )
    PORT MAP
    (
        decode_o => decode_o,
        decode_i => decode_i,
        gprf_o   => gprf_o,
        ena_i    => ena_i,
        rst_i    => rst_i,
        clk_i    => clk_i
    );

    exec_i.fwd_dec              <= decode_o.fwd_dec;
    exec_i.fwd_dec_result       <= decode_o.fwd_dec_result;

    exec_i.dat_a                <= gprf_o.dat_a_o;
    exec_i.dat_b                <= gprf_o.dat_b_o;
    exec_i.dat_d                <= gprf_o.dat_d_o;
    exec_i.reg_a                <= decode_o.reg_a;
    exec_i.reg_b                <= decode_o.reg_b;

    exec_i.imm                  <= decode_o.imm;
    exec_i.program_counter      <= decode_o.program_counter;
    exec_i.ctrl_wb              <= decode_o.ctrl_wb;
    exec_i.ctrl_mem             <= decode_o.ctrl_mem;
    exec_i.ctrl_ex              <= decode_o.ctrl_ex;

    exec_i.fwd_mem              <= mem_o.ctrl_wb;
    exec_i.mem_result           <= dmem_dat_i;
    exec_i.alu_result           <= mem_o.alu_result;
    exec_i.ctrl_mem_wb          <= mem_o.ctrl_mem_wb;

    execute0 : execute GENERIC MAP
    (
        G_USE_HW_MUL => CFG_USE_HW_MUL,
        G_USE_BARREL => CFG_USE_BARREL
    )
    PORT MAP
    (
        exec_o => exec_o,
        exec_i => exec_i,
        ena_i  => ena_i,
        rst_i  => rst_i,
        clk_i  => clk_i
    );

    mem_i.alu_result      <= exec_o.alu_result;
    mem_i.program_counter <= exec_o.program_counter;
    mem_i.branch          <= exec_o.branch;
    mem_i.dat_d           <= exec_o.dat_d;
    mem_i.ctrl_wb         <= exec_o.ctrl_wb;
    mem_i.ctrl_mem        <= exec_o.ctrl_mem;
    mem_i.mem_result      <= dmem_dat_i;

    mem0 : mem PORT MAP
    (
        mem_o  => mem_o,
        dmem_dat_o  => dmem_dat_o,
        dmem_adr_o  => dmem_adr_o,
        dmem_sel_o  => dmem_sel_o,
        dmem_we_o  => dmem_we_o,
        dmem_ena_o  => dmem_ena_o,
        mem_i  => mem_i,
        ena_i  => ena_i,
        rst_i  => rst_i,
        clk_i  => clk_i
    );

END arch;
