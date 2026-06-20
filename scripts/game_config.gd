extends Node
class_name GameConfig

# Records game mode and selected characters, tournament setup, and story selection
# if we ever add that.

enum GameMode {
	CLASSIC,
	CLASSIC_TAG,
	TOURNAMENT,
	TOURNAMENT_TAG
}

static var game_mode: GameMode
static var is_watch_mode: bool
static var player1_characters: Array[CharacterChoice] # of 1 in classic, 2 in tag
static var player2_characters: Array[CharacterChoice]
#var tournament_teams: Array # of arrays of characters (1 classic, 2 tag)

static var winner: int # 1 or 2
