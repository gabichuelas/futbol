module TeamStats

  def find_games_for(team_id)
    @games.find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end
  end

  def results_by_team(team_id)
    games = find_games_for(team_id)
    games.reduce({}) do |acc, game|
      acc[team_id] ||= {won: 0, lost: 0, tied: 0}
      acc[team_id][:won] += 1 if game.winner == team_id
      acc[team_id][:lost] += 1 if game.loser == team_id
      acc[team_id][:tied] += 1 if game.result == :tie
      acc
    end
  end

  def results_by_opponent(team_id)
    games = find_games_for(team_id)
    games.reduce({}) do |acc, game|
      opponent = game.opponent(team_id)
      acc[opponent] ||= {won: 0, lost: 0, tied: 0}
      acc[opponent][:won] += 1 if game.winner == opponent
      acc[opponent][:lost] += 1 if game.loser == opponent
      acc[opponent][:tied] += 1 if game.result == :tie
      acc
    end
  end

  def win_percentage_by_opponent(team_id)
    opp_tallies = results_by_opponent(team_id)
    opp_tallies.reduce({}) do |acc, (opponent, tally_hash)|
      win_percentage = tally_hash[:won].fdiv(tally_hash.values.sum)
      acc[opponent] = win_percentage
      acc
    end
  end

  def win_percentage_by_team(team_id)
    game_tallies = results_by_team(team_id)
    game_tallies.reduce({}) do |acc, (team, tally_hash)|
      win_percentage = tally_hash[:won].fdiv(tally_hash.values.sum)
      acc[team] = win_percentage
      acc
    end
  end

  def results_by_season(team_id)
    games = find_games_for(team_id)
    games.reduce({}) do |acc, game|
      acc[game.season] ||= {won: 0, lost: 0, tied: 0}
      acc[game.season][:won] += 1 if game.winner == team_id
      acc[game.season][:lost] += 1 if game.loser == team_id
      acc[game.season][:tied] += 1 if game.result == :tie
      acc
    end
  end

  def win_percentage_by_season(team_id)
    season_tallies = results_by_season(team_id)
    season_tallies.reduce({}) do |acc, (season, tally_hash)|
      win_percentage = tally_hash[:won].fdiv(tally_hash.values.sum)
      acc[season] = win_percentage
      acc
    end
  end
  
end