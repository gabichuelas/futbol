require './test/setup'
require './lib/game'
require './lib/team'
require './lib/game_team'
require './lib/stat_tracker'

class StatTrackerTest < Minitest::Test
  def setup
    game_path = './fixtures/games_fixture.csv'
    team_path = './fixtures/teams_fixture.csv'
    game_teams_path = './fixtures/game_teams_fixture.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    @stat_tracker = StatTracker.from_csv(locations)
  end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end

  def test_it_has_games
    assert_instance_of Game, @stat_tracker.games.first
    assert_equal "2012030221", @stat_tracker.games.first.game_id
    assert_equal "20122013", @stat_tracker.games.first.season
    assert_equal "3", @stat_tracker.games.first.away_team_id
    assert_equal "6", @stat_tracker.games.first.home_team_id
  end

  def test_it_has_teams
    assert_instance_of Team, @stat_tracker.teams.first
    assert_equal "1", @stat_tracker.teams.first.team_id
    assert_equal "23", @stat_tracker.teams.first.franchise_id
    assert_equal "Atlanta United", @stat_tracker.teams.first.team_name
    assert_equal "ATL", @stat_tracker.teams.first.abbreviation
    assert_equal "/api/v1/teams/1", @stat_tracker.teams.first.link
  end

  def test_it_has_game_teams
    assert_instance_of GameTeam, @stat_tracker.game_teams.first
  end

  # GAME STATISTICS

  def test_highest_total_score
    assert_equal 5, @stat_tracker.highest_total_score
  end

  def test_lowest_total_score
    assert_equal 3, @stat_tracker.lowest_total_score
  end

  def test_find_home_wins
    assert_instance_of Array, @stat_tracker.find_home_wins
    assert_equal 2, @stat_tracker.find_home_wins.count
  end

  def test_home_wins_percentage
    assert_equal 0.67, @stat_tracker.percentage_home_wins
  end

  def test_find_visitor_wins
    assert_instance_of Array, @stat_tracker.find_visitor_wins
    assert_equal 1, @stat_tracker.find_visitor_wins.count
  end

  def test_away_wins_percentage
    assert_equal 0.33, @stat_tracker.percentage_visitor_wins
  end

  def test_find_tied_games
    locations = {
      games: './fixtures/games_gamestats_fixture.csv',
      teams: './fixtures/teams_fixture.csv',
      game_teams: './fixtures/game_teams_gamestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)

    assert_instance_of Array, stat_tracker.find_tied_games
    assert_equal 1, stat_tracker.find_tied_games.count
  end

  def test_percentage_ties
    locations = {
      games: './fixtures/games_gamestats_fixture.csv',
      teams: './fixtures/teams_fixture.csv',
      game_teams: './fixtures/game_teams_gamestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)
    assert_equal 0.04, stat_tracker.percentage_ties
  end

  def test_count_games_by_season
    locations = {
      games: './fixtures/games_gamestats_fixture_2.csv',
      teams: './fixtures/teams_fixture.csv',
      game_teams: './fixtures/game_teams_gamestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)

    game_nums_per_season = {"20122013" => 5,
                          "20162017" => 4,
                          "20132014" => 6}
    assert_equal game_nums_per_season, stat_tracker.count_of_games_by_season
  end

  def test_it_can_find_all_games_total_scores
    locations = {
      games: './fixtures/games_gamestats_fixture_2.csv',
      teams: './fixtures/teams_fixture.csv',
      game_teams: './fixtures/game_teams_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)
    assert_equal 67, stat_tracker.find_all_games_total_score
  end

  def test_it_can_get_average_goals_per_game
    locations = {
      games: './fixtures/games_gamestats_fixture_2.csv',
      teams: './fixtures/teams_fixture.csv',
      game_teams: './fixtures/game_teams_gamestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)
    assert_equal 4.47, stat_tracker.average_goals_per_game
  end

  def test_it_can_get_average_goals_by_season
    locations = {
      games: './fixtures/games_gamestats_fixture_2.csv',
      teams: './fixtures/teams_fixture.csv',
      game_teams: './fixtures/game_teams_gamestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)
    expected = { "20122013" => 4.40,
              "20162017" => 4.75,
              "20132014" => 4.33}
    assert_equal expected, stat_tracker.average_goals_by_season
  end

  # LEAGUE STATISTICS

  def test_it_can_count_teams
    assert_equal 6, @stat_tracker.count_of_teams
  end

  def test_it_can_find_team_by_id
    assert_equal "FC Dallas", @stat_tracker.find_team_by_id("6").team_name
  end

  def test_it_can_organize_scores_by_team #### REPEAT METHOD - keep
    team_scores = {"3"=>[2, 2, 1], "6"=>[3, 3, 2]}
    game_teams = @stat_tracker.game_teams
    assert_equal team_scores, @stat_tracker.sort_scores_by_team(game_teams)
  end

  def test_it_can_report_each_teams_avg_score #### REPEAT METHOD - keep
    game_teams = @stat_tracker.game_teams
    team_scores = @stat_tracker.sort_scores_by_team(game_teams)

    average_scores = {"3"=>1.6666666666666667, "6"=>2.6666666666666665}

    assert_equal average_scores, @stat_tracker.team_averages(team_scores)
  end

  def test_it_can_identify_best_offense
    assert_equal "FC Dallas", @stat_tracker.best_offense
  end

  def test_it_can_identify_worst_offense
    assert_equal "Houston Dynamo", @stat_tracker.worst_offense
  end

  def test_it_can_find_home_and_away_game_teams
    @stat_tracker.find_game_teams("away").each do |game_team|
      assert_equal "away", game_team.hoa
    end

    @stat_tracker.find_game_teams("home").each do |game_team|
      assert_equal "home", game_team.hoa
    end

    assert_equal 3, @stat_tracker.find_game_teams("away").count && @stat_tracker.find_game_teams("home").count
    # is it better for this line to be split up into two separate assertions
    # or for it to be on one line but past the 80char limit?
  end

  def test_it_can_identify_highest_scoring_visitor
    locations = {
      games: './fixtures/games_fixture.csv',
      teams: './fixtures/teams_leaguestats_fixture.csv',
      game_teams: './fixtures/game_teams_leaguestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "FC Dallas", stat_tracker.highest_scoring_visitor
  end

  def test_it_can_identify_highest_scoring_home_team
    locations = {
      games: './fixtures/games_fixture.csv',
      teams: './fixtures/teams_leaguestats_fixture.csv',
      game_teams: './fixtures/game_teams_leaguestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "LA Galaxy", stat_tracker.highest_scoring_home_team
  end

  def test_it_can_identify_lowest_scoring_visitor
    locations = {
      games: './fixtures/games_fixture.csv',
      teams: './fixtures/teams_leaguestats_fixture.csv',
      game_teams: './fixtures/game_teams_leaguestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Sporting Kansas City", stat_tracker.lowest_scoring_visitor
  end

  def test_it_can_identify_lowest_scoring_home_team
    skip
    locations = {
      games: './fixtures/games_fixture.csv',
      teams: './fixtures/teams_leaguestats_fixture.csv',
      game_teams: './fixtures/game_teams_leaguestats_fixture.csv'
    }
    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Sporting Kansas City", stat_tracker.lowest_scoring_home_team
  end

  # SEASON STATISTICS

  def test_it_can_find_games_by_season
  assert_instance_of Array, @stat_tracker.games_by_season("20122013")
  assert_equal 5, @stat_tracker.games_by_season("20122013").count
  end

  def test_winningest_coach
    game_path = './fixtures/games_fixture.csv'
    team_path = './fixtures/teams_fixture.csv'
    game_teams_path = './fixtures/game_teams_seasonstats_fixture.csv'

    locations = {
    games: game_path,
    teams: team_path,
    game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Claude Julien", @stat_tracker.winningest_coach("20122013")
  end

  def test_worst_coach
    game_path = './fixtures/games_fixture.csv'
    team_path = './fixtures/teams_fixture.csv'
    game_teams_path = './fixtures/game_teams_seasonstats_fixture.csv'

    locations = {
    games: game_path,
    teams: team_path,
    game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    # Name of the Coach with the worst win percentage for the season	String
    assert_equal "John Tortorella", @stat_tracker.worst_coach("20122013")
  end

  def test_most_accurate_team
    skip
    # Name of the Team with the best ratio of shots to goals for the season	String
    assert_equal "FC Dallas", @stat_tracker.most_accurate_team("20122013")
  end

  def test_least_accurate_team
    skip
    # Name of the Team with the worst ratio of shots to goals for the season	String
  end

  def test_most_tackles
    skip
    # Name of the Team with the most tackles in the season	String
  end

  def test_fewest_tackles
    skip
    # Name of the Team with the fewest tackles in the season	String
  end

  # TEAM STATISTICS

  def test_can_get_team_info_hash
    result = @stat_tracker.team_info("1")
    assert_instance_of Hash, result
    assert_equal "1", result[:team_id]
    assert_equal "ATL", result[:abbreviation]
  end

  def test_most_goals_scored_for_given_team
    assert_equal 3, @stat_tracker.most_goals_scored("6")
  end

  def test_fewest_goals_scored_for_given_team
    assert_equal 2, @stat_tracker.fewest_goals_scored("6")
  end

  def test_best_season_by_team_id
    assert_equal "20122013", @stat_tracker.best_season("6")
  end

  def test_worst_season_by_team_id
    assert_equal "20122013", @stat_tracker.worst_season("3")
  end

  def test_worst_season_by_team_id_expanded
    skip
    # THIS TEST IS BROKEN SOMEHOW
    # this is the only test that uses full csv, and
    # it's a little noticeably slower.
    locations = {
      games: './data/games.csv',
      teams: './data/teams.csv',
      game_teams: './data/game_teams.csv'
    }

    stat_tracker = StatTracker.from_csv(locations)
    assert_equal "20152016", stat_tracker.worst_season("6")
  end

  # Helpers

  def test_game_ids_by_team_and_result
    assert_equal ["2012030221", "2012030222", "2012030223"], @stat_tracker.game_ids_by("6", "WIN")
    assert_equal ["2012030221", "2012030222", "2012030223"], @stat_tracker.game_ids_by("3", "LOSS")
  end

  def test_games_by_id_array
    game_id_array = @stat_tracker.game_ids_by("6", "WIN")
    assert_equal 3, game_id_array.count
    assert_instance_of Array, game_id_array
  end

  def test_games_won_by_team_id
    game_id_array = @stat_tracker.game_ids_by("6", "WIN")

    @stat_tracker.games_by(game_id_array).each do |game|
      assert_instance_of Game, game
    end
  end

  def test_games_lost_by_team_id
    game_id_array = @stat_tracker.game_ids_by("3", "LOSS")
    @stat_tracker.games_by(game_id_array).each do |game|
      assert_instance_of Game, game
    end
  end

  def test_games_won_by_season_per_team
    assert_instance_of Hash, @stat_tracker.games_won_by_season("6")
    assert_instance_of Game, @stat_tracker.games_won_by_season("6").values[0][0]
  end

  def test_games_lost_by_season_per_team
    assert_instance_of Hash, @stat_tracker.games_lost_by_season("3")
    assert_instance_of Game, @stat_tracker.games_lost_by_season("3").values[0][0]
  end

  def test_average_win_percentage_by_team
    # skip
    # Average win percentage of all games for a team; float
    locations = {
      games: './fixtures/games_teamstats_fixture.csv',
      teams: './fixtures/teams_teamstats_fixture.csv',
      game_teams: './fixtures/game_teams_teamstats_fixture.csv'
    }

    stat_tracker = StatTracker.from_csv(locations)
    assert_equal 0.57, stat_tracker.average_win_percentage("17")
  end

  def test_favorite_opponent_by_team
    # Name of opponent that has the lowest win percentage
    # against given team; String
  end

  def test_rival_by_team
    # name of opponent that has the highest win percentage
    # against the given team
  end

end
