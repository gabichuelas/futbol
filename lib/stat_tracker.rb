require_relative './readable'
require_relative './game'
require_relative './team'
require_relative './game_team'

class StatTracker
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

  def self.from_csv(stat_tracker_params)
    StatTracker.new(stat_tracker_params)
  end

  # GAME STATISTICS

  def highest_total_score
    games.max_by { |game| game.total_goals }.total_goals
  end

  def lowest_total_score
    games.min_by { |game| game.total_goals }.total_goals
  end

  def find_home_wins
    game_teams.find_all do |game_team|
      game_team.hoa == "home" && game_team.result == "WIN"
    end
  end

  def percentage_home_wins
    percentage = find_home_wins.count.fdiv(game_teams.count / 2)
    percentage.round(2)
  end

  def find_visitor_wins
    game_teams.find_all do |game_team|
      game_team.hoa == "away" && game_team.result == "WIN"
    end
  end

  def percentage_visitor_wins
    percentage = find_visitor_wins.count.fdiv(game_teams.count / 2)
    percentage.round(2)
  end

  def find_tied_games
    games.find_all do |game|
      game.away_goals == game.home_goals
    end
  end

  def percentage_ties
    percentage = find_tied_games.count.fdiv(games.count)
    percentage.round(2)
  end

  def count_of_games_by_season
    all_games_by_season_id = @games.group_by do |game|
      game.season
    end

    all_games_by_season_id.reduce({}) do |games_by_season, (season, games)|
      games_by_season[season] = games.count
      games_by_season
    end
  end

  def find_all_games_total_score
    all_goals = 0
    games.each do |game|
      all_goals += game.away_goals.to_i + game.home_goals.to_i
    end
    all_goals
  end

  def average_goals_per_game
    percentage = find_all_games_total_score / games.count.to_f
    percentage.round(2)
  end

  def average_goals_by_season
    all_games_by_season_id = @games.group_by do |game|
      game.season
    end

    all_games_by_season_id.reduce({}) do |games_by_season, (season, games)|
      total_goals = 0
      games.each do |game|
        total_goals += game.away_goals.to_f + game.home_goals.to_f
      end

      games_by_season[season] = (total_goals / games.count.to_f).round(2)
      # require 'pry';binding.pry
      games_by_season
    end
  end

  # LEAGUE STATISTICS
  def count_of_teams
    teams.count
  end

  def find_team_by_id(id)
    @teams.find do |team|
      team.team_id == id
    end
  end

  def scores_by_team
    game_teams.reduce({}) do |team_scores, game|
      if team_scores[game.team_id].nil?
        team_scores[game.team_id] = [game.goals.to_i]
      else
        team_scores[game.team_id] << game.goals.to_i
      end
      team_scores
    end
  end

  def average_scores_by_team
    avgs_by_team = {}
    scores_by_team.each do |team, scores_array|
      avgs_by_team[team] = (scores_array.sum / scores_array.count.to_f)
    end
    avgs_by_team
  end

  def best_offense
    highest_avg_score = average_scores_by_team.max_by do |_team, avg_score|
      avg_score
    end
    find_team_by_id(highest_avg_score.first).team_name
  end

  def worst_offense
    lowest_avg_score = average_scores_by_team.min_by do |_team, avg_score|
      avg_score
    end
    find_team_by_id(lowest_avg_score.first).team_name
  end

  def highest_scoring_visitor # reconsider local variable names in this method
    # and how to better set up average_scores_by_team method to be able to be
    # resued by multiple methods and take an argument of varying subsets of teams
    away_teams = @game_teams.find_all do |game_team|
      game_team.hoa == "away"
    end

    sorted_away_teams = away_teams.reduce({}) do |team_scores, game|
      if team_scores[game.team_id].nil?
        team_scores[game.team_id] = [game.goals.to_i]
      else
        team_scores[game.team_id] << game.goals.to_i
      end
      team_scores
    end

    avgs_by_team = {}
    sorted_away_teams.each do |visiting_team_id, scores_array|
      avgs_by_team[visiting_team_id] = (scores_array.sum / scores_array.count.to_f)
    end

    highest_scoring_visitor_id = avgs_by_team.max_by do |_visiting_team_id, avg_score|
      avg_score
    end.first

    find_team_by_id(highest_scoring_visitor_id).team_name
  end

  def highest_scoring_home_team
    home_teams = @game_teams.find_all do |game_team|
      game_team.hoa == "home"
    end

    sorted_home_teams = home_teams.reduce({}) do |team_scores, game|
      if team_scores[game.team_id].nil?
        team_scores[game.team_id] = [game.goals.to_i]
      else
        team_scores[game.team_id] << game.goals.to_i
      end
      team_scores
    end

    avgs_by_team = {}
    sorted_home_teams.each do |home_team_id, scores_array|
      avgs_by_team[home_team_id] = (scores_array.sum / scores_array.count.to_f)
    end

    highest_scoring_home_id = avgs_by_team.max_by do |_visiting_team_id, avg_score|
      avg_score
    end.first

    find_team_by_id(highest_scoring_home_id).team_name
  end

  def lowest_scoring_visitor
    away_teams = @game_teams.find_all do |game_team|
      game_team.hoa == "away"
    end

    sorted_away_teams = away_teams.reduce({}) do |team_scores, game|
      if team_scores[game.team_id].nil?
        team_scores[game.team_id] = [game.goals.to_i]
      else
        team_scores[game.team_id] << game.goals.to_i
      end
      team_scores
    end

    avgs_by_team = {}
    sorted_away_teams.each do |visiting_team_id, scores_array|
      avgs_by_team[visiting_team_id] = (scores_array.sum / scores_array.count.to_f)
    end

    lowest_scoring_visitor_id = avgs_by_team.min_by do |_visiting_team_id, avg_score|
      avg_score
    end.first

    find_team_by_id(lowest_scoring_visitor_id).team_name
  end

  def lowest_scoring_home_team
    home_teams = @game_teams.find_all do |game_team|
      game_team.hoa == "home"
    end

    sorted_home_teams = home_teams.reduce({}) do |team_scores, game|
      if team_scores[game.team_id].nil?
        team_scores[game.team_id] = [game.goals.to_i]
      else
        team_scores[game.team_id] << game.goals.to_i
      end
      team_scores
    end

    avgs_by_team = {}
    sorted_home_teams.each do |home_team_id, scores_array|
      avgs_by_team[home_team_id] = (scores_array.sum / scores_array.count.to_f)
    end

    lowest_scoring_home_id = avgs_by_team.min_by do |_visiting_team_id, avg_score|
      avg_score
    end.first

    find_team_by_id(lowest_scoring_home_id).team_name
  end

  # SEASON STATISTICS
  def games_by_season(season)
    games.find_all { |game| game.season == season }
  end

  def winningest_coach(season)
    #season_games_by_id returns an array of just season game ids
    season_game_ids = games_by_season(season).map do |game|
      game.game_id
    end

    #then find all games in game_teams from the above season
    season_games = game_teams.find_all do |game|
    season_game_ids.include?(game.game_id)
    end

    # filter season games by wins
    wins = season_games.find_all do |game|
    game.result == "WIN"
    end

    # returns an array of coach name for each win
    coach_wins = wins.map do |game|
    game.head_coach
    end

    # creates a hash of number of season games won by coach
    wins_by_coach = coach_wins.inject(Hash.new(0)) do |wins_by_coach, coach|
       wins_by_coach[coach] += 1; wins_by_coach
     end

    #return the winningest head_coach name as a string
    coach_wins.max_by { |coach| wins_by_coach[coach] }
  end

  def worst_coach(season)
    season_game_ids = games_by_season(season).map do |game|
      game.game_id
    end

    season_games = game_teams.find_all do |game|
    season_game_ids.include?(game.game_id)
    end

    losses = season_games.find_all do |game|
    game.result == "LOSS"
    end

    coach_losses = losses.map do |game|
    game.head_coach
    end

    losses_by_coach = coach_losses.inject(Hash.new(0)) do |losses_by_coach, coach|
       losses_by_coach[coach] += 1; losses_by_coach
     end

    coach_losses.max_by { |coach| losses_by_coach[coach] }
  end

  # def most_accurate_team(season)
  #
  # end

  # least_accurate_team(season)

  # most_tackles(season)

  # fewest_tackles(season)

  # TEAM STATISTICS

  def team_info(id)
    teams.find do |team|
      team.team_id == id
    end.info
  end

  def best_season(team_id)
    season = games_won_by_season(team_id).max_by do |season, games|
      games.count
    end
    season[0]
  end

  def worst_season(team_id)
    season = games_lost_by_season(team_id).max_by do |season, games|
      games.count
    end
    season[0]
  end

  def average_win_percentage(team_id)
    win_percentage_by_team(team_id)[team_id].round(2)
  end

  def most_goals_scored(team_id)
    game_teams.reduce([]) do |scores, game_team|
      scores << game_team.goals.to_i if game_team.team_id == team_id
      scores
    end.max
  end

  def fewest_goals_scored(team_id)
    game_teams.reduce([]) do |scores, game_team|
      scores << game_team.goals.to_i if game_team.team_id == team_id
      scores
    end.min
  end

  def favorite_opponent(team_id)
    opp_id = win_percentage_by_opponent(team_id).min_by do |opponent, win_percentage|
      win_percentage
    end

    find_team_by_id(opp_id[0]).team_name
  end

  def rival(team_id)
    opp_id = win_percentage_by_opponent(team_id).max_by do |opponent, win_percentage|
      win_percentage
    end

    find_team_by_id(opp_id[0]).team_name
  end

  # Helper Methods----------------------

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

  # -------------------------------------

  def game_teams_by(team_id)
    # returns matching GameTeams
    @game_teams.find_all do |game_team|
      game_team.team_id == team_id
    end
  end

  def game_ids_by(team_id, result)
    # returns array of game_ids
    from_game_teams = game_teams_by(team_id).find_all do |game_team|
      game_team.result == result
    end
    from_game_teams.map do |game_team|
      game_team.game_id
    end
  end

  def games_by(game_ids_array)
    # cross references array of game_ids with Games
    @games.find_all do |game|
      game_ids_array.include?(game.game_id)
    end
  end

  def total_games_by(team_id)
    game_teams_by(team_id).count
  end

  def games_won_by(team_id)
    game_ids = game_ids_by(team_id, "WIN")
    games_by(game_ids)
  end

  def games_lost_by(team_id)
    game_ids = game_ids_by(team_id, "LOSS")
    games_by(game_ids)
  end

  def games_won_by_season(team_id)
    games_won_by(team_id).group_by do |game|
      game.season
    end
  end

  def games_lost_by_season(team_id)
    games_lost_by(team_id).group_by do |game|
      game.season
    end
  end

end
