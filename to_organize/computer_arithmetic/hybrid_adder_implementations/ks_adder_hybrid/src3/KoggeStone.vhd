LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


ENTITY KoggeStone is
    PORT( 
				CLOCK : IN STD_LOGIC;
				X : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				Y : IN STD_LOGIC_VECTOR (31 downto 0);
				S : OUT STD_LOGIC_VECTOR (31 downto 0);
				MUX_SEL : IN STD_LOGIC;
				Save_Pin : IN STD_LOGIC;
				Cin : IN STD_LOGIC;
				Cout : OUT STD_LOGIC
			);
END KoggeStone;

ARCHITECTURE ks_arch OF KoggeStone IS
SIGNAL g_in : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL p_in : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L1 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L1 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L2 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L2 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L3 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L3 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L4 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L4 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L5 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L5 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L6 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L6 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L7 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L7 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL gout_L8 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL pout_L8 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL Carry_Box_Out : STD_LOGIC_VECTOR(256 DOWNTO 1);
SIGNAL pout_L8_Pick : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL Cin_Test : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL CinTemp : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L1 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L1 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L2 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L2 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L3 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L3 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L4 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L4 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L5 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L5 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L6 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L6 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L7 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L7 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_gout_L8 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL REG_pout_L8 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL SIPOX_OUT : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL SIPOY_OUT : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL PISOS_IN : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL CircuittoCoutReg : STD_LOGIC;
SIGNAL CinRegtoCircuit : STD_LOGIC;

BEGIN
--Find Gi, Pi to enter to the parallel prefix network!
g_in <= SIPOX_OUT AND SIPOY_OUT;
p_in <= SIPOX_OUT XOR SIPOY_OUT;
--Cin_Test <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & Cin;
--test_sum <= X + Y;-- + Cin_Test;
--test_sig <= gout_L8;
--ci+1 = g[0,i] + c0 p[0,i]
--WITH Cin SELECT
--CinTemp <= (OTHERS => '0') WHEN '0',
--			  (OTHERs => '1') WHEN OTHERS;
WITH CinRegtoCircuit SELECT
pout_L8_Pick <= REG_pout_L8 WHEN '1',
					 (OTHERS=>'0') WHEN OTHERS;
--Carry_Box_Out <= gout_L8 OR (CinTemp AND pout_L8);
Carry_Box_Out <= REG_gout_L8 OR pout_L8_Pick;

CircuittoCoutReg <= Carry_Box_Out(256);
--si = pi XOR ci 
PISOS_IN(0) <= CinRegtoCircuit XOR p_in(0);
--S(255 DOWNTO 1) <= Carry_Box_Out(254 DOWNTO 0) XOR pout_L8(255 DOWNTO 1);
PISOS_IN(255 DOWNTO 1) <= Carry_Box_Out(255 DOWNTO 1) XOR p_in(255 DOWNTO 1);

