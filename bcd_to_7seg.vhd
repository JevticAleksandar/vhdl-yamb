-- Copyright Aleksandar Jevtic.

--****************************************
-- This file contains a Vhdl
-- design for BCD to 7 segment display
-- 3x8 decoder.
-- Comments are provided in each section
-- to help the user understand.
--****************************************
-- Generated on "12/25/2020"

library ieee;
use ieee.std_logic_1164.all;

--*************************************************************************
-- Entity for BCD to 7 segment display 3x8 decoder is named 'bcd_to_7seg'.
--*************************************************************************

-----------------------------------------------------------
-- Na ulazne portove se dovodi 3-bitna cifra. 
-- 3 bita su dovoljna za prikaz svih cifara koje se nalaze 
-- u opsegu 0 do 6.
-- Na izlazni port se salje 7-bitni signal 'display'. 
-- Tih 7 bita se povezuje na sedmosegmentni displej.
-----------------------------------------------------------
entity bcd_to_7seg is
port(
    digit : in std_logic_vector(2 downto 0);
    display : out std_logic_vector(6 downto 0)
);
end bcd_to_7seg;

--*********************************************
-- Behavoiral of BCD to 7 segment 3x8 decoder.
--*********************************************
-----------------------------------------------------------
-- logicka '0' aktivira odgovarajuci segment na displeju.
-- logicka '1' predstavlja neaktivnu vrednost segmenta.
-- U sensitivity listi je ulazni signal iz razloga sto
-- izlaz zavisi samo od ulaza i menja se sa promenom ulaza.
-- Error ('E') ce biti prikazan na displeju ukoliko
-- ulazna cifra nije u opsegu 0 do 6.
------------------------------------------------------------

architecture behavioral of bcd_to_7seg is
begin
    process(digit)
    begin
        case digit is
            when "000" => display <= "1000000";
            when "001" => display <= "1111001";
            when "010" => display <= "0100100";
            when "011" => display <= "0110000";
            when "100" => display <= "0011001";
            when "101" => display <= "0010010";
            when "110" => display <= "0000010";
            when others => display <= "0000110";
        end case;
    end process;
end behavioral;