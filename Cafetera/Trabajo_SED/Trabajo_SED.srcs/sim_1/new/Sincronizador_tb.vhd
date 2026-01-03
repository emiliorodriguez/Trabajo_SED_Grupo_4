----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2025 16:43:00
-- Design Name: 
-- Module Name: Sincronizador_tb - Behavioral
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

entity Sincronizador_tb is
--En los tb no ponemos nada aquí
end Sincronizador_tb;


architecture Behavioral of Sincronizador_tb is
    --1. Declaramos la estructura que tiene el chip
    component Sincronizador --Usamos component para avisar de la estructura que tendrá el chip
    Port(
        CLK: in std_logic;
        RESET: in std_logic;
        ASYNC_IN: in std_logic;
        SYNC_OUT: out std_logic
        );
     end component;
     
     -- 2. Señales internas para conectar al componente
    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '0';
    signal async_in_tb : std_logic := '0';
    signal sync_out_tb : std_logic;

    -- 3. Constante para el periodo del reloj (10 ns = 100 MHz)
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- 4. Instanciamos el diseño
    UUT: Sincronizador port map (
        CLK      => clk_tb,
        RESET    => reset_tb,
        ASYNC_IN => async_in_tb,
        SYNC_OUT => sync_out_tb
    );

    -- 5. Proceso de generación del Reloj
    CLK_GEN : process --process no tiene nada ya qye usamos wait
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 6. Proceso de Estímulos
    STIMULUS : process
    begin
        -- Estado inicial
        reset_tb <= '0';
        async_in_tb <= '0';
        wait for 50 ns;
        
        reset_tb <= '1';
        wait for 20 ns;


        -- CASO 1: Pulsación larga
        -- Esperamos un tiempo que no es múltiplo de 10ns (ej: 13ns) para simular que pulsamos el botón entre dos flancos de reloj.
        wait for 3 ns; 
        async_in_tb <= '1';  -- Pulsamos
        wait for 42 ns;  -- Mantenemos pulsado un rato raro
        async_in_tb <= '0';  -- Soltamos


        -- CASO 2: Pulsación rápida
        wait for 20 ns;
        async_in_tb <= '1';  --Pulsamos
        wait for 12 ns;  -- Mantenemos pulsado un poco tiempo
        async_in_tb <= '0';  -- Soltamos
        
        
        -- CASO 3: Pulsación reset
        async_in_tb <= '1';
        wait for 10 ns;
        async_in_tb <= '0';
        wait for 10 ns;
        reset_tb <= '0';
        wait for 10 ns;
        reset_tb <= '1';
        
        wait for 50 ns;


        -- Fin de la prueba
        wait;--Para no repetir la prueba hasta el infinito
    end process;

end Behavioral;
