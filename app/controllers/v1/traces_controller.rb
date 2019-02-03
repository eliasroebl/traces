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
      result = build_trace_json(params[:id])
      render json: result
      end

    def create # POST
      #request.body.rewind
      #raise ArgumentError if request.body.read.empty?
      coordinates = JSON.parse(request.body.read)
      # initialize here to get variable out of the transaction block scope
      trace_id = nil
      ActiveRecord::Base.transaction do
        trace = Trace.new
        trace.save
        coordinates.each do |c|
          cord = Coordinate.new
          cord.trace_id = trace.id
          cord.lat = c['latitude'].to_f
          cord.lon = c['longitude'].to_f
          cord.save
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
          longitude: c.lon.to_f
        )
      end

      result = {
        id: t.id,
        created_at: t.created_at.to_i,
        updated_at: t.updated_at.to_i,
        coordinates: cords
      }
      end
  end
end
