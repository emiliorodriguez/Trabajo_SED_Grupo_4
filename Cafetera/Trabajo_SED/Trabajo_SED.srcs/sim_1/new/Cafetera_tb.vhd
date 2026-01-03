----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2025 13:23:56
-- Design Name: 
-- Module Name: Cafetera_tb - Behavioral
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

entity Cafetera_tb is
-- La entidad del testbench siempre está vacía
end Cafetera_tb;

architecture Behavior of Cafetera_tb is

    -- 1. Declaramos el COMPONENTE (Debe ser idéntico a tu Entity Cafetera)
    component Cafetera
        Port(
            CLK           : in STD_LOGIC;
            RESET         : in STD_LOGIC;
            Encender      : in STD_LOGIC;
            Cafe_corto    : in STD_LOGIC;
            Cafe_largo    : in STD_LOGIC;
            
            -- Entradas del Temporizador externo
            Fin_Temp      : in STD_LOGIC;
            Cuenta_Actual : in unsigned(15 downto 0);
            
            -- Salidas
            Bomba_cafe    : out STD_LOGIC;
            Bomba_leche   : out STD_LOGIC;
            Zumbador      : out STD_LOGIC;
            Start_Timer   : out STD_LOGIC;
            Timer         : out unsigned(15 downto 0)
        );
    end component;

    -- 2. Declaramos las SEÑALES para conectar (Cables de simulación)
    signal s_CLK           : STD_LOGIC := '0';
    signal s_RESET         : STD_LOGIC := '0';
    signal s_Encender      : STD_LOGIC := '0';
    signal s_Cafe_corto    : STD_LOGIC := '0';
    signal s_Cafe_largo    : STD_LOGIC := '0';
    
    signal s_Fin_Temp      : STD_LOGIC := '0';
    signal s_Cuenta_Actual : unsigned(15 downto 0) := (others => '0');
    
    signal s_Bomba_cafe    : STD_LOGIC;
    signal s_Bomba_leche   : STD_LOGIC;
    signal s_Zumbador      : STD_LOGIC;
    signal s_Start_Timer   : STD_LOGIC;
    signal s_Timer_Target  : unsigned(15 downto 0);

    -- Constante para el reloj (100 MHz = 10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Instanciamos la Cafetera (UUT: Unit Under Test)
    uut: Cafetera PORT MAP (
        CLK           => s_CLK,
        RESET         => s_RESET,
        Encender      => s_Encender,
        Cafe_corto    => s_Cafe_corto,
        Cafe_largo    => s_Cafe_largo,
        Fin_Temp      => s_Fin_Temp,
        Cuenta_Actual => s_Cuenta_Actual,  -- ¡Aquí estaba tu error antes!
        Bomba_cafe    => s_Bomba_cafe,
        Bomba_leche   => s_Bomba_leche,
        Zumbador      => s_Zumbador,
        Start_Timer   => s_Start_Timer,
        Timer         => s_Timer_Target
    );

    -- 4. Proceso de Generación de RELOJ
    clk_process :process
    begin
        s_CLK <= '0';
        wait for CLK_PERIOD/2;
        s_CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 5. PROCESO MAGICO: "Simulador de Temporizador Externo"
    -- Este proceso actúa como si fuera el circuito temporizador real.
    -- Cuando la cafetera pide "Start", este proceso baja la cuenta y activa Fin.
    timer_simulation : process
    begin
        -- Esperamos a que la cafetera pida arrancar
        wait until s_Start_Timer = '1'; 
        
        -- Simulamos que el temporizador empieza limpio
        s_Fin_Temp <= '0';
        s_Cuenta_Actual <= s_Timer_Target; -- Cargamos el valor (ej. 3000)
        
        wait for CLK_PERIOD; -- Un pequeño retardo
        
        -- Bucle de cuenta atrás (Simulado rápido para no esperar 3000 ciclos reales)
        while s_Cuenta_Actual > 0 loop
            wait for 20 ns; -- Velocidad de simulación
            if s_Cuenta_Actual > 50 then
                s_Cuenta_Actual <= s_Cuenta_Actual - 50; -- Bajamos de 50 en 50 para ir rápido
            else
                s_Cuenta_Actual <= (others => '0'); -- Llegamos a cero
            end if;
        end loop;

        -- Al llegar a cero, activamos la señal de fin
        s_Fin_Temp <= '1';
        
        -- Esperamos a que la cafetera quite el Start (Handshake)
        wait until s_Start_Timer = '0';
        s_Fin_Temp <= '0';
        
    end process;

    -- 6. Proceso de Estímulos (Tus dedos pulsando botones)
    stim_proc: process
    begin		
        -- a) Reset inicial
        s_RESET <= '0';
        wait for 100 ns;
        s_RESET <= '1'; -- Soltamos reset (Activo a nivel bajo en tu código)
        wait for 50 ns;

        -- b) Encendemos la máquina
        s_Encender <= '1'; -- Pulsamos encender
        wait for 20 ns; -- Lo mantenemos si es interruptor, o pulso si es botón.
        -- Asumiremos que es interruptor ON fijo:
        -- s_Encender <= '0'; (Descomentar si es pulsador)

        wait for 50 ns;

        -- c) Pedimos un CAFÉ CORTO
        s_Cafe_corto <= '1';
        wait for 40 ns; -- Simulamos pulsación del dedo
        s_Cafe_corto <= '0';

        -- d) Ahora el proceso "timer_simulation" hará el trabajo sucio...
        -- Esperamos suficiente tiempo para ver todo el ciclo (Cafe -> Alarma -> Fin)
        wait for 2000 ns; 

        -- e) Pedimos un CAFÉ LARGO
        s_Cafe_largo <= '1';
        wait for 40 ns;
        s_Cafe_largo <= '0';

        wait for 3000 ns; -- Esperar a que termine

        -- Fin de la simulación
        assert false report "Fin de la Simulacion con exito" severity failure;
    end process;

end Behavior;