Save_p_in : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>p_in,Q=>p_in_to_XOR,ENABLE=>Save_Pin,RESET=>'0',CLOCK=>CLOCK);
CinReg : ENTITY work.REG3(reg3_arch)
			PORT MAP(D=>Cin,Q=>CinRegtoCircuit,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
			
CoutReg : ENTITY work.REG3(reg3_arch)
			 PORT MAP(D=>CircuittoCoutReg,Q=>Cout,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
			
--Define registers for pipelining
--Low on time, so reset and enable signals will be simplified
REG1g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L1,Q=>REG_gout_L1,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG1p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L1,Q=>REG_pout_L1,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

REG2g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L2,Q=>REG_gout_L2,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG2p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L2,Q=>REG_pout_L2,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

REG3g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L3,Q=>REG_gout_L3,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG3p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L3,Q=>REG_pout_L3,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

REG4g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L4,Q=>REG_gout_L4,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG4p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L4,Q=>REG_pout_L4,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

REG5g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L5,Q=>REG_gout_L5,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG5p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L5,Q=>REG_pout_L5,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

REG6g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L6,Q=>REG_gout_L6,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG6p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L6,Q=>REG_pout_L6,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

REG7g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L7,Q=>REG_gout_L7,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG7p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L7,Q=>REG_pout_L7,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

REG8g : ENTITY work.REG(reg_arch)
		 PORT MAP(D=>gout_L8,Q=>REG_gout_L8,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);
REG8p : ENTITY work.REG(reg_arch)
		  PORT MAP(D=>pout_L8,Q=>REG_pout_L8,ENABLE=>'1',RESET=>'0',CLOCK=>CLOCK);

SIPOX : ENTITY work.SIPO(sipo_arch)
		 PORT MAP(Clk=>CLOCK,Input=>X,ENABLE=>'1',RESET=>'0',Output=>SIPOX_OUT);

SIPOY : ENTITY work.SIPO(sipo_arch)
		 PORT MAP(Clk=>CLOCK,Input=>Y,ENABLE=>'1',RESET=>'0',Output=>SIPOY_OUT);

PISOS : ENTITY work.PISO(piso_arch)
		 PORT MAP(Clk=>CLOCK,Input=>PISOS_IN,ENABLE=>'1',RESET=>'0',Output=>S,MUX_SEL=>MUX_SEL);



--LEVEL 1
gout_L1(0) <= g_in(0);
pout_L1(0) <= p_in(0);
--REG_gout_L1(0) <= gout_L1(0);
--REG_pout_L1(0) <= pout_L1(0);
GENL1: FOR i IN 1 TO 255 GENERATE
	LEVEL1 : ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>g_in(i-1),
						g2_in=>g_in(i),
						p1_in=>p_in(i-1),
						p2_in=>p_in(i),
						g_out=>gout_L1(i),
						p_out=>pout_L1(i)
					);
END GENERATE;

--LEVEL 2
gout_L2(0) <= g_in(0);
gout_L2(1) <= gout_L1(1); 
pout_L2(0) <= p_in(0);
pout_L2(1) <= pout_L1(1);
--REG_gout_L2(1 DOWNTO 0) <= gout_L2(1 DOWNTO 0);
--REG_pout_L2(1 DOWNTO 0) <= pout_L2(1 DOWNTO 0);
LEVEL2a : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>g_in(0),
						g2_in=>REG_gout_L1(2),
						p1_in=>p_in(0),
						p2_in=>REG_pout_L1(2),
						g_out=>gout_L2(2),
						p_out=>pout_L2(2)
					);

GENL2: FOR i IN 3 TO 255 GENERATE
	LEVEL2: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L1(i-2),
						g2_in=>REG_gout_L1(i),
						p1_in=>REG_pout_L1(i-2),
						p2_in=>REG_pout_L1(i),
						g_out=>gout_L2(i),
						p_out=>pout_L2(i)
					);
END GENERATE;


--LEVEL 3
gout_L3(0) <= g_in(0);
pout_L3(0) <= p_in(0);
gout_L3(1) <= gout_L1(1);
pout_L3(1) <= pout_L1(1);
gout_L3(3 DOWNTO 2) <= gout_L2(3 DOWNTO 2);
pout_L3(3 DOWNTO 2) <= pout_L2(3 DOWNTO 2);
--REG_gout_L3(3 DOWNTO 0) <= gout_L3(3 DOWNTO 0);
--REG_pout_L3(3 DOWNTO 0) <= pout_L3(3 DOWNTO 0);
LEVEL3a : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>g_in(0),
						g2_in=>REG_gout_L2(4),
						p1_in=>p_in(0),
						p2_in=>REG_pout_L2(4),
						g_out=>gout_L3(4),
						p_out=>pout_L3(4)
					);


LEVEL3b : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>REG_gout_L1(1),
						g2_in=>REG_gout_L2(5),
						p1_in=>REG_pout_L1(1),
						p2_in=>REG_pout_L2(5),
						g_out=>gout_L3(5),
						p_out=>pout_L3(5)
					);

