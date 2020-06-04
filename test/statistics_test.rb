require './test/setup'
require './lib/game'
require './lib/team'
require './lib/game_team'
require './lib/statistics'

class StatisticsTest < Minitest::Test
  def setup
    game_path = './fixtures/games_fixture.csv'
    team_path = './fixtures/teams_fixture.csv'
    game_teams_path = './fixtures/game_teams_fixture.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    @statistics = Statistics.new(locations)
  end

  def test_it_exists
    assert_instance_of Statistics, @statistics
  end

  def test_it_has_games
    assert_instance_of Game, @statistics.games.first
    assert_equal "2012030221", @statistics.games.first.game_id
    assert_equal "20122013", @statistics.games.first.season
    assert_equal "3", @statistics.games.first.away_team_id
    assert_equal "6", @statistics.games.first.home_team_id
  end

  def test_it_has_teams
    assert_instance_of Team, @statistics.teams.first
    assert_equal "1", @statistics.teams.first.team_id
    assert_equal "23", @statistics.teams.first.franchise_id
    assert_equal "Atlanta United", @statistics.teams.first.team_name
    assert_equal "ATL", @statistics.teams.first.abbreviation
    assert_equal "/api/v1/teams/1", @statistics.teams.first.link
  end

  def test_it_has_game_teams
    assert_instance_of GameTeam, @statistics.game_teams.first
  end
end
