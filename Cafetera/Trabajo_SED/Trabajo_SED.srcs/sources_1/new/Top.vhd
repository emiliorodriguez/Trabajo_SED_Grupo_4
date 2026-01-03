----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2025 22:07:19
-- Design Name: 
-- Module Name: Top - Behavioral
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

entity Top is
Port ( 
        CLK : in  STD_LOGIC; -- Reloj 
        RESET : in  STD_LOGIC; -- Botón Reset
        BTN_ENCENDER : in  STD_LOGIC;
        BTN_CORTO : in  STD_LOGIC;
        BTN_LARGO : in  STD_LOGIC;
        BOMBA_CAFE : out STD_LOGIC;
        BOMBA_LECHE : out STD_LOGIC;
        AUDIO_PWM : out STD_LOGIC;
        AUDIO_SD : out STD_LOGIC;
        SEG_DISP : out STD_LOGIC_VECTOR(6 downto 0); -- Segmentos A-G
        ANODOS : out STD_LOGIC_VECTOR(1 downto 0)  -- Control para elegir display
    );
end Top;

architecture Behavioral of Top is

    component Clk_Divisor is
        Port( CLK: in std_logic; 
              RESET: in std_logic; 
              CLK_1ms: out std_logic );
    end component;


    component Sincronizador is
        Port( CLK: in std_logic; 
              RESET: in std_logic; 
              ASYNC_IN: in std_logic; 
              SYNC_OUT: out std_logic );
    end component;


    component Debouncer is
        generic( HOLD_TIME : natural := 20; 
                  COUNT_BITS : natural := 5 );
        Port( CLK: in std_logic; 
              RESET: in std_logic; 
              CLK_1ms: in std_logic; 
              SYNC_IN: in std_logic; 
              BTN_LIMPIO: out std_logic );
    end component;


    component DetectFlanco is
        Port( CLK: in std_logic; 
              RESET: in std_logic; 
              SYNC_IN: in std_logic; 
              EDGE: out std_logic );
    end component;


    component Cafetera is
        Port(
            CLK: in STD_LOGIC; 
            RESET: in STD_LOGIC;
            Encender : in STD_LOGIC;
            Cafe_corto: in STD_LOGIC;
            Cafe_largo: in STD_LOGIC;
            Fin_Temp: in STD_LOGIC;
            Cuenta_Actual : in unsigned(15 downto 0);
            Bomba_cafe: out STD_LOGIC;
            Bomba_leche: out STD_LOGIC;
            Zumbador: out STD_LOGIC;
            Start_Timer : out STD_LOGIC;
            Timer: out unsigned(15 downto 0)
        );
    end component;


    component Temporizador is
        generic ( C_BITS : natural := 16 );
        port (
            CLK: in std_logic; 
            RESET: in std_logic; 
            CLK_1ms: in std_logic;
            TEMP : in unsigned(C_BITS-1 downto 0);
            INI_TEMP: in std_logic;
            FIN_TEMP: out std_logic;
            CUENTA_OUT : out unsigned(C_BITS-1 downto 0)
        );
    end component;


    component Zumbador is
        Port ( CLK: in STD_LOGIC;
               RESET: in STD_LOGIC; 
               ENABLE: in STD_LOGIC; 
               AUDIO_PWM: out STD_LOGIC; 
               AUDIO_SD : out STD_LOGIC );
    end component;


    component Decoder is
        Port ( CODE: in std_logic_vector(3 downto 0); 
               LED: out std_logic_vector(6 downto 0) );
    end component;


    component Mux is
        Port (
            SEG_DECENA_IN : in STD_LOGIC_VECTOR (6 downto 0);
            SEG_UNIDAD_IN : in STD_LOGIC_VECTOR (6 downto 0);
            CLK : in STD_LOGIC; 
            RESET : in STD_LOGIC;
            SEG_OUT : out STD_LOGIC_VECTOR (6 downto 0);
            HAB_DECENA : out STD_LOGIC; 
            HAB_UNIDAD : out STD_LOGIC
        );
    end component;

    
    signal clk_1ms_int : std_logic;-- Reloj 1ms
    signal sync_enc, deb_enc, edge_enc : std_logic;-- Botón Encender
    signal sync_corto, deb_corto, edge_corto : std_logic;-- Botón Corto
    signal sync_largo, deb_largo, edge_largo : std_logic;-- Botón Largo

    signal valor_tiempo_fsm : unsigned(15 downto 0); -- Salida de la FSM
    signal tiempo_ms : unsigned(15 downto 0); -- Cuenta actual del temporizador
    signal fin_temp : std_logic;
    signal start_timer : std_logic;
    signal zumbador_enable : std_logic;

    signal segundos_total : integer range 0 to 100;
    signal digito_decena : unsigned(3 downto 0);
    signal digito_unidad : unsigned(3 downto 0);
    signal seg_decena_code : std_logic_vector(6 downto 0);
    signal seg_unidad_code : std_logic_vector(6 downto 0);
    
    
