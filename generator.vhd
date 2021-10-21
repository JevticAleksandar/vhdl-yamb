-- Copyright Aleksandar Jevtic.

--*********************************************************************
-- This file contains a Vhdl design for pseudo-random generator
-- that generates integers between 1 and 6.
-- Comments are provided in each section to help the user understand.
-- References used in this file:
-- 'https://www.engineersgarage.com/vhdl/feed-back-register-in-vhdl/'.
--*********************************************************************
-- Generated on "12/25/2020".
-- Version 1.0.

library ieee;
use ieee.std_logic_1164.all;

--**********************************************************
-- Entity for pseudo-random generator is named 'generator'.
--**********************************************************

--------------------------------------------------------
-- Na ulazne portove se dovode signali takta i reseta.
-- Na izlazni port se salje slucajna 3-bitna cifra koja 
-- ce biti izgenerisana.
-- 3 bita je dovoljno za prikaz potrebnih cifara,
-- odnosno svih cifara koje su u opsegu 1 do 6.
--------------------------------------------------------
entity generator is
port(
    clk,reset: in std_logic;
    digit : out std_logic_vector(2 downto 0)
);
end generator;


--****************************************
-- Behavioral of pseudo-random generator.
--****************************************

-------------------------------------------------
-- Realizovan kao masina stanja sa 2^8
-- razlicitih stanja zbog bolje raspodele.
-- Radi na uzlaznu ivicu signala takta.
-- Ovo znaci da je moguce da se na izlazu pojavi
-- isti slucajni broj na dve ili vise uzastopnih
-- uzlaznih ivica signala takta sto predstavlja
-- realno bacanje kockica.
-- Mana je sto raspodela ne moze biti ravnomerna
-- jer 6 ne deli 2^8.
-- Broj 6 ima najmanju sansu da bude izgenerisan.
-- Brojevi od 1 do 5 imaju istu sansu da budu
-- izgenerisani.
--------------------------------------------------

architecture behavioral of generator is

-- Definisanje stanja masine, state_reg predstavlja trenutno stanje u kom se 
-- masina nalazi, next_state predstavlja stanje u koje ce masina preci na
-- narednu uzlaznu ivicu signala takta.
-- Signal 'feedback' ce biti MSB od next_state
-- i dobija se od bita state_reg i to od bita na pozicijama 0,2,3 i 4.
-- 7 LSBs stanja next_state ce biti 7 MSBs stanja state_reg.
-- Ovo znaci da ce promena stanja raditi po principu right-shift registra sa 
-- prethodno izgenerisanim MSB-om ('feedback').
signal state_reg,next_state : std_logic_vector(7 downto 0) := "00000000";
signal feedback : std_logic := '1';

begin

    -- Proces promene trenutnog stanja u naredno stanje se obavlja na svaku
    -- uzlaznu ivicu signala takta.
    -- U slucaju da signal 'reset' ima aktivnu vrednost, masina stanja ce
    -- preci u inicijalno stanje "00000001"
    -- U ovome se ogleda pseudo karakter generatora.
    -- Nakon svakog reseta ce se generisati ista sekvenca slucajnih brojeva.
    STATE_TRANSITION:process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state_reg <= ( 0 =>'1',others => '0');
            else
                state_reg <= next_state;
            end if;
        end if;
    end process STATE_TRANSITION;
    
    -- Promena narednog stanja se obavlja na svaku uzlaznu ivicu signala takta.
    -- Prethodno opisan proces promene stanja i generisanja siganala 'feedback'.
    NEXT_STATE_LOGIC:process(clk)
    begin
        if rising_edge(clk) then
            feedback <= state_reg(4) xor state_reg(3) xor state_reg(2) xor state_reg(0);
            next_state <= feedback & state_reg(7 downto 1);
        end if;
    end process NEXT_STATE_LOGIC;
    
    -- Izlaz zavisi samo od trenutnog stanja, stoga je u sensitivity listi
    -- samo state_reg.
    OUTPUT_LOGIC:process(state_reg)
    begin
        -- Opseg stanja za koji ce se na izlazu pojaviti broj 1.
        if state_reg >= "00000000" and state_reg <= "00101010" then
            digit <= "001";
            
        -- Opseg stanja za koji ce se na izlazu pojaviti broj 2.
        elsif state_reg >= "00101011" and state_reg <= "01010101" then
            digit <= "010";
            
        -- Opseg stanja za koji ce se na izlazu pojaviti broj 3.
        elsif state_reg >= "01010110" and state_reg <= "10000000" then
            digit <= "011";
            
        -- Opseg stanja za koji ce se na izlazu pojaviti broj 4.
        elsif state_reg >= "10000001" and state_reg <= "10101011" then
            digit <= "100";
            
        -- Opseg stanja za koji ce se na izlazu pojaviti broj 5.
        elsif state_reg >= "10101100" and state_reg <= "11010110" then
            digit <= "101";
            
        -- Sva stanja koja su van prethodnih opsega ce na izlazu davati broj 6.
        else
            digit <= "110";
        end if;
    end process OUTPUT_LOGIC;

end behavioral;