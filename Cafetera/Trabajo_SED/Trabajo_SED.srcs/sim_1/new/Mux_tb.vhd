----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 22:31:04
-- Design Name: 
-- Module Name: Mux_tb - Behavioral
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

entity Mux_tb is
--  Port ( );
end Mux_tb;

architecture Behavioral of Mux_tb is

    constant CLK_PERIOD : time := 10 ns;   -- Reloj principal (100 MHz)
    constant T_ALTERNANCIA : time := 5 ms;    -- Tiempo que cada digito esta encendido (5 ms)
    

    -- 1. Declaración del Componente
    component Mux
    Port (
        SEG_DECENA_IN : in  STD_LOGIC_VECTOR (6 downto 0);
        SEG_UNIDAD_IN : in  STD_LOGIC_VECTOR (6 downto 0);
        CLK : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
        SEG_OUT : out STD_LOGIC_VECTOR (6 downto 0);
        HAB_DECENA : out STD_LOGIC;
        HAB_UNIDAD : out STD_LOGIC
    );
    end component;

    -- 2. Señales internas para conectar
    signal CLK_tb : std_logic := '0';
    signal RESET_tb : std_logic := '0';
    signal SEG_DECENA_tb : STD_LOGIC_VECTOR (6 downto 0):="1001111";
    signal SEG_UNIDAD_tb : STD_LOGIC_VECTOR (6 downto 0):="0000001";
    signal SEG_OUT_tb : STD_LOGIC_VECTOR (6 downto 0);
    signal HAB_DECENA_tb : std_logic;
    signal HAB_UNIDAD_tb : std_logic;

begin

    -- 3. Instanciación del Módulo
    UUT: Mux
        port map (
            SEG_DECENA_IN => SEG_DECENA_tb,
            SEG_UNIDAD_IN => SEG_UNIDAD_tb,
            CLK => CLK_tb,
            RESET => RESET_tb,
            SEG_OUT => SEG_OUT_tb,
            HAB_DECENA => HAB_DECENA_tb,
            HAB_UNIDAD => HAB_UNIDAD_tb
        );

    -- 4. Generador del Reloj 
    CLK_GEN: process
    begin
        loop
            CLK_tb <= '0';
            wait for CLK_PERIOD / 2;
            CLK_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process CLK_GEN;


    -- 5. Proceso Principal de Estímulos
    STIMULUS: process
    begin
        
        -- A. RESET INICIAL 
        RESET_tb <= '0'; 
        wait for 5 * CLK_PERIOD;
        
        RESET_tb <= '1'; -- Desactivar Reset
        wait for 10 * CLK_PERIOD;


        -- B. PRIMER CICLO - DECENA
        -- Esperar el tiempo de alternancia (5 ms)
        wait for T_ALTERNANCIA; 
        -- Verificación 1: Decena (0 a 5 ms)


        -- C. SEGUNDO CICLO - UNIDAD
        -- Esperar el segundo tiempo de alternancia (5 ms adicionales)
        wait for T_ALTERNANCIA; 
        -- Verificación 2: Unidad (5 ms a 10 ms)
        

        -- D. Fin de la prueba
        wait for 10 * CLK_PERIOD;
        wait; 
    end process STIMULUS;


end Behavioral;
