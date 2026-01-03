----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2025 17:21:33
-- Design Name: 
-- Module Name: DetectFlanco - Behavioral
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

entity DetectFlanco is
    Port ( 
        CLK: in std_logic;  --Reloj
        RESET: in std_logic; --Reset
        SYNC_IN: in std_logic; --Señal síncrona
        EDGE: out std_logic --Flanco detectado
            );
end DetectFlanco;

architecture Behavioral of DetectFlanco is

    signal sreg: std_logic_vector (2 downto 0):="000"; --Inicializamos a 0
 
begin
    process(clk)
        begin
            if RESET = '0' then --Si ocurre reset ponemos todo a 0
                sreg <= "000"; --No ponemos EDGE a 0 porque es una salida combinacional
            elsif rising_edge(CLK) then
                sreg<=sreg(1 downto 0) & SYNC_IN; --Desplazamos un bit a la izquierda todo
            end if;
    end process;
    
with sreg select --Forma elegante de escribir tablas de verdad
    EDGE <= '1' when "011", --Cuando tengamos esa combinacion en sreg entonces habrá un cambio de estado. (Al dejar de pulsar se activa)
    '0' when others; 
end Behavioral;
