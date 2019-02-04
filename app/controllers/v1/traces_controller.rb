require 'json'

module V1
  class TracesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index # GET
      traces = Trace.all
      result = []
      traces.each do |t|
        result.push(build_trace_json(t.id))
      end
      render json: result
      end

    def show # GET
      trace = Trace.find(params[:id])
      trace.save
      coordinates = Coordinate.where(trace_id: trace.id)
      previous = nil
      dist = 0
      coordinates.each do |c|
        c.distance = dist
        c.save
        dist += distance_from_coor(previous,c)
        previous = c
      end
      result = build_trace_json(params[:id])
      render json: result
    end

    def create # POST
      coordinates = JSON.parse(request.body.read)
      trace_id = nil
      ActiveRecord::Base.transaction do
        previous = nil
        dist = 0
        trace = Trace.new
        trace.save
        coordinates.each do |c|
          cord = Coordinate.new
          cord.trace_id = trace.id
          cord.lat = c['latitude'].to_f
          cord.lon = c['longitude'].to_f
          cord.distance = dist
          cord.save
          dist += distance_from_coor(previous,cord)
          previous = cord
        end
        trace_id = trace.id
      end
      result = build_trace_json(trace_id)
      render json: result
    end

    def edit
      trace = Trace.find(params[:id])
      end

    def update # PATCH
      trace = Trace.find(params[:id])
      ActiveRecord::Base.transaction do
        coordinates = Coordinate.where(trace_id: trace.id)
        coordinates.each do |c|
          c.destroy
        end

        coordinates = JSON.parse(request.body.read)
        # initialize here to get variable out of the transaction block scope
        coordinates.each do |c|
          cord = Coordinate.new
          cord.trace_id = trace.id
          cord.lat = c['latitude'].to_f
          cord.lon = c['longitude'].to_f
          cord.save
        end
      end
      result = build_trace_json(trace.id)
      render json: result
    end

    def destroy
      trace = Trace.find(params[:id])
      coordinates = Coordinate.where(trace_id: trace.id)
      coordinates.each(&:destroy)
      trace.destroy
      render json: trace
      end

    private

    def build_trace_json(id)
      t = Trace.find(id)
      cords = []
      Coordinate.where(trace_id: t.id).each do |c|
        cords.push(
          latitude: c.lat.to_f,
          longitude: c.lon.to_f,
          distance: c.distance.to_i
        )
      end

      result = {
        id: t.id,
        created_at: t.created_at.to_i,
        updated_at: t.updated_at.to_i,
        coordinates: cords
      }
    end

    def distance_from_coor prev, cur
      return 0 if prev.nil?
      loc1 = [prev.lat,prev.lon]
      loc2 = [cur.lat,cur.lon]
      rad_per_deg = Math::PI/180  # PI / 180
      rkm = 6371                  # Earth radius in kilometers
      rm = rkm * 1000             # Radius in meters

      dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
      dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

      lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
      lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

      a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

      rm * c # Delta in meters
    end
  end
end
