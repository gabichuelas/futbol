require_relative './readable'
require_relative './game'
require_relative './team'
require_relative './game_team'

class Statistics
  include Readable
  attr_reader :games, :teams, :game_teams

  def initialize(stat_tracker_params)
    games_path = stat_tracker_params[:games]
    teams_path = stat_tracker_params[:teams]
    game_teams_path = stat_tracker_params[:game_teams]

    @games ||= from_csv(games_path, Game)
    @teams ||= from_csv(teams_path, Team)
    @game_teams ||= from_csv(game_teams_path, GameTeam)
  end

  # we can add helper methods here for:
  # find_home_wins
  # find_visitor_wins
  # find_tied_games

  def find_team_by_id(id)
    @teams.find { |team| team.team_id == id }
  end

  def games_by_season
    @games.group_by { |game| game.season }
  end

  def total_goals(games_array)
    games_array.reduce(0) do |goals, game|
      goals += game.total_goals
    end
  end

  def find_games_for(team_id)
    @games.find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end
  end

  def results_by_team(team_id)
    games = find_games_for(team_id)
    games.reduce({}) do |acc, game|
      acc[team_id] ||= {won: 0, lost: 0, tied: 0}
      acc[team_id][:won] += 1 if game.winner == team_id
      acc[team_id][:lost] += 1 if game.loser == team_id
      acc[team_id][:tied] += 1 if game.result == :tie
      acc
    end
  end

  def results_by_opponent(team_id)
    games = find_games_for(team_id)
    games.reduce({}) do |acc, game|
      opponent = game.opponent(team_id)
      acc[opponent] ||= {won: 0, lost: 0, tied: 0}
      acc[opponent][:won] += 1 if game.winner == opponent
      acc[opponent][:lost] += 1 if game.loser == opponent
      acc[opponent][:tied] += 1 if game.result == :tie
      acc
    end
  end

  def win_percentage_by_opponent(team_id)
    opp_tallies = results_by_opponent(team_id)
    opp_tallies.reduce({}) do |acc, (opponent, tally_hash)|
      win_percentage = tally_hash[:won].fdiv(tally_hash.values.sum)
      acc[opponent] = win_percentage
      acc
    end
  end

  def win_percentage_by_team(team_id)
    game_tallies = results_by_team(team_id)
    game_tallies.reduce({}) do |acc, (team, tally_hash)|
      win_percentage = tally_hash[:won].fdiv(tally_hash.values.sum)
      acc[team] = win_percentage
      acc
    end
  end

  def team_results_by_season(team_id)
    games = find_games_for(team_id)
    games.reduce({}) do |acc, game|
      acc[game.season] ||= {won: 0, lost: 0, tied: 0}
      acc[game.season][:won] += 1 if game.winner == team_id
      acc[game.season][:lost] += 1 if game.loser == team_id
      acc[game.season][:tied] += 1 if game.result == :tie
      acc
    end
  end

  def win_percentage_by_season(team_id)
    season_tallies = team_results_by_season(team_id)
    season_tallies.reduce({}) do |acc, (season, tally_hash)|
      win_percentage = tally_hash[:won].fdiv(tally_hash.values.sum)
      acc[season] = win_percentage
      acc
    end
  end

end
