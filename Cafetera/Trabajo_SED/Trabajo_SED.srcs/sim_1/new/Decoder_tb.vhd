----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 19:05:20
-- Design Name: 
-- Module Name: Decoder_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Decoder_tb is
--  Port ( );
end Decoder_tb;

architecture Behavioral of Decoder_tb is

    COMPONENT Decoder
        Port(
            CODE: in std_logic_vector(3 downto 0);
            LED: out std_logic_vector(6 downto 0)
            );
    end COMPONENT;
    
    signal CODE_tb: std_logic_vector(3 downto 0);
    signal LED_tb: std_logic_vector(6 downto 0);
    
    TYPE vtest is record
     code : std_logic_vector(3 DOWNTO 0);
     led : std_logic_vector(6 DOWNTO 0);
    END RECORD;
    
    TYPE vtest_vector IS ARRAY (natural RANGE <>) OF vtest;
    
    CONSTANT test: vtest_vector := (
            (code => "0000", led => "0000001"),
            (code => "0001", led => "1001111"),
            (code => "0010", led => "0010010"),
            (code => "0011", led => "0000110"),
            (code => "0100", led => "1001100"),
            (code => "0101", led => "0100100"),
            (code => "0110", led => "0100000"),
            (code => "0111", led => "0001111"),
            (code => "1000", led => "0000000"),
            (code => "1001", led => "0000100"),
            (code => "1010", led => "1111110"),
            (code => "1011", led => "1111110"),
            (code => "1100", led => "1111110"),
            (code => "1101", led => "1111110"),
            (code => "1110", led => "1111110"),
            (code => "1111", led => "1111110")
                                    );   
    
    
begin

    UUT: Decoder PORT MAP(
        CODE => CODE_tb,
        LED => LED_tb
        );
    Stimulus: PROCESS
    BEGIN
        FOR i IN 0 TO test'HIGH LOOP
            CODE_tb <= test(i).code;
            WAIT FOR 20 ns;
            ASSERT LED_tb = test(i).led
                REPORT "Salida incorrecta."
                SEVERITY FAILURE;
        END LOOP;
        
        ASSERT false
            REPORT "Simulacin finalizada. Test superado."
            SEVERITY FAILURE;
    END PROCESS;

end Behavioral;