GENL3: FOR i IN 6 TO 255 GENERATE
	LEVEL3: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L2(i-4),
						g2_in=>REG_gout_L2(i),
						p1_in=>REG_pout_L2(i-4),
						p2_in=>REG_pout_L2(i),
						g_out=>gout_L3(i),
						p_out=>pout_L3(i)
					);
END GENERATE;


--LEVEL 4
pout_L4(7 DOWNTO 4) <= pout_L3(7 DOWNTO 4);
gout_L4(7 DOWNTO 4) <= gout_L3(7 DOWNTO 4);
pout_L4(3 DOWNTO 2) <= pout_L2(3 DOWNTO 2);
gout_L4(3 DOWNTO 2) <= gout_L2(3 DOWNTO 2);
pout_L4(1) <= pout_L1(1);
gout_L4(1) <= gout_L1(1);
pout_L4(0) <= p_in(0);
gout_L4(0) <= g_in(0);
--REG_gout_L4(7 DOWNTO 0) <= gout_L4(7 DOWNTO 0);
--REG_pout_L4(7 DOWNTO 0) <= pout_L4(7 DOWNTO 0);

LEVEL4a : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>g_in(0),
						g2_in=>REG_gout_L3(8),
						p1_in=>p_in(0),
						p2_in=>REG_pout_L3(8),
						g_out=>gout_L4(8),
						p_out=>pout_L4(8)
					);

LEVEL4b : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>REG_gout_L1(1),
						g2_in=>REG_gout_L3(9),
						p1_in=>REG_pout_L1(1),
						p2_in=>REG_pout_L3(9),
						g_out=>gout_L4(9),
						p_out=>pout_L4(9)
					);

GENL4a: FOR i IN 10 TO 11 GENERATE
	LEVEL4c: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L2(i-8),
						g2_in=>REG_gout_L3(i),
						p1_in=>REG_pout_L2(i-8),
						p2_in=>REG_pout_L3(i),
						g_out=>gout_L4(i),
						p_out=>pout_L4(i)
					);
END GENERATE;					

GENL4: FOR i IN 12 TO 255 GENERATE
	LEVEL4: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L3(i-8),
						g2_in=>REG_gout_L3(i),
						p1_in=>REG_pout_L3(i-8),
						p2_in=>REG_pout_L3(i),
						g_out=>gout_L4(i),
						p_out=>pout_L4(i)
					);
END GENERATE;


--LEVEL 5
pout_L5(15 DOWNTO 8) <= pout_L4(15 DOWNTO 8);
gout_L5(15 DOWNTO 8) <= gout_L4(15 DOWNTO 8);
pout_L5(7 DOWNTO 4) <= pout_L3(7 DOWNTO 4);
gout_L5(7 DOWNTO 4) <= gout_L3(7 DOWNTO 4);
pout_L5(3 DOWNTO 2) <= pout_L2(3 DOWNTO 2);
gout_L5(3 DOWNTO 2) <= gout_L2(3 DOWNTO 2);
pout_L5(1) <= pout_L1(1);
gout_L5(1) <= gout_L1(1);
pout_L5(0) <= p_in(0);
gout_L5(0) <= g_in(0);
--REG_gout_L5(15 DOWNTO 0) <= gout_L5(15 DOWNTO 0);
--REG_pout_L5(15 DOWNTO 0) <= pout_L5(15 DOWNTO 0);

LEVEL5a : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>g_in(0),
						g2_in=>REG_gout_L4(16),
						p1_in=>p_in(0),
						p2_in=>REG_pout_L4(16),
						g_out=>gout_L5(16),
						p_out=>pout_L5(16)
					);

LEVEL5b : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>REG_gout_L1(1),
						g2_in=>REG_gout_L4(17),
						p1_in=>REG_pout_L1(1),
						p2_in=>REG_pout_L4(17),
						g_out=>gout_L5(17),
						p_out=>pout_L5(17)
					);


GENL5a: FOR i IN 18 TO 19 GENERATE
	LEVEL5c: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L2(i-16),
						g2_in=>REG_gout_L4(i),
						p1_in=>REG_pout_L2(i-16),
						p2_in=>REG_pout_L4(i),
						g_out=>gout_L5(i),
						p_out=>pout_L5(i)
					);
