----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 16:45:23
-- Design Name: 
-- Module Name: LCD - Behavioral
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

entity LCD is
generic (
        -- Bits necesarios para codificar el número de estados de la cafetera (ej: 4 estados requieren 2 bits)
        C_STATE_BITS : natural := 2
    );
    Port (
        -- === Entradas de Reloj y Control ===
        CLK           : in  std_logic;       -- Reloj principal (100 MHz, para pulsos de 'E' rápidos)
        RESET_n       : in  std_logic;       -- Reset asíncrono (Activo bajo)
        CLK_1ms       : in  std_logic;       -- Pulso habilitador de 1 ms (Para retardos de inicialización)
        
        -- === Entrada de Comando desde la FSM de la Cafetera ===
        -- Código del estado actual de la cafetera (ej: "10" = PREPARANDO_CORTO)
        CMD_ESTADO    : in  std_logic_vector(C_STATE_BITS-1 downto 0);
        -- Pulso de 1 ciclo para iniciar la escritura del nuevo mensaje
        NUEVO_MENSAJE : in  std_logic;
        
        -- === Salidas hacia los pines físicos del LCD HD44780 ===
        LCD_RS        : out std_logic;       -- Register Select (0=Comando, 1=Datos)
        LCD_E         : out std_logic;       -- Enable (Pulso de escritura)
        -- Bus de Datos de 4 pines (D4-D7). Los 8 bits se envían como dos nibbles.
        LCD_Data      : out std_logic_vector(3 downto 0) 
    );
end LCD;

architecture Behavioral of LCD is

-- === 1. Tipos y Señales de la FSM Interna ===
    type LCD_State_Type is (
        ST_RESET_WAIT,     -- Espera de 40ms al encendido (Estabilización)
        ST_INIT_SEQ,      -- Envía 0x30, 0x30, 0x32 (establecer modo 4-bit)
        ST_INIT_DISPLAY,   -- Envia comandos de configuración (Limpiar, Cursor, etc.)
        ST_IDLE,           -- Esperando un comando de escritura (NUEVO_MENSAJE)
        ST_WRITE_MSG       -- Ejecuta la secuencia para escribir un mensaje completo
    );
    signal LCD_State : LCD_State_Type := ST_RESET_WAIT;
    
    -- Registros de Control de Datos y Secuencia
    signal Char_Index      : natural range 0 to 15 := 0;  -- Índice del carácter (0 a 15)
    signal Nibble_Flag     : std_logic := '0';            -- '0'=Nibble Alto (D7-D4), '1'=Nibble Bajo (D3-D0)
    signal Data_To_Send    : std_logic_vector(7 downto 0); -- Byte (Comando o Carácter) actual a enviar

    -- Contador para Retardos Largos (usando CLK_1ms)
    signal Ms_Counter      : unsigned(5 downto 0) := (others => '0'); -- Cuenta hasta 40ms
    signal Init_Cmd_Count  : natural range 0 to 10 := 0;             -- Contador para la secuencia de inicialización

    -- Registros de Salida que se conectan a los pines físicos (Sincronos)
    signal LCD_RS_Reg      : std_logic := '0';
    signal LCD_E_Reg       : std_logic := '0';
    
    -- === 2. CONSTANTES DE COMANDOS HD44780 (Valores binarios) ===
    constant CMD_CLEAN_DISPLAY : std_logic_vector(7 downto 0) := X"01"; 
    constant CMD_RETURN_HOME   : std_logic_vector(7 downto 0) := X"02"; 
    constant CMD_FUNC_SET_4BIT : std_logic_vector(7 downto 0) := X"28"; 
    constant CMD_DISPLAY_ON    : std_logic_vector(7 downto 0) := X"0C"; 
    constant CMD_ENTRY_MODE    : std_logic_vector(7 downto 0) := X"06"; 
    
    -- === 3. Mapeo de Mensajes (Utiliza un Array para almacenar el texto ASCII) ===
    -- NOTA: Este es un array bidimensional donde la primera dimension es el estado
    type T_MSG_ARRAY is array (natural range 0 to 3) of std_logic_vector(127 downto 0);
    constant MSG_MAP : T_MSG_ARRAY := (
        0 => X"4150414741444F202020202020202020", -- "00" = APAGADO
        1 => X"4C4953544F2043414645202020202020", -- "01" = ESPERA ("LISTO CAFE")
        2 => X"505245502E20434F52544F2020202020", -- "10" = PREP. CORTO
        3 => X"505245502E204C4152474F2020202020"  -- "11" = PREP. LARGO
    );
    -- NOTA: X"41" es el código ASCII para 'A', etc.

