-- Copyright Aleksandar Jevtic.

--*****************************************
-- This file contains a Vhdl
-- design for roll dice that can be used
-- in any game.
-- It's recommended to read 'diif.vhd' and
-- 'generator.vhd' first.
-- Comments are provided in each section
-- to help the user understand.
--*****************************************
-- Generated on "12/25/2020"
-- Version 1.0.

library ieee;
use ieee.std_logic_1164.all;

--*******************************************
-- Entity for roll dice is named 'roll_dice'.
--*******************************************

--------------------------------------------------------------
-- Na ulazne portove se dovode signali takta, reseta,
-- signal 'button' koji se dovodi preko prethodno definisane 
-- komponente 'diff', i signal 'enable_n' aktivan 
-- u logickoj '0' koji se dovodi direktno sa prekidaca i 
-- prosledjuje na prethodno definisanu komponentu 'generator'.
-- Na izlazni port se salje izlazni signal komponente
-- 'generator'.
--------------------------------------------------------------
entity roll_dice is
port(
    clk,reset,button,enable_n : in std_logic;
    digit : out std_logic_vector(2 downto 0)
);
end roll_dice;

--**************************
-- Behavioral of roll dice.
--**************************

----------------------------------------------------
-- Sadrzi komponente 'generator' i 'diff'.
-- Realizovana kao masina stanja sa tri
-- razlicita stanja.
-- Moze se koristiti za bilo koju igru koja
-- koristi kockice bez potrebe za modifikacijom.
-- Cim se dovede napajanje, odnosno signal takta,
-- komponenta 'generator' pocinje da generise
-- slucajne brojeve bez obzira dal je igra, odnosno
-- bacanje u toku.
----------------------------------------------------
architecture behavioral of roll_dice is

component generator is
port(
    clk,reset: in std_logic;
    digit : out std_logic_vector(2 downto 0)
);
end component;

component diff is
port(
    clk,reset,button,enable_n : in std_logic;
    roll : out std_logic
);
end component;


-- Definisanje stanja.
-- 'state_reg' je trenutno stanje u kom se masina nalazi,'next_state' je naredno
-- stanje u koje masina prelazi sa prvom narednom uzlaznom ivicom signala takta.
-- U stanju initial_state je na izlazu cifra 0 i kockica je spremna za bacanje.
-- U stanju roll_state se na svaku uzlaznu ivicu signala takta menja izlaz i ima 
-- vrednost slucajno izgenerisane cifre posredstvom komponente 'generator'.
-- Ovo stanje simulira bacanje kockice.
-- U stanju end_of_roll_state izlaz ne menja vrednost sve dok ne dodje zahtev
-- za narednim bacanjem.
-- Ovo stanje oznacava da je kockica pala, odnosno da je bacanje zavrseno.
-- U slucaju aktivne vrednosti signala 'reset', prelazi se u initial_state bez 
-- obzira u kom se trenutnom stanju masina nalazi.
type State_t is (initial_state,roll_state,end_of_roll_state);
signal state_reg,next_state : State_t;

-- Signal 'random_digit' je signal koji ce biti na izlazu dokle god je masina 
-- u stanju roll_state.
-- Ovaj signal je povezan na izlaz komponente 'generator' i menja se na svaku
-- uzlaznu ivicu signala takta bez obzira u kom se trenutnom stanju masina nalazi.
-- Signal 'output_digit' je signal koji ce biti na izlazu dokle god je masina u 
-- stanju end_of_roll_state.
-- Ovaj signal menja vrednost samo u trenutku kada masina prelazi u stanje
-- end_of_roll_state i tada dobija trenutnu vrednost signala 'random_digit'.
-- Ovaj signal oznacava koji broj je pao prilikom zavrsetka bacanja.
signal random_digit : std_logic_vector(2 downto 0);
signal output_digit : std_logic_vector(2 downto 0);

-- Pomocni signal koji predstavlja izlaz komponente 'diff' i oznacava pritisak
-- tastera, odnosno pocetak i kraj bacanja.
-- Traje tacno jedan taktni period, potrebno je primetiti da dokle god signal
-- 'enable_n' ima neaktivnu vrednost, ovaj signal ne moze dobiti aktivnu vrednost.
-- Ovaj signal je interni, na blok semi se nigde ne povezuje.
signal roll : std_logic := '0';

-- U zavisnosti od vrednosti ovog signala masina prelazi u stanje roll_state.
-- Kada je ovaj signal aktivan, odnosno ima vrednost logicke '1', znaci da je
-- prvi put pritisnut taster i da je bacanje u toku.
-- Ako je vec imao aktivnu vrednost u trenutku kada je pritisnut taster, znaci
-- da se bacanje zavrsava i signal dobija neaktivnu vrednost, odnosno vrednost 
-- logicke '0', i masina prelazi u stanje end_of_roll_state.
-- Dodatno, ukoliko signal 'enable_n' ima neaktivnu vrednost, signal 
-- 'generate_number' ce imati neaktivnu vrednost, cime se zabranjuje prelazak
-- u stanje roll_state, odnosno bacanje kockice je onemoguceno.
signal generate_number : std_logic := '0';

