-- Copyright Aleksandar Jevtic.

--*****************************************
-- This file contains a Vhdl
-- design for yamb game.
-- It's recommended to read 'roll_dice.vhd' and
-- 'bcd_to_7seg.vhd' first.
-- Comments are provided in each section
-- to help the user understand.
--*****************************************
-- Generated on "12/25/2020"
-- Version 1.0.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--***************************************
-- Entity for yamb game is named 'yamb'.
--***************************************

-------------------------------------------------------------
-- Na ulazne portove se dovode signali takta, reseta,
-- signal 'button' koji se prosledjuje na sest prethodno
-- definisanih komponenti 'roll_dice', i signal 'switches'
-- koji sadrzi vrednosti 6 prekidaca koji se dovode na
-- 'enable_n' ulaze komponenti 'roll_dice'.
-- Na izlazne portove se salju visebitni signali 'displays'
-- i 'le'.
-- Deset bita signala 'le' se salje na 10 LE dioda, dok se
-- grupe od po 7 bita iz signala 'displays' salju na jedan
-- od 6 sedmosegmentnih displeja preko prethodno definisane
-- komponente 'bcd_to_7seg'.
-------------------------------------------------------------

entity yamb is
port(
    clk,reset,button: in std_logic;
    switches : in std_logic_vector(5 downto 0);
    displays : out std_logic_vector(41 downto 0);
    le : out std_logic_vector(9 downto 0)
);
end yamb;

--****************************************
-- Behavoiral and structure of yamb game.
--****************************************

--------------------------------------------------
-- Sadrzi komponente 'roll_dice', 'bcd_to_7seg' i
-- 'pll'.
-- Realizovano kao masina stanja sa 4 razlicita
-- stanja.
---------------------------------------------------
architecture behavioral of yamb is


-- Konstante koje su odredjene na osnovu ucestanosti signala takta.
-- Testiranje je vrseno za periodu takta od 20ms,
-- stoga sekunda predstavlja 50 taktnih perioda,
-- 0.2 sekunde predstavlja 10 taktnih perioda.
-- Potrebno je modifikovati u slucaju promene ucestanosti takta.
constant C_SECOND : integer := 50;
constant C_0_2_SECOND : integer := 10;

-- Stanja su odredjena na slican nacin kao stanja za komponentu 'roll_dice'.
-- Razlika je u dodatnom stanju yamb_state u koje masina moze preci samo iz
-- stanja end_of_turn_state i to samo nakon treceg bacanja.
type State_t is (initial_state,turn_state,end_of_turn_state,yamb_state);
signal state_reg,next_state : State_t;

-- Signali koji odredjuju duzinu blinkanja LE dioda u slucaju dobitka jamba.
-- LE diode se pale i gase na svake 0.2 sekunde, a ukupno blinkanje traje
-- cetiri sekunde.
signal blink_counter : integer range 1 to 4*C_SECOND := 1;
signal blink_period : integer range 1 to C_0_2_SECOND := 1;
signal non_blink_period : integer range 1 to C_0_2_SECOND := 1;

-- Signal koji broji koliko puta je otpusten taster.
-- Bitno zbog oznacavanja kraja poteza.
-- Sesto otpustanje znaci da je trenutni igrac zavrsio svoj red.
signal button_counter : integer range 0 to 6 := 0;

-- Signal koji dobija vrednost logicke '1' u slucaju da je dobijen jamb.
-- U svim ostalim slucajevima ima vrednost logicke '0'.
signal yamb : std_logic := '0';

-- Signal rst je signal koji se dovodi na ulaz 'reset' komponenti 'roll_dice'.
-- Zahtevano je da u slucaju da je dobijen jamb sistem predje u inicijalno
-- stanje. Stoga je potrebno ovim signalom obezbediti da i kockice predju u 
-- inicijalno stanje.
-- Ovaj signal je interni i na blok semi je doveden na svaki od ulaza 'reset' 
-- komponenti 'roll_dice'.
-- Signali taktova koje generise komponenta 'pll' i koji se dovode na razlicite
-- kockice da bi se obezdebila vremenska razlicitost generisanja slucajnih brojeva.
-- Trebalo bi ih podesiti da imaju vecu ucestanost od siganala takta zbog
-- prelaznih procesa.
signal rst : std_logic;
signal clk_1,clk_2,clk_3,clk_4,clk_5 : std_logic;

-- Signal u koji su smesteni svi izlazi kockica i koji se dovode na ulaze 
-- komponenti 'bcd_to_7seg'.
type digits is array (5 downto 0) of std_logic_vector(2 downto 0);
signal digit : digits;

-- Signal koji oznacava kraj poteza za trenutnog igraca.
signal end_of_turn : std_logic;


