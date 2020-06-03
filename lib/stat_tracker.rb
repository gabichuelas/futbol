require_relative './statistics'

class StatTracker < Statistics

  def initialize(stat_tracker_params)
    super(stat_tracker_params)
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

  def find_game_teams_by_hoa_and_result(hoa, result)
    game_teams.find_all do |game_team|
      game_team.hoa == hoa && game_team.result == result
    end
  end

  def percentage_home_wins
    home_wins = find_game_teams_by_hoa_and_result("home", "WIN")
    (home_wins.count.fdiv(game_teams.count / 2)).round(2)
  end

  def percentage_visitor_wins
    away_wins = find_game_teams_by_hoa_and_result("away", "WIN")
    (away_wins.count.fdiv(game_teams.count / 2)).round(2)
  end

  def find_tied_games
    games.find_all do |game|
      game.result == :tie
    end
  end

  def percentage_ties
    (find_tied_games.count.fdiv(games.count)).round(2)
  end

  def count_of_games_by_season
    games_by_season.reduce({}) do |season_games, (season, games)|
      season_games[season] = games.count
      season_games
    end
  end

  def find_all_games_total_score
    games.map {|game| game.total_goals }.sum
  end

  def average_goals_per_game
    (find_all_games_total_score.fdiv(games.count)).round(2)
  end

  def average_goals_by_season
    games_by_season.reduce({}) do |acc, (season, games)|
      acc[season] = total_goals(games).fdiv(games.count).round(2)
      acc
    end
  end

  # LEAGUE STATISTICS

  def count_of_teams
    teams.count
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

  def team_with_highest_average_score(team_averages)
    team_averages.max_by { |_team, avg_score| avg_score }.first
  end

  def team_with_lowest_average_score(team_averages)
    team_averages.min_by { |_team, avg_score| avg_score }.first
  end

  def best_offense
    team_avgs = team_averages(sort_scores_by_team(@game_teams))
    find_team_by_id(team_with_highest_average_score(team_avgs)).team_name
  end

  def worst_offense
    team_avgs = team_averages(sort_scores_by_team(@game_teams))
    find_team_by_id(team_with_lowest_average_score(team_avgs)).team_name
  end

  def find_game_teams_by_hoa(hoa)
    @game_teams.find_all do |game_team|
      game_team.hoa == hoa
    end
  end

  def highest_scoring_visitor
    away_teams = find_game_teams_by_hoa("away")
    sorted_away_team_scores = sort_scores_by_team(away_teams)
    team_avgs = team_averages(sorted_away_team_scores)
    find_team_by_id(team_with_highest_average_score(team_avgs)).team_name
  end

  def highest_scoring_home_team
    home_teams = find_game_teams_by_hoa("home")
    sorted_home_team_scores = sort_scores_by_team(home_teams)
    team_avgs = team_averages(sorted_home_team_scores)
    find_team_by_id(team_with_highest_average_score(team_avgs)).team_name
  end

  def lowest_scoring_visitor
    away_teams = find_game_teams_by_hoa("away")
    sorted_away_team_scores = sort_scores_by_team(away_teams)
    team_avgs = team_averages(sorted_away_team_scores)
    find_team_by_id(team_with_lowest_average_score(team_avgs)).team_name
  end

  def lowest_scoring_home_team
    home_teams = find_game_teams_by_hoa("home")
    sorted_home_team_scores = sort_scores_by_team(home_teams)
    team_avgs = team_averages(sorted_home_team_scores)
    find_team_by_id(team_with_lowest_average_score(team_avgs)).team_name
  end

  # SEASON STATISTICS
  def winningest_coach(season)
    coach_win_percentage(season).max_by { |coach, record| record }[0]
  end

  def worst_coach(season)
    coach_win_percentage(season).min_by { |coach, record| record }[0]
  end

  def most_accurate_team(season)
    most_accurate_team_id = team_accuracy(season).max_by { |team_id, acc| acc }[0]
    teams.find { |team| team.team_id == most_accurate_team_id }.team_name
  end

  def least_accurate_team(season)
    least_accurate_team_id = team_accuracy(season).min_by { |team_id, acc| acc }[0]
    teams.find { |team| team.team_id == least_accurate_team_id }.team_name
  end

  def most_tackles(season)
    most_tackles_team_id = team_tackles(season).max_by { |team_id, tackles| tackles }[0]
    teams.find { |team| team.team_id == most_tackles_team_id }.team_name
  end

  def fewest_tackles(season)
    fewest_tackles_team_id = team_tackles(season).min_by { |team_id, tackles| tackles }[0]
    teams.find { |team| team.team_id == fewest_tackles_team_id }.team_name
  end

  # season stats helper methods ------------------

  def coach_stats(season)
    game_teams_by_coach(season).reduce({}) do |acc, (coach, game_teams)|
      wins = game_teams.find_all {|game| game.result == "WIN"}.count
      acc[coach] ||= {wins: 0, games: 0}
      acc[coach][:wins] = wins
      acc[coach][:games] = game_teams.count
      acc
    end
  end

  def coach_win_percentage(season)
    coach_stats(season).reduce({}) do |acc, (coach, stats)|
      acc[coach] = stats[:wins].fdiv(stats[:games])
      acc
    end
  end

  def team_accuracy(season)
    season_team_accuracy = Hash.new { |h,k| h[k] = Hash.new(0) }
    game_teams_by_season(season).each do |game_team|
      season_team_accuracy[game_team.team_id][:shots] += game_team.shots.to_i
      season_team_accuracy[game_team.team_id][:goals] += game_team.goals.to_i
    end

    team_accuracy = {}
    season_team_accuracy.each do |team_id, stats|
      team_accuracy[team_id] = stats[:goals].fdiv(stats[:shots])
    end
    team_accuracy
  end

  def team_tackles(season)
    game_teams_by_season(season).inject(Hash.new(0)) do |team_tackles, game_team|
      team_tackles[game_team.team_id] += game_team.tackles.to_i
      team_tackles
    end
  end

  # TEAM STATISTICS
  def team_info(id)
    find_team_by_id(id).info
  end

  def best_season(team_id)
    win_percentage_by_season(team_id).max_by do |season, percentage|
      percentage
    end[0]
  end

  def worst_season(team_id)
    win_percentage_by_season(team_id).min_by do |season, percentage|
      percentage
    end[0]
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
