----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2025 20:25:43
-- Design Name: 
-- Module Name: Temporizador - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Temporizador is
generic (
        -- El contador es de 16 bits para llegar hasta 65535 (65.5s)
        C_BITS : natural := 16 --Con esto cubrimos los 60s máximos.
    );
    port (
        CLK : in  std_logic; -- Reloj principal (100 MHz)
        RESET : in  std_logic; -- Reset asíncrono
        CLK_1ms : in  std_logic; -- Pulso habilitador de 1 ms (del Clk_Divisor)
        TEMP : in  unsigned(C_BITS-1 downto 0); -- Valor en ms de la cuenta 
        INI_TEMP : in  std_logic;  -- Pulso para iniciar la cuenta
        FIN_TEMP : out std_logic; -- Pulso al finalizar la cuenta
        CUENTA_OUT : out unsigned(C_BITS-1 downto 0) -- Salida del valor actual en milisegundos
    );
end Temporizador;

architecture Behavioral of Temporizador is

    signal Reg_Contador : unsigned(C_BITS-1 downto 0) := (others => '0');

begin
    process(CLK, RESET)
    begin
        if RESET = '0' then
            Reg_Contador <= (others => '0');
            
        elsif rising_edge(Clk) then 
                
                -- A. Cargamos tiempo (Fuera del CLK_1ms para que no se tenga que cargar justo en ese ms)
                if INI_TEMP = '1' then
                    Reg_Contador <= TEMP; --Cargamos el valor de tiempo elegido

                -- B. Contamos tiempo (De forma regresiva)
                elsif CLK_1ms = '1' then
                    if Reg_Contador > 0 then
                        Reg_Contador <= Reg_Contador - 1;
                    end if;
                    
                end if;
        
        end if;
    end process;
    
    FIN_TEMP <= '1' when (Reg_Contador = 0 and INI_TEMP = '0') else '0';--Importante fuera del process para actualizar lo más rápido posible
    CUENTA_OUT <= Reg_Contador;--Obtenemos los milisengundos que quedan todo el rato

end Behavioral;
