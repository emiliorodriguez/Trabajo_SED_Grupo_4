----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2025 10:29:12
-- Design Name: 
-- Module Name: Zumbador - Behavioral
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

entity Zumbador is
    Port ( 
        CLK : in  STD_LOGIC; -- Reloj
        RESET : in  STD_LOGIC; --Reset
        ENABLE : in  STD_LOGIC; -- '1' para que suene, '0' para silencio
        AUDIO_PWM: out STD_LOGIC; -- Salida de audio
        AUDIO_SD : out STD_LOGIC  -- Habilitación del amplificador (Encender LED)
    );
end Zumbador;

architecture Behavioral of Zumbador is
    -- Reloj FPGA es 100.000.000 Hz y tono es 1.000 Hz (1 kHz)
    -- Periodo completo es por tanto 100.000
    signal count : integer range 0 to 50000 := 0; --Contador que va desde 0 a 50.000
    signal pwm : std_logic := '0';
begin

    process(CLK, RESET)
    begin
        if RESET = '0' then
            count <= 0;
            pwm <= '0';
            
        elsif rising_edge(CLK) then
            if ENABLE = '1' then
                -- Si el zumbador está activo, contamos para generar la frecuencia
                if count = 50000 - 1 then
                    count <= 0;
                    pwm <= not pwm; -- Invertir la señal (Generar onda cuadrada)
                else
                    count <= count + 1;
                end if;
            else
                -- Si no está habilitado, reiniciamos y silenciamos
                count <= 0;
                pwm <= '0';
            end if;
        end if;
    end process;

    -- Asignación de salidas
    AUDIO_PWM <= pwm; 
    AUDIO_SD <= ENABLE;

end Behavioral;
