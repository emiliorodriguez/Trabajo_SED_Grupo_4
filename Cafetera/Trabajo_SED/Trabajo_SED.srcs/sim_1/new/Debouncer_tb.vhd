----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 16:22:59
-- Design Name: 
-- Module Name: Debouncer_tb - Behavioral
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

entity Debouncer_tb is
--  Port ( );
end Debouncer_tb;

architecture Behavioral of Debouncer_tb is

    -- Constantes de Tiempo
    constant CLK_PERIOD : time := 10 ns;   -- Periodo del reloj principal (100 MHz)
    constant TIME_1MS : time := 1 ms;    -- Base de tiempo para la cuenta (1 kHz)
    constant T_HOLD : time := 20 ms;   -- Tiempo de confirmación (20 ms)
    constant COUNT_BITS_TB : natural := 5;    -- Ancho del contador para la simulacion
    
    -- 1. Declaración del Componente
    component Debouncer
        generic (
            HOLD_TIME : natural := 20; 
            COUNT_BITS   : natural := 5 
        );
        Port (
            CLK : in  std_logic;
            RESET : in  std_logic;
            CLK_1ms : in  std_logic;
            SYNC_IN : in  std_logic;       
            BTN_LIMPIO : out std_logic   
        );
    end component;

    -- 2. Señales internas para conectar
    signal CLK_tb : std_logic := '0';
    signal RESET_tb : std_logic := '0';
    signal CLK_1ms_tb : std_logic := '0';
    signal SYNC_IN_tb : std_logic := '0';
    signal BTN_LIMPIO_tb : std_logic;

begin

    -- 3. Instanciación del Módulo (UUT)
    UUT: Debouncer
        generic map (HOLD_TIME => 20, COUNT_BITS => COUNT_BITS_TB)
        port map (
            CLK        => CLK_tb,
            RESET      => RESET_tb,
            CLK_1ms    => CLK_1ms_tb,
            SYNC_IN    => SYNC_IN_tb,
            BTN_LIMPIO => BTN_LIMPIO_tb
        );

    -- 4. Generador del Reloj Principal (100 MHz)
    CLK_GEN: process
    begin
        loop
            CLK_tb <= '0';
            wait for CLK_PERIOD / 2;
            CLK_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process CLK_GEN;

    -- 5. Generador del Pulso de 1 ms (Simula el Clk_Divisor)
    CLK_1MS_GEN: process
    begin
        loop
            CLK_1ms_tb <= '1';
            wait for CLK_PERIOD; 
            CLK_1ms_tb <= '0';
            wait for TIME_1MS - CLK_PERIOD;
        end loop;
    end process CLK_1MS_GEN;
    
    -- 6. Proceso Principal de Estímulos (Prueba de Antirrebote)
    STIMULUS: process
    begin
        
        --A. FASE INICIAL
        RESET_tb <= '0'; 
        SYNC_IN_tb <= '0'; 
        wait for 5 * CLK_PERIOD;
        
        RESET_tb <= '1'; -- Desactivar Reset
        wait for 10 * CLK_PERIOD;


        --B. PRUEBA DE REBOTE AL PULSAR
        SYNC_IN_tb <= '1'; -- Pulsamos el botón
        wait for 10 * TIME_1MS; -- Mantenemos el pulso por 10 ms (Menos que 20 ms)
        
        SYNC_IN_tb <= '0'; -- El botón vuelve a 0 (El rebote no fue válido)
        wait for 5 * CLK_PERIOD;


        --C. PULSACIÓN VÁLIDA
        SYNC_IN_tb <= '1'; -- Pulsamos el botón
        wait for T_HOLD + 5 * TIME_1MS; -- Esperamos 25 ms (20 ms de confirmación + 5 ms de margen)
        

        --D. PRUEBA DE REBOTE AL SOLTAR
        SYNC_IN_tb <= '0'; -- Soltamos el botón, pero por 5ms (Rebote no válido)
        wait for 5 * TIME_1MS;
        
        SYNC_IN_tb <= '1'; -- El contacto rebota y vuelve a activarse
        wait for 5 * CLK_PERIOD;
        
        
        --E. SOLTAR VÁLIDO
        SYNC_IN_tb <= '0'; -- Soltamos el botón por un tiempo largo
        wait for 30 * TIME_1MS;
        
        --F. Fin
        wait for 10 * CLK_PERIOD;
        wait; 

    end process STIMULUS;
end Behavioral;
