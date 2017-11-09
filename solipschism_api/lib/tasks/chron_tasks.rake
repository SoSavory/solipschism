namespace :chron_tasks do
  desc "Matches Aliases based on coordinates, to be used every 15ish minutes"
  task match_aliases: :environment do
    puts "Running task"

     Alias.where(effective_date: Date.today).order(:id).pluck(:id).each do |alias_id|
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
      # compare_aliases = Alias.where(effective_date: Date.today).where('aliases.id > ?', alias_id)
      #                        .includes(:coordinate, :matched_aliases)
      #                        .references(:coordinate, :matched_aliases)
      #                        .where('')
      compare_aliases.each do |cc|
        distance = Coordinate.compare_coordinates(cc[1].to_f, alias_coordinates[0][0].to_f, cc[2].to_f, alias_coordinates[0][1].to_f)
        puts alias_id
        puts cc[0]
        puts distance
        if distance <= 100
          MatchedAlias.create(alias_id: alias_id, matched_alias_id: cc[0], effective_date: Date.today)
        end
      end
    end
    # Here is where we would archiv the existing coordinates, if that is something we wanted to do
  end

  desc "Creates a fresh set of aliases and coordinates for users, to be used daily"
  task create_aliases: :environment do
    puts "Running Task"
    date = Date.today
    time = Time.now
    user_ids = User.pluck(:id)
    existing_users = user_ids.map{ |id| "('#{id}', '#{date}', '#{time}', '#{time}')" }.join(",")
    coordinates = user_ids.map{ |id| "('#{id}', '0', '0', '#{time}', '#{time}')" }.join(",")
    puts "Existing users: "
    puts existing_users

    puts "Coordinates: "
    puts coordinates

    sql_aliases = "INSERT INTO aliases (user_id, effective_date, created_at, updated_at) VALUES #{existing_users}"
    sql_coordinates = "INSERT INTO coordinates (alias_id, latitude, longitude, created_at, updated_at) VALUES #{coordinates}"
    ActiveRecord::Base.connection.execute(sql_aliases)
    ActiveRecord::Base.connection.execute(sql_coordinates)
  end

end
