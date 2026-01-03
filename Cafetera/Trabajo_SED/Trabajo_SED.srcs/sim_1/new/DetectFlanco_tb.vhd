----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2025 17:39:12
-- Design Name: 
-- Module Name: DetectFlanco_tb - Behavioral
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

entity DetectFlanco_tb is
--  Port ( );
end DetectFlanco_tb;

architecture Behavioral of DetectFlanco_tb is

-- 1. Declaración del Componente
    component DetectFlanco
    Port(
        CLK : in std_logic;
        RESET : in std_logic;
        SYNC_IN : in std_logic;
        EDGE : out std_logic
    );
    end component;

    -- 2. Señales internas
    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '0'; --Reset a 0 significa que se hace reset
    signal sync_in_tb : std_logic := '0'; -- Empezamos con el botón soltado
    signal edge_tb : std_logic;

    -- 3. Constante de Reloj (10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 4. Conexión
    UUT: DetectFlanco port map (
        CLK      => clk_tb,
        RESET    => reset_tb,
        SYNC_IN  => sync_in_tb,
        EDGE     => edge_tb
    );

    -- 5. Generador de Reloj
    CLK_GEN : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 6. Proceso de Estímulos
    STIMULUS : process
    begin
        -- A) ESTADO INICIAL
        reset_tb <= '0'; --Hacemos reset por si acaso
        sync_in_tb <= '0'; -- Imaginamos que el botón está en reposo
        wait for 3 * CLK_PERIOD;   -- Esperamos a que el sistema se estabilice
        
        reset_tb <= '1'; --Desactivamos reset
        wait for 5 * CLK_PERIOD; --Esperamos un tiempo
        
        sync_in_tb <= '1'; --Ponemos la señal a 1
        wait for 5 * CLK_PERIOD; --Esperamos un tiempo


        -- B) PRUEBA DE FLANCO DE BAJADA EN BOTÓN
        sync_in_tb <= '0'; -- Soltamos el botón (Pasamos de 1 a 0)
        wait for 5 * CLK_PERIOD;-- Mantenemos el 0 un rato
        

        -- C) PRUEBA DE SUBIDA
        sync_in_tb <= '1';-- Volvemos a poner a 1
        wait for 5 * CLK_PERIOD;--Mantenemos pulsado un rato


        -- D) PRUEBA DE PULSACIÓN RÁPIDA
        sync_in_tb <= '0'; -- Bajada
        wait for 2 * CLK_PERIOD;
        sync_in_tb <= '1'; -- Subida
        wait for 2 * CLK_PERIOD;
        
        -- E) PRUEBA DE RESET
        sync_in_tb <= '0'; --Desactivamos el boton
        reset_tb <= '0'; --Hacemos reset
        wait for 5 * CLK_PERIOD; --Esperamos un tiempo
        

        -- Fin de la prueba
        wait;
    end process;


end Behavioral;
