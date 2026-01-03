----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2025 18:59:22
-- Design Name: 
-- Module Name: Clk_Divisor - Behavioral
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
use ieee.numeric_std.all; --Libreria para usar tipos de datos numericos con y sin signo

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--Esta entidad se usará para no tener que contar hasta 1000.000.000 sino hasta 10.000 (más eficiente)
--Es decir cada 1 ms la cosas se ponen en funcionamiento.

entity Clk_Divisor is
    Port ( 
    CLK: in std_logic;
    RESET: in std_logic;
    CLK_1ms: out std_logic --Se elige 1 ms ya que ofrece un equilibrio perfecto
        );
end Clk_Divisor;

architecture Behavioral of Clk_Divisor is

    constant COUNT: integer:=99999; --Contaremos hasta 100.000-1 para que en el siguiente pulso sea 100.000
    signal Contador: unsigned (16 downto 0) :=(others => '0'); --Necesitamos un contador de 17 bits par almacenar hasta 100.000 (2^17)
    --Y usamos un vector de unsigned para así especificar la cantidad de bits que queremos y aprovechar recursos
begin

process(CLK, RESET)
    begin
        if RESET = '0' then
            -- 1. Reset 
            Contador <= (others => '0');
            CLK_1ms <= '0';
            
        elsif rising_edge(CLK) then
            -- 2. Lógica de conteo y división
            if Contador = to_unsigned(COUNT, Contador'length) then --Convertimos el valor de COUNT a un vector unsigned de 17 bits
                -- A. 1 ms alcanzado
                Contador <= (others => '0'); -- Reiniciar contador
                CLK_1ms <= '1'; -- Generar el pulso de 1ms
            else
                -- B. Conteo
                Contador <= Contador + 1;
                CLK_1ms <= '0'; -- Mantener el pulso bajo hasta el siguiente milisegundo
            end if;
        end if;
    end process;

end Behavioral;
