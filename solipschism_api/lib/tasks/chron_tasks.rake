namespace :chron_tasks do
  desc "Matches Aliases based on coordinates"
  task match_aliases: :environment do
    puts "Running task"

     Alias.where(effective_date: Date.today).order(:id).pluck(:id).each do |alias_id|
      puts "Alias ID: " + String(alias_id)
      # Exclude aliases where there is already a match, find a way to rewrite this query as a single join
      already_matched_aliases = MatchedAlias.where(alias_id: alias_id).pluck(:matched_alias_id).push(alias_id)
      puts "Already Matched Aliases" + String(already_matched_aliases)
      alias_coordinates = Coordinate.where(alias_id: alias_id).pluck(:latitude, :longitude)
      puts "Alias Coordinates: " + String(alias_coordinates)
      compare_aliases = Alias.where(effective_date: Date.today).where('aliases.id > ?', alias_id).includes(:matched_aliases, :coordinate).references(:matched_aliases, :coordinate).where("aliases.id NOT IN (?)", already_matched_aliases).pluck('aliases.id, coordinates.latitude, coordinates.longitude')
      puts "Compare Aliases " + String(compare_aliases)
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

end
