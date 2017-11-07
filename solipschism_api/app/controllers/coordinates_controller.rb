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
end
