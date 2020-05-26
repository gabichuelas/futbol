class Team
  attr_reader :team_id,
              :franchise_id,
              :team_name,
              :abbreviation,
              :link

  def initialize(team_params)
    @team_id = team_params[:team_id].to_i
    @franchise_id = team_params[:franchiseid].to_i
    @team_name = team_params[:teamname]
    @abbreviation = team_params[:abbreviation]
    @link = team_params[:link]
  end
end