begin

    U_CLK_DIV: Clk_Divisor 
    port map ( 
        CLK => CLK, 
        RESET => RESET, 
        CLK_1ms => clk_1ms_int );

    U_SYNC_ENC: Sincronizador 
    port map (
        CLK => CLK, 
        RESET => RESET, 
        ASYNC_IN => BTN_ENCENDER, 
        SYNC_OUT => sync_enc);
        
    U_DEB_ENC:  Debouncer     
    port map (
        CLK => CLK, 
        RESET => RESET, 
        CLK_1ms => clk_1ms_int, 
        SYNC_IN => sync_enc, 
        BTN_LIMPIO => deb_enc);
        
    U_EDGE_ENC: DetectFlanco  
    port map (
        CLK => CLK, 
        RESET => RESET, 
        SYNC_IN => deb_enc, 
        EDGE => edge_enc);

    U_SYNC_CORTO: Sincronizador 
    port map (
        CLK => CLK, 
        RESET => RESET, 
        ASYNC_IN => BTN_CORTO, 
        SYNC_OUT => sync_corto);
        
    U_DEB_CORTO:  Debouncer     
    port map (
        CLK => CLK, 
        RESET => RESET, 
        CLK_1ms => clk_1ms_int, 
        SYNC_IN => sync_corto, 
        BTN_LIMPIO => deb_corto);
        
    U_EDGE_CORTO: DetectFlanco  
    port map (
        CLK => CLK, 
        RESET => RESET, 
        SYNC_IN => deb_corto, 
        EDGE => edge_corto);

    U_SYNC_LARGO: Sincronizador 
    port map (
        CLK => CLK, 
        RESET => RESET, 
        ASYNC_IN => BTN_LARGO, 
        SYNC_OUT => sync_largo);
        
    U_DEB_LARGO:  Debouncer     
    port map (
        CLK => CLK, 
        RESET => RESET, 
        CLK_1ms => clk_1ms_int, 
        SYNC_IN => sync_largo, 
        BTN_LIMPIO => deb_largo);
        
    U_EDGE_LARGO: DetectFlanco  
    port map (
        CLK => CLK, 
        RESET => RESET, 
        SYNC_IN => deb_largo, 
        EDGE => edge_largo);

    U_FSM: Cafetera
    port map (
        CLK         => CLK,
        RESET       => RESET,
        Encender    => edge_enc,
        Cafe_corto  => edge_corto,
        Cafe_largo  => edge_largo,
        Fin_Temp    => fin_temp,
        Cuenta_Actual => tiempo_ms,
        Bomba_cafe  => BOMBA_CAFE,
        Bomba_leche => BOMBA_LECHE,
        Zumbador    => zumbador_enable,
        Start_Timer => start_timer,
        Timer       => valor_tiempo_fsm
    );


    U_TIMER: Temporizador
    generic map ( C_BITS => 16 )
    port map (
        CLK        => CLK,
        RESET      => RESET,
        CLK_1ms    => clk_1ms_int,
        TEMP       => valor_tiempo_fsm,
        INI_TEMP   => start_timer,
        FIN_TEMP   => fin_temp,
        CUENTA_OUT => tiempo_ms
    );

    U_ZUMB: Zumbador
    port map ( 
        CLK => CLK, 
        RESET => RESET, 
        ENABLE => zumbador_enable, 
        AUDIO_PWM => AUDIO_PWM, 
        AUDIO_SD => AUDIO_SD );

    segundos_total <= to_integer(tiempo_ms) / 1000; --Convertimos a segundos (para que en el display salga eso)
    digito_decena <= to_unsigned(segundos_total / 10, 4); --Separa las decenas
    digito_unidad <= to_unsigned(segundos_total mod 10, 4); --Separa las unidades
    
    U_DEC_DECENA: Decoder 
    port map ( 
        CODE => std_logic_vector(digito_decena), 
        LED => seg_decena_code );
        
    U_DEC_UNIDAD: Decoder 
    port map ( 
        CODE => std_logic_vector(digito_unidad), 
        LED => seg_unidad_code );
    
    U_MUX: Mux
    port map (
        SEG_DECENA_IN => seg_decena_code,
        SEG_UNIDAD_IN => seg_unidad_code,
        CLK           => CLK,
        RESET         => RESET,
        SEG_OUT       => SEG_DISP,
        HAB_DECENA    => ANODOS(1),
        HAB_UNIDAD    => ANODOS(0)
    );
    
end Behavioral;
