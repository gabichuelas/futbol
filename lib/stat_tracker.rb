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

  def percentage_home_wins
    game_results[:home_win].count.fdiv(@games.count).round(2)
  end

  def percentage_visitor_wins
    game_results[:away_win].count.fdiv(@games.count).round(2)
  end

  def percentage_ties
    game_results[:tie].count.fdiv(@games.count).round(2)
  end

  def count_of_games_by_season
    games_by_season.transform_values { |games| games.count }
  end

  def find_all_games_total_score
    games.map {|game| game.total_goals }.sum
  end

  def average_goals_per_game
    find_all_games_total_score.fdiv(@games.count).round(2)
  end

  def average_goals_by_season
    games_by_season.transform_values do |games|
      total_goals(games).fdiv(games.count).round(2)
    end
  end
  # LEAGUE STATISTICS
  def count_of_teams
    @teams.count
  end

  def sort_scores_by_team(game_teams_collection)
    game_teams_collection.reduce({}) do |sorted_scores, game_team|
      sorted_scores[game_team.team_id] ||= []
      sorted_scores[game_team.team_id] << game_team.goals.to_i
      sorted_scores
    end
  end

  def team_averages(sorted_team_scores)
    sorted_team_scores.reduce({}) do |acc, (team, scores_array)|
      acc[team] = (scores_array.sum / scores_array.count.to_f)
      acc
    end
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
    id = team_accuracy(season).max_by { |team_id, acc| acc }[0]
    find_team_by_id(id).team_name
  end

  def least_accurate_team(season)
    id = team_accuracy(season).min_by { |team_id, acc| acc }[0]
    find_team_by_id(id).team_name
  end

  def most_tackles(season)
    id = team_tackles(season).max_by { |team_id, tackles| tackles }[0]
    find_team_by_id(id).team_name
  end

  def fewest_tackles(season)
    id = team_tackles(season).min_by { |team_id, tackles| tackles }[0]
    find_team_by_id(id).team_name
  end
  # TEAM STATISTICS
  def team_info(id)
    find_team_by_id(id).info
  end

  def best_season(team_id)
    value = win_percentage_by_season(team_id).values.max
    win_percentage_by_season(team_id).key(value)
  end

  def worst_season(team_id)
    value = win_percentage_by_season(team_id).values.min
    win_percentage_by_season(team_id).key(value)
  end

  def average_win_percentage(team_id)
    win_percentage_by_team(team_id)[team_id].round(2)
  end

  def most_goals_scored(team_id)
    goals_scored_by(team_id).max
  end

  def fewest_goals_scored(team_id)
    goals_scored_by(team_id).min
  end

  def favorite_opponent(team_id)
    value = win_percentage_by_opponent(team_id).values.min
    team_id = win_percentage_by_opponent(team_id).key(value)
    find_team_by_id(team_id).team_name
  end

  def rival(team_id)
    value = win_percentage_by_opponent(team_id).values.max
    team_id = win_percentage_by_opponent(team_id).key(value)
    find_team_by_id(team_id).team_name
  end
end
