----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2025 15:47:47
-- Design Name: 
-- Module Name: Cafetera - Behavioral
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

entity Cafetera is
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
end Cafetera;

architecture Behavioral of Cafetera is

    constant T_ALARMA : unsigned(15 downto 0) :=  to_unsigned(3000,16);
    constant T_CAFE_CORTO: unsigned(15 downto 0) :=  to_unsigned(3000,16);
    constant T_CAFE_LARGO: unsigned(15 downto 0) :=  to_unsigned(5000,16);
    
    -- La mitad del tiempo
    constant MITAD_CORTO  : unsigned(15 downto 0) := to_unsigned(1500, 16);
    constant MITAD_LARGO  : unsigned(15 downto 0) := to_unsigned(2500, 16);


    type Estados is(
        APAGADO,
        INICIO,
        --PRE_CORTO,
        CORTO,
        --PRE_LARGO,
        LARGO,
        TRANSICION_CAFE,
        TRANSICION_ALARMA,
        ALARMA
        --ESPERA_SOLTAR
    );
    signal current_state: Estados:=APAGADO;
    signal next_state: Estados;

begin
    process(CLK, RESET)
    begin
        if RESET='0' then
            current_state<=APAGADO;
        elsif rising_edge (CLK) then

                current_state<=next_state;

        end if;
    end process;
    
    next_estado:process(current_state, Encender, Cafe_corto,Cafe_largo,Fin_Temp)
    begin
        --Sentencias que se leen antes de cada case y luego en el case se evaluan.
        next_state<=current_state;
        Bomba_Cafe<='0';
        Bomba_Leche<='0';
        Zumbador<='0';
        Timer<= (others=>'0');
        Start_Timer <= '0';
        
        case current_state is --OK
            when APAGADO =>
                if Encender='1' then
                    next_state<=INICIO;
                end if;
                
            when INICIO => --OK
                if Cafe_corto ='1' then
                    next_state<=CORTO;
                    Start_Timer <= '1';--Importante ponerlo aqui
                    Timer<=T_CAFE_CORTO;
                elsif Cafe_largo ='1' then
                    next_state<=LARGO;
                    Start_Timer <= '1';
                    Timer <= T_CAFE_LARGO;
                elsif Encender ='1' then
                    next_state<=APAGADO;
                end if;
                
            when CORTO => --OK
                Timer<=T_CAFE_CORTO;--Necesario ponerlo de nuevo ya que sino timer volvería a ser cero
                
                if Cuenta_Actual > MITAD_CORTO then
                    Bomba_cafe  <= '1';
                    Bomba_leche <= '0';
                else
                    Bomba_cafe  <= '0';
                    Bomba_leche <= '1';
                end if;
                
                if Fin_Temp = '1' then
                    next_state<=TRANSICION_CAFE;
                end if;

            when LARGO => --OK
                Timer<=T_CAFE_LARGO;
                
                if Cuenta_Actual > MITAD_LARGO then
                    Bomba_cafe  <= '1';
                else
                    Bomba_leche <= '1';
                end if;
                
                if Fin_Temp = '1' then
                    next_state<=TRANSICION_CAFE;
                end if;
                    
            when ALARMA => --OK
                Zumbador<='1';
                Timer<=T_ALARMA;
                    if Fin_Temp = '1' then
                        --next_state<=ESPERA_SOLTAR;
                        next_state<=TRANSICION_ALARMA;
                    end if;
                    
            when TRANSICION_CAFE=> --Por si acaso Fin_Temp sigue valiendo uno (Bajamos Fin_Temp a 0)
                next_state<=ALARMA;
                Start_Timer <= '1';       
                Timer <= T_ALARMA;
                
            when TRANSICION_ALARMA=> --Por si acaso Fin_Temp sigue valiendo uno
                next_state<=INICIO; 
            
                  
            when others =>
                next_state<=APAGADO;
            end case;            
    end process;
end Behavioral;