component pll is
	port (
		refclk   : in  std_logic := '0';    -- refclk.clk
		rst      : in  std_logic := '0';    -- reset.reset
		outclk_0 : out std_logic;           -- outclk0.clk
		outclk_1 : out std_logic;           -- outclk1.clk
		outclk_2 : out std_logic;           -- outclk2.clk
		outclk_3 : out std_logic;           -- outclk3.clk
		outclk_4 : out std_logic            -- outclk4.clk
	);
end component;

component roll_dice is
port(
    clk,reset,button,enable_n : in std_logic;
    digit : out std_logic_vector(2 downto 0)
);
end component;

component bcd_to_7seg is
port(
    digit : in std_logic_vector(2 downto 0);
    display : out std_logic_vector(6 downto 0)
);
end component;

begin

    -- Povezivanje komponenti sa signalima.
    PLL_PORT_MAP:pll port map(clk,reset,clk_1,clk_2,clk_3,clk_4,clk_5);

    ROLL_DICE_1:roll_dice port map(clk,rst,button,switches(0),digit(0));
    ROLL_DICE_2:roll_dice port map(clk,rst,button,switches(1),digit(1));
    ROLL_DICE_3:roll_dice port map(clk,rst,button,switches(2),digit(2));
    ROLL_DICE_4:roll_dice port map(clk,rst,button,switches(3),digit(3));
    ROLL_DICE_5:roll_dice port map(clk,rst,button,switches(4),digit(4));
    ROLL_DICE_6:roll_dice port map(clk,rst,button,switches(5),digit(5));
    
    BCD_TO_7SEG_1:bcd_to_7seg port map(digit(0),displays(6 downto 0));
    BCD_TO_7SEG_2:bcd_to_7seg port map(digit(1),displays(13 downto 7));
    BCD_TO_7SEG_3:bcd_to_7seg port map(digit(2),displays(20 downto 14));
    BCD_TO_7SEG_4:bcd_to_7seg port map(digit(3),displays(27 downto 21));
    BCD_TO_7SEG_5:bcd_to_7seg port map(digit(4),displays(34 downto 28));
    BCD_TO_7SEG_6:bcd_to_7seg port map(digit(5),displays(41 downto 35));
    
    -- Proces koji broji otpustanje tastera.
    -- Menja se na uzlaznu ivicu signala 'button' iz razloga sto je signal
    -- 'button' aktivan u logickoj '0', a nas interesuje kada je taster otpusten,
    -- odnosno trenutak kada dobija vrednost logicke '1'.
    -- Uzeto je da se menja na otpustanje tastera jer u ovoj masini stanja
    -- postoje jos dve masine stanja, 'roll_dice' i 'diff' koje rade na silaznu
    -- ivicu signala 'button'.
    -- Samim tim ce se svi prelazni procesi izvrsiti tek nakon nekoliko uzastopnih
    -- uzlaznih ivica signala takta posle pritiska tastera.
    -- Dakle, ako je ucestanost takta dovoljno velika, pritisak tastera ce
    -- trajati dovoljno dugo da se svi prelazni procesi zavrse i da se izlazi
    -- stabilizuju.
    -- Zbog toga ce prilikom otpustanja tastera biti stabilizovani izlazi.
    -- Ovo je bitno jer se u trenutku menjanja ovog signala ispituje da li je 
    -- dobijen jamb.
    -- Prilikom aktivne vrednosti signala 'reseta', brojac dobija vrednost 0,
    -- jer igra krece ispocetka.
    -- Ako je vec imao vrednost 6, i ponovo je naisla uzlazna ivica signala
    -- 'button', dobice vrednost jedan jer je novi igrac vec zapoceo svoj red.
    CNT_PROCESS:process(button,reset)
    begin
        if reset = '1' then
            button_counter <= 0;
        elsif rising_edge(button) then
            if button_counter = 6 then
                button_counter <= 1;
            else
                button_counter <= button_counter + 1;
            end if;
        end if;
    end process CNT_PROCESS;
    
    -- Ako je taster otpusten sesti put, ondosno zavrseno je trece bacanje
    -- signal 'end_of_turn' dobija aktivnu vrednost.
    -- U svim drugim slucajevima ce imati neaktivnu vrednost.
    END_OF_TURN_FOR_PLAYER:process(button_counter)
    begin
        case button_counter is
            when 6 =>
                end_of_turn <= '1';
            when others =>
                end_of_turn <= '0';
        end case;
    end process END_OF_TURN_FOR_PLAYER;
    
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
    
    -- Iz inicijalnog stanja se prelazi u stanje turn_state u slucaju da je
    -- pritisnut taster.
    -- U stanju turn_state se ostaje do sledeceg pritiska tastera.
    -- Sledeci pritisak tastera oznacava prelazak u stanje end_of_turn_state.
    -- Iz stanja end_of_turn_state se vraca u stanje turn_state u slucaju
    -- pritiska tastera.
    -- Ukoliko je zavrsen potez trenutnog igraca, proverava se dal je dobijen 
    -- jamb i ako jeste prelazi se u stanje yamb_state.
    -- U svim drugim slucajevima se ostaje u stanju end_of_turn_state.
    -- U stanju yamb_state se zadrzava onoliko dugo koliko je predvidjeno
    -- signalom 'blink_counter', a zatim se vraca u inicijalno stanje.
    -- Ovde je potrebno i kockice resetovati da bi se na izlazima pojavile 0,
    -- stoga je ovaj uslov ukljucen u generisanje siganala 'rst'.
    -- Signal 'switches' unutar komponente 'roll_dice' omogucuje ili
    -- onemogucuje prelazak stanja.
    NEXT_STATE_LOGIC:process(state_reg,button,end_of_turn,yamb,blink_counter)
    begin
        case state_reg is
            when initial_state =>
                if button = '0' then
                    next_state <= turn_state;
                else
                    next_state <= initial_state;
                end if;
            when turn_state =>
                if end_of_turn = '1' then
                    next_state <= end_of_turn_state;
                else
                    next_state <= turn_state;
                end if;
            when end_of_turn_state =>
                if yamb = '1' then
                    next_state <= yamb_state;
                elsif button = '0' then
                    next_state <= turn_state;
                else
                    next_state <= end_of_turn_state;
                end if;
            when yamb_state =>
                if blink_counter < 4*C_SECOND - 2 then
                    next_state <= yamb_state;
                else
                    next_state <= initial_state;
                end if;
        end case;
    end process NEXT_STATE_LOGIC;
    
    -- Obezbedjivanje da masina bude u stanju yamb_state cetiri sekunde, odnosno
    -- onoliko vremena koliko je odredjeno da LE diode svetle.
    BLINK_CNT:process(clk)
    begin
        if rising_edge(clk) then
            if state_reg = yamb_state then
                blink_counter <= blink_counter + 1;
            else
                blink_counter <= 1;
            end if;
        end if;
    end process BLINK_CNT;
    
    -- Resetovanje kockica ce se izvrsiti ukoliko signal 'reset' ima aktivnu 
    -- vrednost ili ukoliko je naredno stanje u koje ce masina preci inicijalno.
    -- Masina u inicijalno stanje prelazi iz stanja yamb_state, ili samo prilikom
    -- aktiviranja reseta, stoga je potreban i ovaj drugi uslov u if petlji.
    RST_ROLL_DICES:process(reset,next_state)
    begin
        if reset = '1' or next_state = initial_state then
            rst <= '1';
        else
            rst <= '0';
        end if;
    end process RST_ROLL_DICES;
    
    -- Proces koji proverava da li je dobijen jamb.
    -- Dovoljno je proveriti uslove samo za dve cifre.
    -- Za prvu cifru ce postojati 5 nad 4 razlicitih kombinacija.
    -- Za drugu isto toliko, ali ce sve osim jedne vec biti ispitane u okviru
    -- ispitivanja kombinacija za prvu cifru.
    -- Sledi da je ukupan broj kombinacija koje treba ispitati 5+1=6.
    CHECK_YAMB:process(clk)
    begin
        if rising_edge(clk) then
            if state_reg = end_of_turn_state then
                if digit(0) = digit(1) and digit(0) = digit(2) and digit(0) = digit(3) and digit(0) = digit(4) then
                    yamb <= '1';
                elsif digit(0) = digit(5) and digit(0) = digit(2) and digit(0) = digit(3) and digit(0) = digit(4) then
                    yamb <= '1';
                elsif digit(0) = digit(1) and digit(0) = digit(5) and digit(0) = digit(3) and digit(0) = digit(4) then
                    yamb <= '1';
                elsif digit(0) = digit(1) and digit(0) = digit(2) and digit(0) = digit(5) and digit(0) = digit(4) then
                    yamb <= '1';
                elsif digit(0) = digit(1) and digit(0) = digit(2) and digit(0) = digit(3) and digit(0) = digit(5) then
                    yamb <= '1';
                elsif digit(1) = digit(2) and digit(1) = digit(3) and digit(1) = digit(4) and digit(1) = digit(5) then
                    yamb <= '1';
                else 
                    yamb <= '0';
                end if;
            end if;
        end if;
    end process CHECK_YAMB;
    
    -- Proces koji pali i gasi LE diode na svakih 0.2 sekunde.
    BLINK:process(clk,state_reg)
    begin
        if rising_edge(clk) and state_reg = yamb_state then
            if blink_period < C_0_2_SECOND and non_blink_period > 0 then
                le <= "1111111111";
                blink_period <= blink_period + 1;
                non_blink_period <= C_0_2_SECOND;
            elsif non_blink_period = 1 then
                    blink_period <= 1;
            else
                le <= "0000000000";
                non_blink_period <= non_blink_period - 1;
            end if;
        end if;
    end process BLINK;

end behavioral;