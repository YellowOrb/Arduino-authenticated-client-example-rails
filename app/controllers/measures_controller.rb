class MeasuresController < ApplicationController
  before_action :set_measure, only: [:show, :edit, :update, :destroy]
  
  # require any kind of change and creation of a measure to come through our authenticated api using HMAC 
  # and we skip the CSRF check for these requests
  before_action :require_authenticated_api, only: [:edit, :update, :destroy, :create]
  skip_before_action :verify_authenticity_token, only: [:edit, :update, :destroy, :create]

  def require_authenticated_api
    @current_probe = Probe.find_by_id(ApiAuth.access_id(request))
    
    # if a probe could not be found via the access id or the one found did not authenticate with the data in the request
    # fail the call
    if @current_probe.nil? || !ApiAuth.authentic?(request, @current_probe.secret) 
      flash[:error] = "Authentication required"
      redirect_to measures_url, :status => :unauthorized
    end
  end
        
  # GET /measures
  # GET /measures.json
  def index
    @measures = Measure.all
  end

  # GET /measures/1
  # GET /measures/1.json
  def show
  end

  # GET /measures/new
  def new
    @measure = Measure.new
  end

  # GET /measures/1/edit
  def edit
  end

  # POST /measures
  # POST /measures.json
  def create
    @measure = Measure.new(measure_params)

    respond_to do |format|
      if @measure.save
        format.html { redirect_to @measure, notice: 'Measure was successfully created.' }
        format.json { render :show, status: :created, location: @measure }
      else
        format.html { render :new }
        format.json { render json: @measure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /measures/1
  # PATCH/PUT /measures/1.json
  def update
    respond_to do |format|
      if @measure.update(measure_params)
        format.html { redirect_to @measure, notice: 'Measure was successfully updated.' }
        format.json { render :show, status: :ok, location: @measure }
      else
        format.html { render :edit }
        format.json { render json: @measure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measures/1
  # DELETE /measures/1.json
  def destroy
    @measure.destroy
    respond_to do |format|
      format.html { redirect_to measures_url, notice: 'Measure was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measure
      @measure = Measure.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measure_params
      params.require(:measure).permit(:temperature)
    end
end
