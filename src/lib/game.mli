open Grid
open Words

module Game : sig
  type config = {
  board: Grid.t;  
  word_coords: WordCoords.t;  
  word_records: WordRecord.t; 
  spangram : string;
  theme: string
 }

  (** [initialize_game config] initializes the game config *)
  val initialize_game : config -> config

  (** [check_word word coords config] checks if a given word at the specified
    coordinates matches the valid words on the board*)
  val check_word : string -> (int * int ) list -> config -> bool

  (** [set_found word state] updates the game state to mark the given word as found *)
  val set_found : string -> config -> config

end