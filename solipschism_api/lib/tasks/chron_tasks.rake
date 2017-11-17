namespace :chron_tasks do
  desc "Matches Aliases based on coordinates, to be used every 15ish minutes"
  # Currently the cost of this is 3N + 1 Queries + 2 Mass Inserts + (N^2 - N)/2 Trig comparisons
  task match_aliases: :environment do
    puts "Running task"
    today = Date.today
    now = Time.now
    overall_matches_array = []

     Alias.joins(:user).where('users.opts_to_compute != TRUE').where(effective_date: Date.today).order("aliases.id").pluck("aliases.id").each do |alias_id|

      puts "Alias ID: " + String(alias_id)
      # Exclude aliases where there is already a match, find a way to rewrite this query as a single join
      already_matched_aliases = MatchedAlias.where(alias_id: alias_id).pluck(:matched_alias_id).push(alias_id)
      puts "Already Matched Aliases" + String(already_matched_aliases)

      alias_coordinates = Coordinate.where(alias_id: alias_id).pluck(:latitude, :longitude)
      puts "Alias Coordinates: " + String(alias_coordinates)
      compare_aliases = Alias.where(effective_date: Date.today).where('aliases.id > ?', alias_id).includes(:coordinate)
                             .references(:coordinate)
                             .where("aliases.id NOT IN (?)", already_matched_aliases)
                             .pluck('aliases.id, coordinates.latitude, coordinates.longitude')
      puts "Compare Aliases " + String(compare_aliases)

      matched_aliases = []

      compare_aliases.each do |cc|
        distance = Coordinate.compare_coordinates(cc[1].to_f, alias_coordinates[0][0].to_f, cc[2].to_f, alias_coordinates[0][1].to_f)
        puts alias_id
        puts cc[0]
        puts distance
        if distance <= 100
          matched_aliases.push(cc[0])
        end
      end
      unless matched_aliases.empty?
        matches = matched_aliases.map{|m| "( #{alias_id}, #{m}, '#{today}', '#{now}', '#{now}' )"}.join(",")
        puts "Matches: "
        puts matches
        overall_matches_array.push(matches)
      end
    end
    # Here is where we would archiv the existing coordinates, if that is something we wanted to do
    overall_matches = overall_matches_array.join(",")
    puts "Overall Matches: "
    puts overall_matches
    sql_matched_aliases = "INSERT INTO matched_aliases (alias_id, matched_alias_id, effective_date, created_at, updated_at) VALUES #{overall_matches}"
    sql_reverse_matched_aliases = "INSERT INTO matched_aliases (matched_alias_id, alias_id, effective_date, created_at, updated_at) VALUES #{overall_matches}"
    ActiveRecord::Base.connection.execute(sql_matched_aliases)
    ActiveRecord::Base.connection.execute(sql_reverse_matched_aliases)
  end

  desc "Creates a fresh set of aliases and coordinates for users, to be used daily"
  task create_aliases: :environment do
    puts "Running Task"
    date = Date.today
    time = Time.now
    user_ids = User.pluck(:id)
    existing_users = user_ids.map{ |id| "('#{id}', '#{date}', '#{time}', '#{time}')" }.join(",")

    sql_aliases = "INSERT INTO aliases (user_id, effective_date, created_at, updated_at) VALUES #{existing_users}"
    ActiveRecord::Base.connection.execute(sql_aliases)

    existing_aliases = Alias.where(effective_date: date).pluck(:id)
    coordinates = existing_aliases.map{ |id| "('#{id}', '0', '0', '#{time}', '#{time}')" }.join(",")
    sql_coordinates = "INSERT INTO coordinates (alias_id, latitude, longitude, created_at, updated_at) VALUES #{coordinates}"
    ActiveRecord::Base.connection.execute(sql_coordinates)
  end

end
