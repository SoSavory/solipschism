namespace :chron_tasks do
  desc "Matches Users based on coordinates, to be used every 15ish minutes"
  # Currently the cost of this is 3N + 1 Queries + 2 Mass Inserts + (N^2 - N)/2 Trig comparisons
  task match_users: :environment do

    today = Date.today
    now = Time.now
    overall_matches_array = []
    puts "====================================================================="
    puts "Running task"
    puts now
    puts "====================================================================="


     users_plucked = User.joins(:coordinate).where('users.opts_to_compute != TRUE')
                            .where("coordinates.latitude != ? OR coordinates.longitude != ?", 0.0000000, 0.0000000)
                            .order("users.id")
                            .pluck("users.id")


     unless users_plucked.empty?
       users_plucked.each do |user_id|

        # puts "Alias ID: " + String(alias_id)
        # Exclude aliases where there is already a match, find a way to rewrite this query as a single join
        already_matched_users = MatchedUser.where(user_id: user_id).pluck(:matched_user_id).push(user_id)
        # puts "Already Matched Aliases" + String(already_matched_aliases)

        user_coordinates = Coordinate.where(user_id: user_id).pluck(:latitude, :longitude)
        # puts "Alias Coordinates: " + String(alias_coordinates)
        compare_users = User.where('users.id > ?', user_id).includes(:coordinate)
                               .references(:coordinate)
                               .where("users.id NOT IN (?)", already_matched_users)
                               .pluck('users.id, coordinates.latitude, coordinates.longitude')
        # puts "Compare Aliases " + String(compare_aliases)

        matched_users = []

        compare_users.each do |cc|
          distance = Coordinate.compare_coordinates(cc[1].to_f, user_coordinates[0][0].to_f, cc[2].to_f, user_coordinates[0][1].to_f)
          # puts alias_id
          # puts cc[0]
          # puts distance
          if distance <= 1000000
            matched_users.push(cc[0])
          end
        end
        unless matched_users.empty?
          matches = matched_users.map{|m| "( #{user_id}, #{m}, '#{today}', '#{now}', '#{now}' )"}.join(",")
          # puts "Matches: "
          # puts matches
          overall_matches_array.push(matches)
          overall_matches = overall_matches_array.join(",")
          # puts "Overall Matches: "
          # puts overall_matches
          sql_matched_users = "INSERT INTO matched_users (user_id, matched_user_id, effective_date, created_at, updated_at) VALUES #{overall_matches}"
          sql_reverse_matched_users = "INSERT INTO matched_users (matched_user_id, user_id, effective_date, created_at, updated_at) VALUES #{overall_matches}"
          ActiveRecord::Base.connection.execute(sql_matched_users)
          ActiveRecord::Base.connection.execute(sql_reverse_matched_users)
        end
      end
    # Here is where we would archiv the existing coordinates, if that is something we wanted to do
    end
  end



end
