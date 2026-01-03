----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 11:54:50
-- Design Name: 
-- Module Name: Temporizador_tb - Behavioral
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

--Esta entidad se tendrá que probar en la placa ya que en el tb será practicamente imposible verlo. Debido al alto tiempo de simulacion.

entity Temporizador_tb is
--  Port ( );
end Temporizador_tb;

architecture Behavioral of Temporizador_tb is

    -- Constantes
    constant CLK_PERIOD : time := 10 ns;   -- Periodo del reloj principal (100 MHz)
    constant TIME_1MS : time := 1 ms;    -- Periodo de la base de tiempo (1 kHz)
    constant C_BITS_TB : natural := 16;
    constant T_CORTO : natural := 10000; -- 10 segundos
    constant T_LARGO : natural := 20000; -- 20 segundos

    -- 1. Declaración del Componente 
    component Temporizador
    generic (
        C_BITS : natural := 16
    );
    port (
        CLK : in  std_logic;
        RESET : in  std_logic;
        CLK_1ms : in  std_logic;
        TEMP : in  unsigned(C_BITS-1 downto 0);
        INI_TEMP : in  std_logic;
        FIN_TEMP : out std_logic;
        CUENTA_OUT : out unsigned(C_BITS-1 downto 0)
    );
    end component;

    -- 2. Señales internas
    signal CLK_tb : std_logic := '0';
    signal RESET_tb : std_logic := '0';
    signal CLK_1ms_tb : std_logic := '0';
    signal TEMP_tb : unsigned(C_BITS_TB-1 downto 0) := (others => '0');
    signal INI_TEMP_tb : std_logic := '0';
    signal FIN_TEMP_tb : std_logic;
    signal CUENTA_OUT_tb : unsigned(C_BITS_TB-1 downto 0);

begin

    -- 3. Instanciación del Módulo
    UUT: Temporizador
        generic map (C_BITS => C_BITS_TB)
        port map (
            CLK => CLK_tb,
            RESET => RESET_tb,
            CLK_1ms  => CLK_1ms_tb,
            TEMP  => TEMP_tb,
            INI_TEMP => INI_TEMP_tb,
            FIN_TEMP => FIN_TEMP_tb,
            CUENTA_OUT => CUENTA_OUT_tb
        );

    -- 4. Generador del Reloj Principal
    CLK_GEN: process
    begin
        loop
            CLK_tb <= '0';
            wait for CLK_PERIOD / 2;
            CLK_tb <= '1';
            wait for CLK_PERIOD / 2;  
        end loop;
    end process CLK_GEN;
    
    -- 5. Generador del Pulso de 1 ms (1 kHz)
    CLK_1MS_GEN: process
    begin
        loop
            CLK_1ms_tb <= '1';
            wait for CLK_PERIOD; -- El pulso dura un ciclo de 10 ns
            CLK_1ms_tb <= '0';
            wait for TIME_1MS - CLK_PERIOD; -- Espera el resto del ms (1 ms - 10 ns)
        end loop;
    end process CLK_1MS_GEN;


    -- 6. Proceso Principal de Estímulos
    STIMULUS: process
    begin
        
        -- A. RESET INICIAL
        RESET_tb <= '0'; -- Activar Reset
        wait for 5 * CLK_PERIOD;
        
        RESET_tb <= '1'; -- Desactivar Reset
        wait for 10 * CLK_PERIOD;

        
        -- B. PRUEBA DE CAFÉ CORTO (10 segundos)
        wait until CLK_1ms_tb = '1'; --Se debe alinear con el reloj principal para así cargar el valor en el registro
        --Dado que CLK_1ms solo dura 1 periodo pues tienen que coincidir para que se cargue.
        TEMP_tb <= to_unsigned(T_CORTO, C_BITS_TB); -- Cargamos 10.000 ms
        INI_TEMP_tb <= '1'; -- Disparamos el temporizador (debe ser un pulso de 1 ciclo)
        wait for CLK_PERIOD;
        
        INI_TEMP_tb <= '0'; -- Desactivamos el pulso INI_TEMP
        TEMP_tb <= (others => '0'); --Ponemos a 0 por si acaso
        
        -- Esperamos el tiempo total de la cuenta (10 segundos)
        wait for T_CORTO * TIME_1MS;

        
        wait for 10 * CLK_PERIOD; -- Esperamos un poco

        
        -- C. PRUEBA DE CAFÉ LARGO (20 segundos)
        wait until CLK_1ms_tb = '1'; --Se debe alinear con el reloj principal para así cargar el valor en el registro
        TEMP_tb <= to_unsigned(T_LARGO, C_BITS_TB); -- Cargamos 20000 ms
        INI_TEMP_tb <= '1'; -- Disparamos el temporizador
        wait for CLK_PERIOD;
        
        INI_TEMP_tb <= '0'; -- Desactivamos el pulso INI_TEMP
        TEMP_tb <= (others => '0'); --Ponemos a 0 por si acaso
 
        -- Esperamos el tiempo total de la cuenta (20 segundos)
        wait for T_LARGO * TIME_1MS;
        

        -- D. Fin de la prueba
        wait for 5 * CLK_PERIOD;
        
        wait; 

    end process STIMULUS;

end Behavioral;
