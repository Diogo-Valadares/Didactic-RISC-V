library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity irReceiver is
    Port ( 
        clk_50   : in  std_logic;
        irSignal : in  std_logic;
        dataCode : out std_logic_vector (7 downto 0) := (others => '0');
        valid    : out std_logic := '0';
        
        -- Debug signals for SignalTap
        debug_ir       : out std_logic;
        debug_address  : out std_logic_vector(15 downto 0);
        debug_bitcount : out std_logic_vector(5 downto 0);
        debug_counter  : out std_logic_vector(19 downto 0);
        debug_state    : out std_logic_vector(2 downto 0)
    );
end irReceiver;

architecture Behavioral of irReceiver is
    -- States
    TYPE estados is (idle, start, decoding, finish);
    SIGNAL ep : estados := idle;
    SIGNAL es : estados;

    -- Control signals
    SIGNAL started : std_logic := '0';
    SIGNAL decoded : std_logic := '0';
    SIGNAL failled : std_logic := '0';
    SIGNAL success : std_logic := '0';
    
    -- Counters
    SIGNAL cycleCounter : integer range 0 to 499999 := 0;
    SIGNAL NB           : integer range -1 to 32 := -1;
    
    -- Auxiliary signals
    SIGNAL myData  : std_logic_vector (31 downto 0) := (others => '0');
    SIGNAL stored  : std_logic := '0';
    
    -- IR signal synchronization
    SIGNAL irSync : std_logic := '1';
    SIGNAL irPrev : std_logic := '1';
    
    -- Internal debug signals
    SIGNAL dbg_state : std_logic_vector(2 downto 0);

begin
    -- Synchronize IR signal
    process(clk_50)
    begin
        if rising_edge(clk_50) then
            irPrev <= irSync;
            irSync <= irSignal;
        end if;
    end process;

    -- Map debug signals to outputs
    debug_ir <= irSync;
    debug_address <= myData(31 downto 16);
    debug_bitcount <= std_logic_vector(to_unsigned(NB, 6)) when NB >= 0 else (others => '0');
    debug_counter <= std_logic_vector(to_unsigned(cycleCounter, 20));
    debug_state <= dbg_state;

    -- State encoding for debugging
    with ep select dbg_state <=
        "000" when idle,
        "001" when start,
        "010" when decoding,
        "011" when finish;

    -- State machine (Control Unit)
    process(ep, irSync, started, decoded, failled, success)
    begin
        CASE ep IS
            WHEN idle =>
                IF(irSync = '0' and started = '0') THEN
                    es <= start;
                ELSE
                    es <= idle;
                END IF;
                
            WHEN start =>
                IF(irSync = '1' and started = '1') THEN
                    es <= decoding;
                ELSIF(failled = '1') THEN
                    es <= idle;
                ELSE                    
                    es <= start;
                END IF;
                
            WHEN decoding =>
                IF(decoded = '1') THEN
                    es <= finish;
                ELSIF(failled = '1') THEN
                    es <= idle;
                ELSE
                    es <= decoding;
                END IF;
                
            WHEN finish =>
                IF(success = '1') THEN
                    es <= idle;
                ELSE
                    es <= finish;
                END IF;
        END CASE;
    end process;
            
    ep <= es;
    
    -- Process unit
    process(clk_50)
    begin
        if rising_edge(clk_50) then
            valid <= '0';
            
            if ep = idle then
                -- Reset counters and control signals
                cycleCounter <= 0;
                NB <= -1;
                failled <= '0';
                started <= '0';
                decoded <= '0';
                success <= '0';
                stored <= '0';
                
            elsif ep = start then
                -- Check for start pulse (9ms low for NEC)
                if cycleCounter < 450000 then  -- 9ms @ 50MHz
                    cycleCounter <= cycleCounter + 1;
                    
                    -- If start condition is interrupted, fail
                    if cycleCounter < 400000 and irSync = '1' then
                        failled <= '1';
                    end if;
                else
                    -- Start condition met
                    started <= '1';
                    cycleCounter <= 0;
                end if;
                
            elsif ep = decoding then
                -- Read data
                if NB < 32 then
                    -- Measure pulse duration
                    if irSync = '0' then
                        stored <= '0';
                        cycleCounter <= cycleCounter + 1;
                    else
                        -- Store bit value based on pulse duration
                        if stored = '0' then
                            if NB > -1 then
                                -- Adjust timing thresholds based on your SignalTap data
                                if cycleCounter > 100000 then  -- Increased threshold
                                    myData(NB) <= '1';
                                else
                                    myData(NB) <= '0';
                                end if;
                            end if;
                            NB <= NB + 1;
                            cycleCounter <= 0;
                            stored <= '1';
                        end if;
                    end if;
                else
                    decoded <= '1';
                end if;
                
            elsif ep = finish then
                -- Extract data code (don't validate address for now)
                dataCode <= myData(15 downto 8);  -- Command byte
                valid <= '1';
                success <= '1';
            end if;        
        end if;
    end process;
end Behavioral;