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

    @games = from_csv(games_path, Game)
    @teams = from_csv(teams_path, Team)
    @game_teams = from_csv(game_teams_path, GameTeam)
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

  def sort_scores_by_team(game_teams_collection)
    game_teams_collection.reduce({}) do |sorted_scores, game_team|
      sorted_scores[game_team.team_id] ||= []
      sorted_scores[game_team.team_id] << game_team.goals.to_i
      sorted_scores
    end
  end

  def team_averages(sorted_team_scores)
    avgs_by_team = {}
    sorted_team_scores.each do |team, scores_array|
      avgs_by_team[team] = (scores_array.sum / scores_array.count.to_f)
    end
    avgs_by_team
  end

  def team_with_highest_average_score(team_averages) # better name??
    team_averages.max_by { |_team, avg_score| avg_score }.first
  end

  def team_with_lowest_average_score(team_averages) # ^^
    team_averages.min_by { |_team, avg_score| avg_score }.first
  end

  # consider combining above two methods taking an addtl arg for max_by or min_by

  def best_offense
    team_avgs = team_averages(sort_scores_by_team(@game_teams))
    find_team_by_id(team_with_highest_average_score(team_avgs)).team_name
  end

  def worst_offense
    team_avgs = team_averages(sort_scores_by_team(@game_teams))
    find_team_by_id(team_with_lowest_average_score(team_avgs)).team_name
  end

  def find_game_teams(home_or_away)
    @game_teams.find_all do |game_team|
      game_team.hoa == home_or_away
    end
  end

  def highest_scoring_visitor
    away_teams = find_game_teams("away")
    sorted_away_team_scores = sort_scores_by_team(away_teams)
    team_avgs = team_averages(sorted_away_team_scores)
    find_team_by_id(team_with_highest_average_score(team_avgs)).team_name
  end

  def highest_scoring_home_team
    home_teams = find_game_teams("home")
    sorted_home_team_scores = sort_scores_by_team(home_teams)
    team_avgs = team_averages(sorted_home_team_scores)
    find_team_by_id(team_with_highest_average_score(team_avgs)).team_name
  end

  def lowest_scoring_visitor
    away_teams = find_game_teams("away")
    sorted_away_team_scores = sort_scores_by_team(away_teams)
    team_avgs = team_averages(sorted_away_team_scores)
    find_team_by_id(team_with_lowest_average_score(team_avgs)).team_name
  end

  def lowest_scoring_home_team
    home_teams = find_game_teams("home")
    sorted_home_team_scores = sort_scores_by_team(home_teams)
    team_avgs = team_averages(sorted_home_team_scores)
    find_team_by_id(team_with_lowest_average_score(team_avgs)).team_name
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
    games_won_by(team_id).count.fdiv(total_games_by(team_id)).round(2)
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

  def favorite_opponent
  end

  def rival
  end

  # Helper Methods----------------------

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
