class Game
  attr_reader :game_id,
              :season,
              :away_team_id,
              :home_team_id,
              :away_goals,
              :home_goals,
              :total_goals

  def initialize(game_params)
    @game_id = game_params[:game_id]
    @season = game_params[:season]
    @away_team_id = game_params[:away_team_id]
    @home_team_id = game_params[:home_team_id]
    @away_goals = game_params[:away_goals]
    @home_goals = game_params[:home_goals]
    @total_goals = @away_goals.to_i + @home_goals.to_i
  end

  def result
    if @home_goals.to_i > @away_goals.to_i
      :home_win
    elsif @away_goals.to_i > @home_goals.to_i
      :away_win
    elsif @away_goals.to_i == @home_goals.to_i
      :tie
    end
  end

  def winner
    if result == :home_win
      @home_team_id
    elsif result == :away_win
      @away_team_id
    end
  end

  def loser
    if result == :home_win
      @away_team_id
    elsif result == :away_win
      @home_team_id
    end
  end

  def opponent(team_id)
    if @home_team_id == team_id
      @away_team_id
    else
      @home_team_id
    end
  end

end
