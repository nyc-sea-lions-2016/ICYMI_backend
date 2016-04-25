class PlacesController < ApplicationController

  def index
    @places = Place.all
    render json: @places
  end

  def today
    @today = Date.today
    @places = Place.where(created_at: @today.beginning_of_day..@today.end_of_day)
    render json: @places
  end

  def yesterday
    @yesterday = Date.yesterday
    @places = Place.where(created_at: @yesterday.beginning_of_day..@yesterday.end_of_day)
    render json: @places
  end

  def two_days
    @two_days = 2.days.ago
    @places = Place.where(created_at: @two_days.beginning_of_day..@two_days.end_of_day)
    render json: @places
  end

  def favorites
    @places = Place.where("favorite = ?", true)
    render json: @places
  end

  def show
    @place = Place.find_by(id: params[:id])
    render json: @place
  end


  def create
    @places = []
    r = JSON.parse(request.body.string)
    p r
    long = r["latlong"]["coords"]["longitude"]
    lat = r["latlong"]["coords"]["latitude"]
    response = HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{long}&radius=3000&key=" + ENV["GOOGLE_PLACE_API"])
    p response
    response['results'].each do |place|
      place_id = place['place_id']
      @places << HTTParty.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+ place_id +'&key=' + ENV["GOOGLE_PLACE_API"])
    end
    p @places


    @places.each do |place|
      new_p = Place.new({
        name: place['result']['name'],
      	address: place['result']['formatted_address'],
      	phone: place['result']['international_phone_number'],
      	website: place['result']['website'],
      	user_id: 1,
      	favorite: false
      	})
        if new_p.save
          new_p
          p new_p
        else
          puts "Failed to save place"
          p new_p.errors.full_messages
          return "This is wrong"
        end

    end
  end

end
