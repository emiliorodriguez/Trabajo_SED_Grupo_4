----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2025 16:23:21
-- Design Name: 
-- Module Name: Sincronizador - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Sincronizador is
    Port(
        CLK: in std_logic;  --Reloj
        RESET: in std_logic; --Reset
        ASYNC_IN: in std_logic; --Señal asíncrona
        SYNC_OUT: out std_logic --Señal síncrona
        );
end Sincronizador;

--Cuando haya un flanco de reloj la señal sincrona será la de SYNC_OUT y luego se desplazarán los bits de sreg a la izquierda.
--Con estos nos aseguramos de que todo vaya de forma síncrona. Es decir a la sincronía del reloj.

architecture Behavioral of Sincronizador is
    signal sreg: std_logic_vector (1 downto 0):="00";   --Inicializamos a 0
begin
    process (CLK)
    begin
        if RESET = '0' then -- Lógica de Reset
            sreg <= "00";
            SYNC_OUT <= '0'; --Esta salida si que es secuencial y por tanto se pone a 0
        elsif rising_edge (CLK) then
            SYNC_OUT<=sreg(1);--Durante dos ciclos de reloj no hay pulsacion de boton (Tarda un poco más en procesar la señal de botón)
            sreg<=sreg(0) & ASYNC_IN;   --Desplazamos un bit a la izquiera los bits de sreg
        end if;
   end process;     

end Behavioral;
