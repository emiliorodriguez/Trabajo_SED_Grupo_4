----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 15:26:29
-- Design Name: 
-- Module Name: Debouncer - Behavioral
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

entity Debouncer is
    generic (
        HOLD_TIME : natural := 20; -- 20 ms es el tiempo estándar para confirmar que una pulsación es estable
        COUNT_BITS   : natural := 5   -- 5 bits son suficientes para contar hasta 20 (2^5 = 32)
    );
    Port ( 
        CLK : in  std_logic;  -- Reloj principal
        RESET : in  std_logic;  -- Reset asíncrono
        CLK_1ms : in  std_logic;  -- Pulso habilitador de 1 ms
        SYNC_IN : in  std_logic;  -- Señal síncrona       
        BTN_LIMPIO : out std_logic  -- Salida sin rebote (limpio)
    );
end Debouncer;

architecture Behavioral of Debouncer is

    
    signal Count_ms : unsigned(COUNT_BITS-1 downto 0) := (others => '0');-- Contador para medir los ms (hasta 20 ms)
    signal Senal_est : std_logic := '0'; -- Registro del estado limpio actual

begin
    process(CLK, RESET)
    begin
        if RESET = '0' then
            Count_ms     <= (others => '0');
            Senal_est   <= '0';
            
        elsif rising_edge(CLK) then

            if CLK_1ms = '1' then --El ruido es lento
                
                -- Si la entrada (SYNC_IN) es diferente del estado estable (Senal_est)
                if SYNC_IN /= Senal_est then
                    
                    -- A. Cambio/Rebote detectado
                    if Count_ms < to_unsigned(HOLD_TIME, COUNT_BITS) then
                         Count_ms <= Count_ms + 1; -- Contamos la duracion del cambio (Dejamos correr el tiempo)
                        
                    -- B. Estabilidad confirmada
                    else
                         Senal_est <= SYNC_IN; -- Aceptamos el nuevo estado
                         Count_ms   <= (others => '0'); -- Reiniciamos el contador
                    end if;
                    
                -- Si la entrada es fija (no se diferencia de Stable_Sig)
                else
                    Count_ms <= (others => '0'); -- Reseteamos el contador para prepararnos para el próximo cambio/rebote
                end if;
                
            end if;
            
        end if;
    end process;
    
    BTN_LIMPIO <= Senal_est; --Asignamos la salida final

end Behavioral;
