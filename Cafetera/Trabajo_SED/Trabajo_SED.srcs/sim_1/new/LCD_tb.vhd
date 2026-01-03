----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 16:50:27
-- Design Name: 
-- Module Name: LCD_tb - Behavioral
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

entity LCD_tb is
--  Port ( );
end LCD_tb;

architecture Behavioral of LCD_tb is

-- Constantes de Tiempo
    constant CLK_PERIOD     : time := 10 ns;   -- Periodo del reloj principal (100 MHz)
    constant TIME_1MS       : time := 1 ms;    -- Pulso de 1 ms
    constant T_WAIT_INIT    : time := 40 ms;   -- Tiempo de espera inicial para el LCD
    
    -- Constantes del LCD
    constant C_STATE_BITS_TB : natural := 2; -- 2 bits para codificar 4 estados
    constant CMD_APAGADO     : std_logic_vector(1 downto 0) := "00";
    constant CMD_ESPERA      : std_logic_vector(1 downto 0) := "01";

    -- 1. Declaración del Componente
    component LCD_Controller
        generic (
            C_STATE_BITS : natural := 2
        );
        Port (
            CLK           : in  std_logic;
            RESET_n       : in  std_logic;
            CLK_1ms       : in  std_logic;
            CMD_ESTADO    : in  std_logic_vector(C_STATE_BITS-1 downto 0);
            NUEVO_MENSAJE : in  std_logic;
            LCD_RS        : out std_logic;
            LCD_E         : out std_logic;
            LCD_Data      : out std_logic_vector(3 downto 0)
        );
    end component;

    -- 2. Señales internas para conectar
    signal CLK_tb          : std_logic := '0';
    signal RESET_n_tb      : std_logic := '0'; -- Inicialmente activo bajo
    signal CLK_1ms_tb      : std_logic := '0';
    signal CMD_ESTADO_tb   : std_logic_vector(C_STATE_BITS_TB-1 downto 0) := (others => '0');
    signal NUEVO_MENSAJE_tb: std_logic := '0';
    signal LCD_RS_tb       : std_logic;
    signal LCD_E_tb        : std_logic;
    signal LCD_Data_tb     : std_logic_vector(3 downto 0);

begin

    -- 3. Instanciación del Módulo (DUT)
    DUT: LCD_Controller
        generic map (C_STATE_BITS => C_STATE_BITS_TB)
        port map (
            CLK           => CLK_tb,
            RESET_n       => RESET_n_tb,
            CLK_1ms       => CLK_1ms_tb,
            CMD_ESTADO    => CMD_ESTADO_tb,
            NUEVO_MENSAJE => NUEVO_MENSAJE_tb,
            LCD_RS        => LCD_RS_tb,
            LCD_E         => LCD_E_tb,
            LCD_Data      => LCD_Data_tb
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


    -- 6. Proceso Principal de Estímulos (Prueba de Secuencia)
    STIMULUS: process
    begin
        
        -- *** FASE 1: RESET y Espera de Inicialización ***
        report "FASE 1: Inicializando el sistema y LCD. (Estado: ST_RESET_WAIT)" severity note;
        RESET_n_tb <= '0'; -- Reset activo
        CMD_ESTADO_tb <= CMD_APAGADO; -- Estado inicial de la cafetera
        wait for 5 * CLK_PERIOD;
        
        RESET_n_tb <= '1'; -- Desactivar Reset (El LCD entra en ST_RESET_WAIT)

        -- Esperar el tiempo de inicialización de 40ms. El LCD_Controller debe pasar a ST_INIT_SEQ y luego a ST_IDLE.
        wait for T_WAIT_INIT + 5 * TIME_1MS; 
        report "OK: 40ms de espera completados. El LCD debe estar en ST_IDLE." severity note;
        
        -- Verificar que el LCD ha enviado comandos (LCD_RS=0) y está en IDLE (asumiendo que los comandos de init se hicieron)
        
        
        -- *** FASE 2: PRUEBA DE ESCRITURA (De APAGADO a ESPERA) ***
        report "FASE 2: Enviando comando para cambiar a ESTADO ESPERA." severity note;
        
        -- 1. FSM cambia el estado de la cafetera
        CMD_ESTADO_tb <= CMD_ESPERA; 
        
        -- 2. FSM envía el pulso NUEVO_MENSAJE
        NUEVO_MENSAJE_tb <= '1';
        wait for CLK_PERIOD;
        NUEVO_MENSAJE_tb <= '0';
        
        -- El LCD debe estar ahora en ST_WRITE_MSG y limpiando/escribiendo.
        
        -- 3. Esperamos el tiempo suficiente para que se escriban los 16 caracteres.
        -- Cada caracter son 2 pulsos de Enable, más los comandos de limpiar.
        -- Esto requiere al menos 32-40 pulsos. Esperamos un margen de tiempo amplio (ej: 1 ms * 50 pulsos = 50ms).
        wait for 50 * TIME_1MS;
        report "OK: Escritura de mensaje 'ESPERA' completada. LCD debe volver a ST_IDLE." severity note;
        
        
        -- *** FASE 3: PRUEBA DE ESCRITURA (De ESPERA a CORTO) ***
        report "FASE 3: Enviando comando para cambiar a PREP. CORTO (CMD 10)." severity note;
        CMD_ESTADO_tb <= "10";
        NUEVO_MENSAJE_tb <= '1';
        wait for CLK_PERIOD;
        NUEVO_MENSAJE_tb <= '0';

        wait for 50 * TIME_1MS;
        report "OK: Escritura de mensaje 'PREP. CORTO' completada." severity note;


        -- *** FASE 4: Fin de la prueba ***
        wait for 10 * CLK_PERIOD;
        assert false report "Fin de la simulacion del Controlador LCD" severity failure;
        wait; 

    end process STIMULUS;


end Behavioral;
