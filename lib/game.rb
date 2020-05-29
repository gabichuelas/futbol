class Game
  attr_reader :game_id,
              :season,
              :away_team_id,
              :home_team_id,
              :away_goals,
              :home_goals,
              :total_goals

  def initialize(game_params)
    @game_id = game_params[:game_id].to_i
    @season = game_params[:season].to_i
    @away_team_id = game_params[:away_team_id].to_i
    @home_team_id = game_params[:home_team_id].to_i
    @away_goals = game_params[:away_goals].to_i
    @home_goals = game_params[:home_goals].to_i
    @total_goals = @away_goals + @home_goals
  end

end
