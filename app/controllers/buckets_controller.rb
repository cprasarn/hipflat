class BucketsController < ApplicationController
  # GET /buckets/list.json
  def show
    bucket_id = (params[:max_distance].to_f / 100).ceil + 1
    @buckets = Bucket.where({'bucket_id' => {'$lte' => bucket_id}})
    respond_to do |format|
      if 0 < @buckets.length
        # format.json { render :show, status: :ok, location: @buckets }
        format.json { render text: @buckets.to_json }
      else
        @errors = ["error" => "Cannot find any groups within " + params[:max_distance] + " meters"]
        format.json { render text: @errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def building_params
      params.require(:buckets).permit(:max_distance)
    end
end
