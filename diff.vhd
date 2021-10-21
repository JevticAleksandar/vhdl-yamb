-- Copyright Aleksandar Jevtic.

--*********************************************************************
-- This file contains a Vhdl design for differentiation of falling edge.
-- Comments are provided in each section to help the user understand.
--*********************************************************************
-- Generated on "12/25/2020".
-- Version 1.0.

library ieee;
use ieee.std_logic_1164.all;

--********************************************
-- Entity for differentiator is named 'diff'.
--********************************************

-----------------------------------------------------
-- Na ulazne portove se dovode signali takta, reseta,
-- 'button-a' koji predstavlja pritisak tastera
-- aktivan u logickoj '0', i 'enable_n' koji
-- je aktivan u logickoj '0'.
-- Na izlani port se salje signal 'roll' koji traje
-- tacno jednu periodu signala takta i koji ima
-- aktivnu vrednostu u logickoj '1'.
------------------------------------------------------
entity diff is
port(
    clk,reset,button,enable_n : in std_logic;
    roll : out std_logic
);
end diff;

--*******************************
-- Behavioral of differentiator.
--*******************************

---------------------------------------
-- Realizovan kao masina stanja sa tri 
-- razlicita stanja.
-- Stanje s0 je inicijalno stanje.
-- Stanje s1 je stanje koje traje tacno
-- jednu periodu signala takta i u kom
-- se na izlazu generise vrednost '1'.
-- Stanje s2 je stanje koje ceka 
-- otpustanje tastera.
---------------------------------------

architecture behavioral of diff is


-- state_reg predstavlja trenutno stanje u kom se masina nalazi.
-- next_state predstavlja stanje u koje ce masina preci na narednu
-- uzlaznu ivicu signala takta.
type State_t is (s0,s1,s2);
signal state_reg,next_state : State_t;

begin
    
    -- Proces promene trenutnog stanja u naredno stanje se obavlja na svaku
    -- uzlaznu ivicu signala takta.
    -- U slucaju da signal 'reset' ima aktivnu vrednost, masina ce preci
    -- u inicijalno stanje.
    STATE_TRANSITION:process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state_reg <= s0;
            else
                state_reg <= next_state;
            end if;
        end if;
    end process STATE_TRANSITION;
    
    -- Proces promene stanja zavisi od trenutnog stanja i signala 'button'.
    -- Iz inicijalnog stanja s0 se prelazi u naredno stanje s1 prilikom 
    -- pritiska tastera odnosno prilikom detekcije silazne ivice signala
    -- 'button'.
    -- U stanje s1 ce se preci tek na narednu uzlaznu ivicu signala takta ukoliko
    -- je prethodni uslov ispunjen.
    -- Iz stanja s1 se na prvu narednu uzlaznu ivicu signala takta prelazi u
    -- stanje s2 cime se obezbedjuje da stanje s1 traje tacno jednu periodu 
    -- signala takta.
    -- U stanju s2 se zadrzava dokle god je taster pritisnut.
    -- Stanje s2 je potrebno jer bi se u slucaju da je taster pritisnut duze od
    -- dve periode signala takta za jedan isti pritisak tastera dva ili vise puta
    -- generisala logicka '1' na izlazu.
    -- Ukoliko je signal 'enable_n' neaktivan, promena stanja nije moguca.
    -- U slucaju da je promena stanja otpoceta pre nego sto je signal 'enable_n'
    -- postao neaktivan onda se promena stanja izvrsava sve do povratka u 
    -- inicijalno stanje.
    NEXT_STATE_LOGIC:process(state_reg,button)
    begin
        case state_reg is
            when s0 =>
                if button = '0' and enable_n = '0' then
                    next_state <= s1;
                else
                    next_state <= s0;
                end if;
            when s1 =>
                next_state <= s2;
            when others =>
                if button = '0' then
                    next_state <= s2;
                else
                    next_state <= s0;
                end if;
        end case;
    end process NEXT_STATE_LOGIC;
    
    -- Izlaz zavisi samo od trenutnog stanja u kom se masina nalazi
    -- i samo ce se u stanju s1 generisati logicka '1' koja ce trajati tacno jednu
    -- periodu signala takta. U svim ostalim slucajevima na izlazu ce biti logicka
    -- '0'.
    OUTPUT_LOGIC:process(state_reg)
    begin
        case state_reg is
            when s1 =>
                roll <= '1';
            when others =>
                roll <= '0';
        end case;
    end process OUTPUT_LOGIC;

end behavioral;