begin

    -- Povezivanje portova komponente 'generator' sa odgovarajucim signalima
    GENERATOR_PORT_MAP:generator port map(clk,reset,random_digit);
    
    DIFF_PORT_MAP:diff port map(clk,reset,button,enable_n,roll);
    
    -- Generisanje signala 'generate_number' i signala 'output_digit'.
    -- Menja se sa promenom signala 'roll' ili signala 'reset'.
    -- Promena se vrsi na uzlaznu ivicu signala 'roll' na prethodno opisani nacin. 
    -- Aktivna vrednost signala 'reset' postavlja signal 'generate_number' na 
    -- logicku '0' iz razloga sto bi pojavom aktivne vrednosti signala 'reset'
    -- masina presla u stanje initial_state i u slucaju da je signal 
    -- 'generate_number' u tom trenutku imao vrednost logicke '1' moglo bi da se
    -- dogodi da masina predje u stanje roll_state (kada bi se signal 'reset' 
    -- postavio na logicku '0') iako taster nije bio prethodno pritisnut.
    GEN_NUMBER:process(roll,reset)
    begin
        if reset = '1' then
            generate_number <= '0';
        elsif rising_edge(roll) then
        
            -- If petlja oznacava da je stigao zahtev za pocetak bacanja
            if generate_number = '0' then
                generate_number <= '1';
            
            -- Else petlja oznacava da je bacanje u toku, da je stigao zahtev
            -- za prekid bacanja i da u ovom trenutnku signal 'output_digit'
            -- moze da dobije vrednost signala 'random_digit'.
            else
                generate_number <= '0';
                output_digit <= random_digit;
            end if;
        end if;
    end process GEN_NUMBER;
    
    -- Proces promene trenutnog stanja u naredno stanje se obavlja na svaku
    -- uzlaznu ivicu signala takta.
    -- U slucaju da signal 'reset' ima aktivnu vrednost, masina ce preci
    -- u inicijalno stanje.
    STATE_TRANSITION:process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state_reg <= initial_state;
            else
                state_reg <= next_state;
            end if;
        end if;
    end process STATE_TRANSITION;
    
    
    -- Iz stanja initial_state je moguce preci samo u stanje roll_state i to pod
    -- uslovom da signal 'generate_number' ima aktivnu vrednost.
    -- U svim drugim slucajevima masina ostaje u stanju initial_state.
    -- Masina ostaje u stanju roll_state sve dok signal 'generate_number' ne
    -- dobije neaktivnu vrednost.
    -- Kada signal 'generate_number' dobije neaktivnu vrednost masina ce preci
    -- u stanje end_of_roll_state.
    -- Iz stanja end_of_roll_state masina se moze vratiti u stanje roll_state
    -- ako signal 'generate_number' ima aktivnu vrednost, sto oznacava da je
    -- zapoceto novo bacanje.
    -- U svim drugim slucajevima masina ostaje u stanju end_of_roll_state.
    -- Iz bilo kog stanja masina moze preci u stanje initial_state u slucaju
    -- aktivne vrednosti signala 'reset'.
    NEXT_STATE_LOGIC:process(state_reg,generate_number)
    begin
        case state_reg is
            when initial_state =>
                if generate_number = '1' then 
                    next_state <= roll_state;
                else
                    next_state <= initial_state;
                end if;
            when roll_state =>
                if generate_number = '1' then
                    next_state <= roll_state;
                else
                    next_state <= end_of_roll_state;
                end if;
            when end_of_roll_state =>
                if generate_number = '1' then
                    next_state <= roll_state;
                else
                    next_state <= end_of_roll_state;
                end if;
        end case;
    end process NEXT_STATE_LOGIC;
    
    -- Stanje initial_state postavlja cifru 0 na izlaz.
    -- Stanje roll_state postavlja signal 'random_digit' na izlaz i izlaz
    -- u ovom stanju se menja na svaku uzlaznu ivicu signala takta.
    -- Stanje end_of_roll_state postavlja signal 'output_digit' na izlaz.
    OUTPUT_LOGIC:process(state_reg,random_digit,output_digit)
    begin
        case state_reg is
            when initial_state =>
                digit <= "000";
            when roll_state =>
                digit <= random_digit;
            when end_of_roll_state =>
                digit <= output_digit;
        end case;
    end process OUTPUT_LOGIC;

end behavioral;