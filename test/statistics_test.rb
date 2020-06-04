require './test/setup'
require './lib/game'
require './lib/team'
require './lib/game_team'
require './lib/statistics'
require './lib/readable'

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
    @statistics = Statistics.from_csv(locations)
  end

  def test_it_exists
    assert_instance_of Statistics, @statistics
  end

  def test_it_has

  end
end
