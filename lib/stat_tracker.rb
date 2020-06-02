require_relative './readable'
require_relative './team_stats_module'
require_relative './game'
require_relative './team'
require_relative './game_team'

class StatTracker
  include Readable
  include TeamStats

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

    all_games_by_season_id.reduce({}) do |season_games, (season, games)|
      season_games[season] = games.count
      season_games
    end
  end

  def find_all_games_total_score
    games.map {|game| game.total_goals }.sum
  end

  def average_goals_per_game
    (find_all_games_total_score / games.count.to_f).round(2)
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
  # season stats helper methods -------------------
  def season_games(season)
    games.find_all { |game| game.season == season }
  end
  #-----------------------------

  def winningest_coach(season)
    season_game_ids = season_games(season).map do |game|
      game.game_id
    end

    season_game_teams = game_teams.find_all do |game|
      season_game_ids.include?(game.game_id)
    end

    game_teams_by_coach = season_game_teams.group_by do |game_team|
      game_team.head_coach
    end

    coach_games_and_wins = Hash.new { |h,k| h[k] = Hash.new(0) }

    game_teams_by_coach.each do |coach, game_teams|
      coach_games_and_wins[coach][:games] = game_teams.count
      coach_games_and_wins[coach][:wins] = game_teams.find_all { |game| game.result == "WIN"}.count
    end

    coach_win_percentage = {}
    coach_games_and_wins.each do |coach, stats|
      coach_win_percentage[coach] = stats[:wins].fdiv(stats[:games])
    end

    coach_win_percentage.max_by { |coach, record| record }[0]
  end

  def worst_coach(season)
    season_game_ids = season_games(season).map do |game|
      game.game_id
    end

    season_game_teams = game_teams.find_all do |game|
      season_game_ids.include?(game.game_id)
    end

    game_teams_by_coach = season_game_teams.group_by do |game_team|
      game_team.head_coach
    end

    coach_games_and_wins = Hash.new { |h,k| h[k] = Hash.new(0) }

    game_teams_by_coach.each do |coach, game_teams|
      coach_games_and_wins[coach][:games] = game_teams.count
      coach_games_and_wins[coach][:wins] = game_teams.find_all { |game| game.result == "WIN"}.count
    end

    coach_win_percentage = {}
    coach_games_and_wins.each do |coach, stats|
      coach_win_percentage[coach] = stats[:wins].fdiv(stats[:games])
    end

    coach_win_percentage.min_by { |coach, record| record }[0]
  end

  def most_accurate_team(season)
    season_game_ids = season_games(season).map do |game|
      game.game_id
    end

    season_game_teams = game_teams.find_all do |game|
      season_game_ids.include?(game.game_id)
    end

    season_team_accuracy = Hash.new { |h,k| h[k] = Hash.new(0) }
    season_game_teams.each do |game_team|
      season_team_accuracy[game_team.team_id][:shots] += game_team.shots.to_i
      season_team_accuracy[game_team.team_id][:goals] += game_team.goals.to_i
    end

    team_accuracy = {}
    season_team_accuracy.each do |team_id, stats|
      team_accuracy[team_id] = stats[:goals].fdiv(stats[:shots])
    end

    most_accurate_team_id = team_accuracy.max_by { |team_id, acc| acc }[0]

    teams.find { |team| team.team_id == most_accurate_team_id }.team_name
  end

  def least_accurate_team(season)
    season_game_ids = season_games(season).map do |game|
      game.game_id
    end

    season_game_teams = game_teams.find_all do |game|
      season_game_ids.include?(game.game_id)
    end

    season_team_accuracy = Hash.new { |h,k| h[k] = Hash.new(0) }
    season_game_teams.each do |game_team|
      season_team_accuracy[game_team.team_id][:shots] += game_team.shots.to_i
      season_team_accuracy[game_team.team_id][:goals] += game_team.goals.to_i
    end

    team_accuracy = {}
    season_team_accuracy.each do |team_id, stats|
      team_accuracy[team_id] = stats[:goals].fdiv(stats[:shots])
    end

    least_accurate_team_id = team_accuracy.min_by { |team_id, acc| acc }[0]

    teams.find { |team| team.team_id == least_accurate_team_id }.team_name
  end

  def most_tackles(season)
    season_game_ids = season_games(season).map do |game|
      game.game_id
    end

    season_game_teams = game_teams.find_all do |game|
      season_game_ids.include?(game.game_id)
    end

    season_team_tackles = season_game_teams.inject(Hash.new(0)) do |team_tackles, game_team|
      team_tackles[game_team.team_id] += game_team.tackles.to_i
      team_tackles
    end

    most_tackles_team_id = season_team_tackles.max_by { |team_id, tackles| tackles }[0]

    teams.find { |team| team.team_id == most_tackles_team_id }.team_name
  end

  def fewest_tackles(season)
    season_game_ids = season_games(season).map do |game|
      game.game_id
    end

    season_game_teams = game_teams.find_all do |game|
      season_game_ids.include?(game.game_id)
    end

    season_team_tackles = season_game_teams.inject(Hash.new(0)) do |team_tackles, game_team|
      team_tackles[game_team.team_id] += game_team.tackles.to_i
      team_tackles
    end

    fewest_tackles_team_id = season_team_tackles.min_by { |team_id, tackles| tackles }[0]

    teams.find { |team| team.team_id == fewest_tackles_team_id }.team_name
  end

  # TEAM STATISTICS
  # Uses helper methods from TeamStats module

  def team_info(id)
    teams.find do |team|
      team.team_id == id
    end.info
  end

  def best_season(team_id)
    best_season = win_percentage_by_season(team_id).max_by do |season, percentage|
      percentage
    end
    best_season[0]
  end

  def worst_season(team_id)
    worst_season = win_percentage_by_season(team_id).min_by do |season, percentage|
      percentage
    end
    worst_season[0]
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

end