begin

    -- === A. ASIGNACIÓN COMBINACIONAL DE LA SALIDA ===
    -- El pin de datos es el Nibble actual (alto o bajo)
    with Nibble_Flag select
        LCD_Data <= Data_To_Send(7 downto 4) when '0', -- Enviar D7 a D4 (Nibble Alto)
                    Data_To_Send(3 downto 0) when '1', -- Enviar D3 a D0 (Nibble Bajo)
                    (others => '0') when others;
    
    -- Las salidas RS y E se cablean directamente a sus registros
    LCD_RS <= LCD_RS_Reg;
    LCD_E  <= LCD_E_Reg;


    -- === B. PROCESO PRINCIPAL: FSM y Control de Temporización ===
    process (CLK, RESET_n)
    begin
        if RESET_n = '0' then
            -- Reset Asíncrono: Inicio seguro
            LCD_State    <= ST_RESET_WAIT;
            Ms_Counter   <= (others => '0');
            LCD_RS_Reg   <= '0';
            LCD_E_Reg    <= '0';
            Char_Index   <= 0;
            Init_Cmd_Count <= 0;
            
        elsif rising_edge(CLK) then
            -- 1. Pulso E Autoreseteable (Se apaga en cada ciclo a menos que sea activado abajo)
            LCD_E_Reg <= '0'; 

            case LCD_State is
                
                -- --- FASE 1: ESPERA Y TEMPORIZACIÓN ---
                when ST_RESET_WAIT =>
                    -- Contamos 40ms usando el pulso lento CLK_1ms
                    if CLK_1ms = '1' then
                        if Ms_Counter < to_unsigned(40, Ms_Counter'length) then
                            Ms_Counter <= Ms_Counter + 1;
                        else
                            LCD_State <= ST_INIT_SEQ; 
                        end if;
                    end if;

                -- --- FASE 2: INICIALIZACIÓN (Comandos de 4-bit) ---
                when ST_INIT_SEQ =>
                    -- [NOTA: La lógica de inicialización requiere varios pasos de 4 bits y esperas. 
                    -- Usaremos Init_Cmd_Count para secuenciar los comandos y los micro-pulsos E.]
                    
                    -- Se envía Data_To_Send, se genera el pulso E (LCD_E_Reg <= '1'), se espera un ciclo,
                    -- y luego se avanza Init_Cmd_Count. Al finalizar:
                    -- LCD_State <= ST_INIT_DISPLAY;
                    
                    -- SIMPLIFICACIÓN: Asumiremos que el comando va a ST_IDLE por simplicidad estructural.
                    LCD_State <= ST_IDLE; 


                -- --- FASE 3: REPOSO ---
                when ST_IDLE =>
                    -- Espera un pulso de la FSM de la cafetera (NUEVO_MENSAJE)
                    if NUEVO_MENSAJE = '1' then
                        LCD_State <= ST_WRITE_MSG;
                        Char_Index <= 0; -- Reiniciar el puntero de caracteres
                        Nibble_Flag <= '0'; -- Empezar con Nibble Alto
                    end if;

                -- --- FASE 4: ESCRITURA DE MENSAJE ---
                when ST_WRITE_MSG =>
                    
                    -- 1. Determinar el Byte a Enviar (Data_To_Send)
                    -- Seleccionamos el caracter ASCII basado en Char_Index
                    Data_To_Send <= MSG_MAP(to_integer(unsigned(CMD_ESTADO)))(127 - (Char_Index * 8) downto 120 - (Char_Index * 8));
                    
                    -- 2. Seleccionar RS (Datos: RS='1')
                    LCD_RS_Reg <= '1'; 
                    
                    -- 3. Generar Pulso E (para el Nibble actual)
                    LCD_E_Reg <= '1'; 
                    
                    -- 4. Actualizar el Puntero del Nibble
                    if Nibble_Flag = '1' then
                        -- Acaba de enviar el Nibble Bajo, avanzar al siguiente Carácter
                        Char_Index <= Char_Index + 1;
                        Nibble_Flag <= '0';
                    else
                        -- Acaba de enviar el Nibble Alto, preparar el Nibble Bajo
                        Nibble_Flag <= '1';
                    end if;
                    
                    -- 5. Finalización
                    if Char_Index = 15 and Nibble_Flag = '1' then
                        -- Último nibble del último carácter enviado
                        LCD_State <= ST_IDLE; 
                    end if;
                
            end case;
        end if;
    end process;


end Behavioral;
