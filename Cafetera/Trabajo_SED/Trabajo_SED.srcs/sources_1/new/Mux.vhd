----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 19:24:58
-- Design Name: 
-- Module Name: Mux - Behavioral
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

--Este módulo no es un mux tradicional sino que sigue la lógica de un mux tradicional.
--Por tanto lo que se quiere es alternar entre las salidas cada cierto tiempo
--De esta manera conseguimos ver dos dígitos a la vez (alternando cada 5ms para no ver parpadeo)

entity Mux is
    Port (
        SEG_DECENA_IN : in  STD_LOGIC_VECTOR (6 downto 0); --Decenas
        SEG_UNIDAD_IN : in  STD_LOGIC_VECTOR (6 downto 0); --Unidades
        CLK : in  STD_LOGIC;
        RESET : in  STD_LOGIC;  
        SEG_OUT : out STD_LOGIC_VECTOR (6 downto 0);  --Salida de datos 7-segmentos
        HAB_DECENA : out STD_LOGIC;  --Habilitacion decena
        HAB_UNIDAD : out STD_LOGIC   --Habilitacion unidad
    );
end Mux;

architecture Behavioral of Mux is

    constant MUX_COUNT_MAX : natural := 500000 - 1; --Alternamos cada 5 ms (para ver bien) (500.000 ciclos)
    signal Mux_Counter     : unsigned(19 downto 0) := (others => '0');-- 20 bits son suficientes para contar hasta 500.000
    signal Selector_Reg    : std_logic := '0'; -- Señal de 1 bit que alterna entre '0' (Decena) y '1' (Unidad)

begin

    process(CLK, RESET)
    begin
        if RESET = '0' then --Reset
            Mux_Counter <= (others => '0');
            Selector_Reg <= '0';
            
        elsif rising_edge(CLK) then --Lógica secuencial
            if Mux_Counter = MUX_COUNT_MAX then --Si estamos en el máximo entonces toca resetear y cambiar de salida
                Mux_Counter <= (others => '0');
                Selector_Reg <= not Selector_Reg; -- Alternamos el digito cada 5 ms
            else --Seguimos en la misma salida (seguimos contando)
                Mux_Counter <= Mux_Counter + 1;
            end if;
        end if;
    end process;

    -- A. Lógica de Salida
    with Selector_Reg select
        SEG_OUT <= SEG_DECENA_IN when '0', -- Si selector es '0', muestra Decena
                   SEG_UNIDAD_IN when '1', -- Si selector es '1', muestra Unidad
                   (others => '1') when others; --Todo activo cuando sea otra cosa
                   
    -- B. Lógica de Habilitación
    HAB_DECENA <= Selector_Reg; -- Cuando Selector_Reg es '0', activa HAB_DECENA (Decena)   
    HAB_UNIDAD <= not Selector_Reg;-- Cuando Selector_Reg es '1', activa HAB_UNIDAD (Unidad)


end Behavioral;
