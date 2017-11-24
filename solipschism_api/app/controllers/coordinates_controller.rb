class CoordinatesController < ApiController
  def update
    coordinate = Coordinate.find_or_create(alias_id: current_user.current_alias)
    if coordinate.update_attributes(latitude: params[:latitude], longitude: params[:longitude])
      message = { message: "Successfully Updated Your Coordinates" }
      status = :ok
    else
      message = { errors: [ { detail: "Your Coordinates Could Not Be Updated" } ] }
      status = :bad_request
    end
    render json: message, status: status
  end

  def index
    c = Coordinate.where(alias_id: current_user.current_alias).pluck(:latitude, :longitude, :alias_id, :created_at, :updated_at)[0]
    coordinates = { latitude: c[0], longitude: c[1], alias_id: c[2], created_at: c[3], updated_at: c[4] }
    render json: {coordinates: coordinates}
  end



  def require_computation_set
    if current_user.opts_to_compute == TRUE

      computation_set = Alias.includes(:matched_aliases, :coordinate).references(:matched_aliases, :coordinate)
                           .where('aliases.id != ?', current_user.current_alias)
                           .pluck('aliases.id, coordinates.latitude, coordinates.longitude')
                           .map{|datum| {alias_id: datum[0], latitude: datum[1].to_f, longitude: datum[2].to_f } }

      message = {computation_set: computation_set}
      status = :ok
    else
      message = {errors: [{detail: "You have not opted in to perform computation, you must do so in order to retrieve your data set."}]}
      status = :bad_request
    end
    render json: message, status: status
  end


  # Expexts the params[:matched] to be in form [ids where match should be made]
  def upload_matched_aliases

    if current_user.opts_to_compute == TRUE
      current_alias = current_user.current_alias

      # if params[:computation_set_key] == current_user.computation_set_key
      effective_date = Date.today
      now = Time.now

      already_existing_matches = MatchedAlias.where(alias_id: current_alias).where(effective_date: effective_date).pluck(:matched_alias_id)
      matched = params[:matched] -= already_existing_matches
      matches = matched.map{|m| "( #{current_alias}, #{m}, '#{effective_date}', '#{now}', '#{now}' )"}.join(",")

      sql_matched_aliases = "INSERT INTO matched_aliases (alias_id, matched_alias_id, effective_date, created_at, updated_at) VALUES #{matches}"
      sql_reverse_matched_aliases = "INSERT INTO matched_aliases (matched_alias_id, alias_id, effective_date, created_at, updated_at) VALUES #{matches}"
      ActiveRecord::Base.connection.execute(sql_matched_aliases)
      ActiveRecord::Base.connection.execute(sql_reverse_matched_aliases)
      message = {message: "Thank You for uploading your matches!"}
      status = :ok

    else
      message = {errors: [{detail: "You have not opted in to perform computation, you must do so in order to submit matched data sets."}]}
      status = :bad_request
    end

    render json: message, status: status

  end

end
