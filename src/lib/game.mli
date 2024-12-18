open Grid
open Words

module Game : sig
  type config = {
  board: Grid.t;  
  word_coords: WordCoords.t;  
  spangram : string;
  theme: string
 }

  (** [initialize_game config] initializes the game config *)
  val initialize_game : config -> config

  (** [check_word word coords config] checks if a given word at the specified
    coordinates matches the valid words on the board*)
  val check_word : string -> (int * int ) list -> config -> bool


end