END GENERATE;


GENL5b: FOR i IN 20 TO 23 GENERATE
	LEVEL5d: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L3(i-16),
						g2_in=>REG_gout_L4(i),
						p1_in=>REG_pout_L3(i-16),
						p2_in=>REG_pout_L4(i),
						g_out=>gout_L5(i),
						p_out=>pout_L5(i)
					);
END GENERATE;


GENL5: FOR i IN 24 TO 255 GENERATE
	LEVEL5: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L4(i-16),
						g2_in=>REG_gout_L4(i),
						p1_in=>REG_pout_L4(i-16),
						p2_in=>REG_pout_L4(i),
						g_out=>gout_L5(i),
						p_out=>pout_L5(i)
					);
END GENERATE;



--LEVEL 6
pout_L6(31 DOWNTO 16) <= pout_L4(31 DOWNTO 16);
gout_L6(31 DOWNTO 16) <= gout_L4(31 DOWNTO 16);
pout_L6(15 DOWNTO 8) <= pout_L4(15 DOWNTO 8);
gout_L6(15 DOWNTO 8) <= gout_L4(15 DOWNTO 8);
pout_L6(7 DOWNTO 4) <= pout_L3(7 DOWNTO 4);
gout_L6(7 DOWNTO 4) <= gout_L3(7 DOWNTO 4);
pout_L6(3 DOWNTO 2) <= pout_L2(3 DOWNTO 2);
gout_L6(3 DOWNTO 2) <= gout_L2(3 DOWNTO 2);
pout_L6(1) <= pout_L1(1);
gout_L6(1) <= gout_L1(1);
pout_L6(0) <= p_in(0);
gout_L6(0) <= g_in(0);
--REG_gout_L6(31 DOWNTO 0) <= gout_L6(31 DOWNTO 0);
--REG_pout_L6(31 DOWNTO 0) <= pout_L6(31 DOWNTO 0);

LEVEL6a : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>g_in(0),
						g2_in=>REG_gout_L5(32),
						p1_in=>p_in(0),
						p2_in=>REG_pout_L5(32),
						g_out=>gout_L6(32),
						p_out=>pout_L6(32)
					);

LEVEL6b : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>REG_gout_L1(1),
						g2_in=>REG_gout_L5(33),
						p1_in=>REG_pout_L1(1),
						p2_in=>REG_pout_L5(33),
						g_out=>gout_L6(33),
						p_out=>pout_L6(33)
					);
					

GENL6a: FOR i IN 34 TO 35 GENERATE
	LEVEL6c: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L2(i-32),
						g2_in=>REG_gout_L5(i),
						p1_in=>REG_pout_L2(i-32),
						p2_in=>REG_pout_L5(i),
						g_out=>gout_L6(i),
						p_out=>pout_L6(i)
					);
END GENERATE;

GENL6b: FOR i IN 36 TO 39 GENERATE
	LEVEL6d: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L3(i-32),
						g2_in=>REG_gout_L5(i),
						p1_in=>REG_pout_L3(i-32),
						p2_in=>REG_pout_L5(i),
						g_out=>gout_L6(i),
						p_out=>pout_L6(i)
					);
END GENERATE;

GENL6c: FOR i IN 40 TO 47 GENERATE
	LEVEL6e: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L4(i-32),
						g2_in=>REG_gout_L5(i),
						p1_in=>REG_pout_L4(i-32),
						p2_in=>REG_pout_L5(i),
						g_out=>gout_L6(i),
						p_out=>pout_L6(i)
					);
END GENERATE;

GENL6: FOR i IN 48 TO 255 GENERATE
	LEVEL6: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L5(i-32),
						g2_in=>REG_gout_L5(i),
						p1_in=>REG_pout_L5(i-32),
						p2_in=>REG_pout_L5(i),
						g_out=>gout_L6(i),
						p_out=>pout_L6(i)
					);
