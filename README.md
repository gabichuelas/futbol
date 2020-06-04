# Futbol

Starter repository for the [Turing School](https://turing.io/) Futbol project.


## Refactoring approach
* Upon completing the general composition of all four statistic method categories, each team member broke down their individual methods into helper methods to better align with the `Single Responsibility Principle`
  * eg, `#lowest_scoring_home_team` had originally encompassed over 20 lines of code that found all "home" `game_teams`, then created a hash with team IDs as keys and arrays of scores as the values, then found the average score across games for each team, then found the lowest average score, identified the team ID associated with that average, and _finally_ identified and returned the name of the team associated with that ID. ==> Each of those steps was then refactored into a separate helper method, each carrying out a single responsibility.
* We then noticed the patterns in our various helper methods and implemented the `Don't Repeat Yourself` principle by figuring out which helper methods could be combined into a single, more dynamic helper method
  * eg, `#percentage_home_wins` and `#percentage_visitor_wins` each required a helper method that searched for `game_teams` that met a certain criteria for `game_team.hoa` and `game_team.result`. Originally composed as separate helper methods, we refactored them into a single helper method that takes two arguments which detail the criteria we need the resulting list of `game_teams` to match.
* As for bigger picture reorganization, we used a combination of modules and inheritance
  * A `Readable` module included in our `Statistics` class reads the CSV data files and turns all instances of the `Game`, `GameTeam`, `Team` classes into collections that in turn serve as attributes of the `Statistics` and `StatTracker` classes. Though the module is `included` only in the `Statistics` class, it addresses a shared functionality used across the three `Game`, `GameTeam`, `Team` classes.
  * Inheritance is used to pass down functionality and attributes from the `Statistics` class to the `StatTracker` class. The `StatTracker` – which carries out a "type of" `Statistics` – accesses the helper methods and `@games`, `@game_teams`, and `@teams` attributes passed down from the `Statistics` class.
* Depending on capacity before Thursday's deadline, we hope to also implement mocks and stubs to eliminate the need for the various fixture files we created while building out our `StatTracker`: we will mock a `StatTracker` object to define the return values of specific methods so that we don't need to create entire `StatTracker` instances for tests that require different subsets of `@games`, `@game_teams`, and `@teams` objects.
* **Wonderful, last minute discovery!!** Wednesday night, we discovered the `#transform_values` method, which allowed us to drastically shorten up methods that previously used `#reduce` to modify existing hashes. 
