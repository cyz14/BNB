
## CONSTANT
  Screen Display Size:    640 * 480
  Map_Size:               15(*15)
  Tile_Size:              32(*32)


## map_rom.vhd
  ENTITY map_rom IS PORT(
      clock:			IN  STD_LOGIC;
      tile_X:			IN  STD_LOGIC_VECTOR(3 downto 0); -- max: 15
      tile_Y:			IN  STD_LOGIC_VECTOR(3 downto 0); -- max: 15
      data:				OUT STD_LOGIC_VECTOR(2 downto 0)
    );
  END;

  SIGNAL addr: STD_LOGIC_VECTOR(8 downto 0);  -- tile_Y & tile_X
  SUBTYPE map_tile IS integer RANGE 0 TO 7;
  TYPE rom_type IS ARRAY(0 TO 256) OF map_tile;
  CONSTANT rom: rom_type :=
  (
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  );
BEGIN
  addr <= tile_Y & tile_X;
END;

## video_sync.vhd
  ENTITY video_sync IS PORT(
      clock:									IN STD_LOGIC;	-- should be 25M Hz
      video_on, Horiz_Sync, Vert_Sync:	OUT STD_LOGIC;
      H_count_out, V_count_out:			OUT STD_LOGIC_VECTOR(9 downto 0)    
    );
  END;

## draw_map.vhd


## draw_sprite.vhd
  ENTITY draw_sprite IS PORT (
    world_X, world_Y:   IN STD_LOGIC_VECTOR(8 downto 0);
    sprite_X, sprite_Y: IN STD_LOGIC_VECTOR(8 downto 0);
    active:             OUT STD_LOGIC
    );
  END;

## draw_bubble.vhd
  ENTITY draw_bubble IS PORT(
    world_X, world_Y:     IN STD_LOGIC_VECTOR(8 downto 0);
    bubble_X, bubble_Y:   IN STD_LOGIC_VECTOR(8 downto 0);
    active:               OUT STD_LOGIC
    );
  END;

## draw_explosion.vhd
  ENTITY draw_explosion IS PORT(
    world_X, world_Y:   IN STD_LOGIC_VECTOR(8 downto 0);
    explo_X, explo_Y:   IN STD_LOGIC_VECTOR(8 downto 0);
    active:             OUT STD_LOGIC
    );
  END;


## map_rom.vhd
  ENTITY map_rom IS PORT(
      clock:          IN STD_LOGIC;
      tile_X:         IN STD_LOGIC_VECTOR(4 downto 0);
      tile_Y:         IN STD_LOGIC_VECTOR(4 downto 0);
      data:           OUT STD_LOGIC_VECTOR(2 downto 0)
    );
  END;
