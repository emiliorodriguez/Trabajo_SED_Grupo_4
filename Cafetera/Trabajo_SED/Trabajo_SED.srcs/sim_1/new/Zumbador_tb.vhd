----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2025 10:45:26
-- Design Name: 
-- Module Name: Zumbador_tb - Behavioral
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

entity Zumbador_tb is
--  Port ( );
end Zumbador_tb;

architecture Behavioral of Zumbador_tb is

    -- 1. Declaramos el componente
    component Zumbador
    Port (
        CLK  : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
        ENABLE : in  STD_LOGIC;
        AUDIO_PWM: out STD_LOGIC;
        AUDIO_SD : out STD_LOGIC
    );
    end component;

    -- 2. Señales internas
    signal CLK_tb : std_logic := '0';
    signal RESET_tb : std_logic := '0';
    signal ENABLE_tb : std_logic := '0';
    signal AUDIO_PWM_tb: std_logic;
    signal AUDIO_SD_tb : std_logic;
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Instanciamos el Zumbador
    UUT: Zumbador
    port map (
        CLK => CLK_tb,
        RESET => RESET_tb,
        ENABLE => ENABLE_tb,
        AUDIO_PWM => AUDIO_PWM_tb,
        AUDIO_SD  => AUDIO_SD_tb
    );

    -- 4. Generador de Reloj
    CLK_PROCESS: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD / 2;
        CLK_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 5. Proceso de Estímulos
    STIM_PROCESS: process
    begin
        -- A. Reset Inicial
        RESET_tb <= '0';
        ENABLE_tb <= '0';
        wait for 100 ns;
        
        RESET_tb <= '1'; -- Soltamos el reset
        wait for 100 ns;


        -- B. Prueba de encendido
        
        -- Activamos el zumbador
        ENABLE_tb <= '1';
        wait for 3 ms; -- Para ver al menos 3 ondas completas, esperamos 3 ms.


        -- C. Prueba de apagado 
        ENABLE_tb <= '0';
        wait for 1 ms;

        -- D. Fin de la simulación
        wait;
    end process;
    
end Behavioral;
