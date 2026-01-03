----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2025 19:23:45
-- Design Name: 
-- Module Name: Clk_Divisor_tb - Behavioral
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

entity Clk_Divisor_tb is
--  Port ( );
end Clk_Divisor_tb;

architecture Behavioral of Clk_Divisor_tb is

    -- 1. Declaración de Componente
    component Clk_Divisor
        port (
            CLK : in  std_logic;
            RESET : in  std_logic;
            CLK_1ms : out std_logic
        );
    end component;

    -- 2. Declaración de Señales
    signal Clk_tb      : std_logic := '0';
    signal Reset_tb  : std_logic := '0'; -- Inicialmente activo (Reset)
    signal Clk_1ms_tb  : std_logic;
    
    -- 3. Definición de Constantes
    constant CLK_PERIOD : time := 10 ns; -- Reloj de la FPGA: 100 MHz -> Periodo = 10 ns
    constant TIME_1MS   : time := 1 ms;-- 1 milisegundo = 100.000 ciclos de 10ns

begin

-- 4. Instanciación del Módulo 
    UUT: Clk_Divisor
        port map (
            CLK     => Clk_tb,
            RESET => Reset_tb,
            CLK_1ms => Clk_1ms_tb
        );

    -- 5. Generación del Reloj
    CLK_GEN: process
    begin
        loop
            Clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            Clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process CLK_GEN;

    -- 6. Proceso Principal de Estímulos (STIMULUS)
    STIMULUS: process
    begin
        -- A. RESET 
        Reset_tb <= '0'; -- Pulsamos el reset para inicializar
        wait for 2 * CLK_PERIOD; 

        -- B. OPERACION NORMAL 
        Reset_tb <= '1'; -- Desactivamos Reset
        
        -- C. Verificamos el primer pulso (debe ocurrir en 1 ms)
        wait for TIME_1MS; 
        
        -- D. Verificamos el segundo pulso (debe ocurrir en 2 ms)
        wait for TIME_1MS;

        -- E. Dejamos correr la simulación un poco más
        wait for 10 * TIME_1MS;
        
-- Se añadirá en Tcl Console 5 ms para no tener que cambiar la configuración del tiempo general de simulación.
        wait; 
    end process STIMULUS;

end Behavioral;