END GENERATE;


--LEVEL 7
pout_L7(63 DOWNTO 32) <= pout_L5(63 DOWNTO 32);
gout_L7(63 DOWNTO 32) <= gout_L5(63 DOWNTO 32);
pout_L7(31 DOWNTO 16) <= pout_L4(31 DOWNTO 16);
gout_L7(31 DOWNTO 16) <= gout_L4(31 DOWNTO 16);
pout_L7(15 DOWNTO 8) <= pout_L4(15 DOWNTO 8);
gout_L7(15 DOWNTO 8) <= gout_L4(15 DOWNTO 8);
pout_L7(7 DOWNTO 4) <= pout_L3(7 DOWNTO 4);
gout_L7(7 DOWNTO 4) <= gout_L3(7 DOWNTO 4);
pout_L7(3 DOWNTO 2) <= pout_L2(3 DOWNTO 2);
gout_L7(3 DOWNTO 2) <= gout_L2(3 DOWNTO 2);
pout_L7(1) <= pout_L1(1);
gout_L7(1) <= gout_L1(1);
pout_L7(0) <= p_in(0);
gout_L7(0) <= g_in(0);
--REG_gout_L7(63 DOWNTO 0) <= gout_L7(63 DOWNTO 0);
--REG_pout_L7(63 DOWNTO 0) <= pout_L7(63 DOWNTO 0);

LEVEL7a : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>g_in(0),
						g2_in=>REG_gout_L6(64),
						p1_in=>p_in(0),
						p2_in=>REG_pout_L6(64),
						g_out=>gout_L7(64),
						p_out=>pout_L7(64)
					);
					
LEVEL7b : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>REG_gout_L1(1),
						g2_in=>REG_gout_L6(65),
						p1_in=>REG_pout_L1(1),
						p2_in=>REG_pout_L6(65),
						g_out=>gout_L7(65),
						p_out=>pout_L7(65)
					);

GENL7a: FOR i IN 66 TO 67 GENERATE
	LEVEL7c: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L2(i-64),
						g2_in=>REG_gout_L6(i),
						p1_in=>REG_pout_L2(i-64),
						p2_in=>REG_pout_L6(i),
						g_out=>gout_L7(i),
						p_out=>pout_L7(i)
					);
END GENERATE;					
					

GENL7b: FOR i IN 68 TO 71 GENERATE
	LEVEL7d: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L3(i-64),
						g2_in=>REG_gout_L6(i),
						p1_in=>REG_pout_L3(i-64),
						p2_in=>REG_pout_L6(i),
						g_out=>gout_L7(i),
						p_out=>pout_L7(i)
					);
END GENERATE;					

GENL7c: FOR i IN 72 TO 79 GENERATE
	LEVEL7e: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L4(i-64),
						g2_in=>REG_gout_L6(i),
						p1_in=>REG_pout_L4(i-64),
						p2_in=>REG_gout_L6(i),
						g_out=>gout_L7(i),
						p_out=>pout_L7(i)
					);
END GENERATE;					

GENL7d: FOR i IN 80 TO 95 GENERATE
	LEVEL7f: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L5(i-64),
						g2_in=>REG_gout_L6(i),
						p1_in=>REG_pout_L5(i-64),
						p2_in=>REG_pout_L6(i),
						g_out=>gout_L7(i),
						p_out=>pout_L7(i)
					);
END GENERATE;					

GENL7: FOR i IN 96 TO 255 GENERATE
	LEVEL7: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L6(i-64),
						g2_in=>REG_gout_L6(i),
						p1_in=>REG_pout_L6(i-64),
						p2_in=>REG_pout_L6(i),
						g_out=>gout_L7(i),
						p_out=>pout_L7(i)
					);					
END GENERATE;

