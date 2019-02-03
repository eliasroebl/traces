  require 'rails_helper'

RSpec.describe V1::TracesController, type: :controller do
  describe "GET index" do
    it "returns no data" do
      get :index
      expect(response.body).to eq([].to_json)
    end

    it "returns stored data" do
      # prefill db data
      trace = Trace.new
      trace.save

      cord = Coordinate.new
      cord.trace_id = trace.id
      cord.lat = 32.1213245
      cord.lon = 112.34890
      cord.save


      get :index
      expected_body = [{
        id: trace.id,
        created_at: Time.now.to_i ,
        updated_at: Time.now.to_i,
        coordinates: [
          { latitude: 32.1213245, longitude: 112.3489 }
        ]
      }].to_json

      expect(response.body).to eq(expected_body)
    end
  end

  describe "POST create" do
    context "fails" do
      it "raises ArgumentError when no body is being passed" do
        expect { post :create }.to raise_error ArgumentError
      end
    end
    context "success" do
      let(:params) do
        {
          coordinates: trace
        }
      end
      let(:trace) do
        [{ latitude: 32.9377784729004, longitude: -117.230392456055 },
        { latitude: 32.937801361084, longitude: -117.230323791504 },
        { latitude: 32.9378204345703, longitude: -117.230278015137 }]
      end
      it "stores data into databse" do
        expected_body = [{
          coordinates: [
            { latitude: 32.1213245, longitude: 112.3489 }
          ]
        }
        ].to_json
        post :create, params: params
        expect(response.body).to eq(expected_body)



      end
    end
  end
end
