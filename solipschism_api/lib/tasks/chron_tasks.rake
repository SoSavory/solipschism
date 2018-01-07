# Loop through all possible user comparisons at once? Or separate into non-existant matches and matches that need to be updated. We cant rely on matches already existing to prevent us from repeating comparisons that don't need to be made. In order to check whether a comparison needs to be made, we need to look-up where user matches don't exist, and where the updated date is so far in the past. Then we iterate through the users, and with each user we ignore everything in already matched users. Think about where already _matched_users would have to be for this to make sense.

namespace :chron_tasks do
  desc "Matches Users based on coordinates, to be used every 15ish minutes"
  # Currently the cost of this is 3N + 1 Queries + 2 Mass Inserts + (N^2 - N)/2 Trig comparisons
  task match_users: :environment do

    today = Date.today
    now = Time.now
    overall_matches_to_create_array = []
    puts "====================================================================="
    puts "Running task"
    puts now
    puts "====================================================================="


     users_plucked = User.joins(:coordinate).where('users.opts_to_compute != TRUE')
                            .where("coordinates.latitude != ? AND coordinates.longitude != ?", 0.0000000, 0.0000000)
                            .order("users.id")
                            .pluck("users.id, coordinates.latitude, coordinates.longitude")


     unless users_plucked.empty?
       users_plucked.each_with_index do |user, i|
        min_index = i + 1
        user_id = user[0]
        user_coordinates = user[1..2]

        # Exclude aliases where there is already a match, find a way to rewrite this query as a single join

        non_matched_users = users_plucked[min_index..-1] - User.joins(:matched_users, :coordinate)
                                                                .references(:matched_users, :coordinate)
                                                                .where("matched_users.matched_user_id = ?", user_id)
                                                                .where("matched_users.user_id > ?", user_id)
                                                                .pluck("matched_users.user_id, coordinates.latitude, coordinates.longitude")

        matched_users_to_be_rechecked = User.joins(:matched_users, :coordinate)
                              .references(:matched_users, :coordinate)
                              .where("users.id > ?", user_id)
                              .where("matched_users.matched_user_id = ?", user_id)
                              .where("matched_users.updated_at <= ?", Date.today - 2.days)
                              .pluck("matched_users.user_id, coordinates.latitude, coordinates.longitude")

        matches_to_create = []

        non_matched_users.each do |cc|
          distance = Coordinate.compare_coordinates(cc[1].to_f, user_coordinates[0].to_f, cc[2].to_f, user_coordinates[1].to_f)
          if distance <= 1000000
            matches_to_create.push(cc[0])
          end
        end

        matches_to_update = []
        matched_users_to_be_rechecked.each do |cc|
          distance = Coordinate.compare_coordinates(cc[1].to_f, user_coordinates[0].to_f, cc[2].to_f, user_coordinates[1].to_f)
          if distance <= 1000000
            matches_to_update.push(cc[0])
          end
        end

        # We can process all of the newly created matches, and then execute them all at once after this block
        unless matches_to_create.empty?
          matches = matches_to_create.map{|m| "( #{user_id}, #{m}, '#{now}', '#{now}' )"}.join(",")
          overall_matches_to_create_array.push(matches)
        end

        # For the updates, there is no super efficient way to do them all in bulk, so we do them user by user
        unless matches_to_update.empty?
          # matches = matches_to_update.join(",")
          matches = matches_to_update
          MatchedUser.where(user_id: user_id).where("matched_users.matched_user_id IN (?)", matches).update_all(updated_at: now)
          MatchedUser.where("matched_users.user_id IN (?)", matches).where(matched_user_id: user_id).update_all(updated_at: now)
        end
      end
      # Think about consolidating all the INSERT statements into a single statement, and have a loop that zips through index_of_matched_users and users_plucked, matching the indices of both
    # Here is where we would archiv the existing coordinates, if that is something we wanted to do

      unless overall_matches_to_create_array.empty?
        overall_matches_to_create = overall_matches_to_create_array.join(",")
        sql_matched_users = "INSERT INTO matched_users (user_id, matched_user_id, created_at, updated_at) VALUES #{overall_matches_to_create}"
        sql_reverse_matched_users = "INSERT INTO matched_users (matched_user_id, user_id, created_at, updated_at) VALUES #{overall_matches_to_create}"
        ActiveRecord::Base.connection.execute(sql_matched_users)
        ActiveRecord::Base.connection.execute(sql_reverse_matched_users)
      end

    end
  end
end
