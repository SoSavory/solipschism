class CoordinatesController < ApiController
  def update
    coordinate = Coordinate.find_by(alias_id: current_user.current_alias)
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
    computation_set = Alias.includes(:coordinate).references(:coordinate).where('aliases.id != ?', current_user.current_alias)
                           .pluck('aliases.id, coordinates.latitude, coordinates.longitude')
                           .map{|datum| {alias_id: datum[0], latitude: datum[1].to_f, longitude: datum[2].to_f } }
    # Generate Computation set key- a key that allows for matched to be uploaded

    render json: {computation_set: computation_set}
  end

  def upload_matched_aliases
    current_alias = current_user.current_alias

    # if params[:computation_set_key] == current_user.computation_set_key
    effective_date = Date.today
    now = Time.now

    matches = params[:matched].map{|m| "( #{current_alias}, #{m}, '#{effective_date}', '#{now}', '#{now}' )"}.join(",")

    sql_matched_aliases = "INSERT INTO matched_aliases (alias_id, matched_alias_id, effective_date, created_at, updated_at) VALUES #{existing_users}"
    ActiveRecord::Base.connection.execute(sql_matched_aliases)

    render json: {message: "Thank you for uploading your matches!"}

  end

end