--LEVEL 8
pout_L8(127 DOWNTO 64) <= pout_L5(127 DOWNTO 64);
gout_L8(127 DOWNTO 64) <= gout_L5(127 DOWNTO 64);
pout_L8(63 DOWNTO 32) <= pout_L5(63 DOWNTO 32);
gout_L8(63 DOWNTO 32) <= gout_L5(63 DOWNTO 32);
pout_L8(31 DOWNTO 16) <= pout_L4(31 DOWNTO 16);
gout_L8(31 DOWNTO 16) <= gout_L4(31 DOWNTO 16);
pout_L8(15 DOWNTO 8) <= pout_L4(15 DOWNTO 8);
gout_L8(15 DOWNTO 8) <= gout_L4(15 DOWNTO 8);
pout_L8(7 DOWNTO 4) <= pout_L3(7 DOWNTO 4);
gout_L8(7 DOWNTO 4) <= gout_L3(7 DOWNTO 4);
pout_L8(3 DOWNTO 2) <= pout_L2(3 DOWNTO 2);
gout_L8(3 DOWNTO 2) <= gout_L2(3 DOWNTO 2);
pout_L8(1) <= pout_L1(1);
gout_L8(1) <= gout_L1(1);
pout_L8(0) <= p_in(0);
gout_L8(0) <= g_in(0);
LEVEL8a : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>g_in(0),
						g2_in=>REG_gout_L7(128),
						p1_in=>p_in(0),
						p2_in=>REG_pout_L7(128),
						g_out=>gout_L8(128),
						p_out=>pout_L8(128)
					);

LEVEL8b : ENTITY work.C_OP(cop_arch)
	PORT MAP(
						g1_in=>REG_gout_L1(1),
						g2_in=>REG_gout_L7(129),
						p1_in=>REG_pout_L1(1),
						p2_in=>REG_pout_L7(129),
						g_out=>gout_L8(129),
						p_out=>pout_L8(129)
					);					
					

GENL8a: FOR i IN 130 TO 131 GENERATE
	LEVEL8c: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L2(i-128),
						g2_in=>REG_gout_L7(i),
						p1_in=>REG_pout_L2(i-128),
						p2_in=>REG_pout_L7(i),
						g_out=>gout_L8(i),
						p_out=>pout_L8(i)
					);
END GENERATE;

GENL8b: FOR i IN 132 TO 135 GENERATE
	LEVEL8d: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L3(i-128),
						g2_in=>REG_gout_L7(i),
						p1_in=>REG_pout_L3(i-128),
						p2_in=>REG_pout_L7(i),
						g_out=>gout_L8(i),
						p_out=>pout_L8(i)
					);
END GENERATE;

GENL8c: FOR i IN 136 TO 143 GENERATE
	LEVEL8e: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L4(i-128),
						g2_in=>REG_gout_L7(i),
						p1_in=>REG_pout_L4(i-128),
						p2_in=>REG_pout_L7(i),
						g_out=>gout_L8(i),
						p_out=>pout_L8(i)
					);
END GENERATE;

GENL8d: FOR i IN 144 TO 159 GENERATE
	LEVEL8f: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L5(i-128),
						g2_in=>REG_gout_L7(i),
						p1_in=>REG_pout_L5(i-128),
						p2_in=>REG_pout_L7(i),
						g_out=>gout_L8(i),
						p_out=>pout_L8(i)
					);
END GENERATE;

GENL8e: FOR i IN 160 TO 191 GENERATE
	LEVEL8g: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L6(i-128),
						g2_in=>REG_gout_L7(i),
						p1_in=>REG_pout_L6(i-128),
						p2_in=>REG_pout_L7(i),
						g_out=>gout_L8(i),
						p_out=>pout_L8(i)
					);
END GENERATE;

GENL8: FOR i IN 192 TO 255 GENERATE
	LEVEL8: ENTITY work.C_OP(cop_arch)
		PORT MAP(
						g1_in=>REG_gout_L7(i-128),
						g2_in=>REG_gout_L7(i),
						p1_in=>REG_pout_L7(i-128),
						p2_in=>REG_pout_L7(i),
						g_out=>gout_L8(i),
						p_out=>pout_L8(i)
					);
END GENERATE;



END ks_arch;

