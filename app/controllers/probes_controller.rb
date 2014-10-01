class ProbesController < ApplicationController
  before_action :set_probe, only: [:show, :edit, :update, :destroy]

  # GET /probes
  # GET /probes.json
  def index
    @probes = Probe.all
  end

  # GET /probes/1
  # GET /probes/1.json
  def show
  end

  # GET /probes/new
  def new
    @probe = Probe.new
  end

  # GET /probes/1/edit
  def edit
  end

  # POST /probes
  # POST /probes.json
  def create
    @probe = Probe.new(probe_params)
    
    @probe.secret = ApiAuth.generate_secret_key

    respond_to do |format|
      if @probe.save
        format.html { redirect_to @probe, notice: 'Probe was successfully created.' }
        format.json { render :show, status: :created, location: @probe }
      else
        format.html { render :new }
        format.json { render json: @probe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /probes/1
  # PATCH/PUT /probes/1.json
  def update
    respond_to do |format|
      if @probe.update(probe_params)
        format.html { redirect_to @probe, notice: 'Probe was successfully updated.' }
        format.json { render :show, status: :ok, location: @probe }
      else
        format.html { render :edit }
        format.json { render json: @probe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /probes/1
  # DELETE /probes/1.json
  def destroy
    @probe.destroy
    respond_to do |format|
      format.html { redirect_to probes_url, notice: 'Probe was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_probe
      @probe = Probe.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def probe_params
      params.require(:probe).permit(:name, :secret)
    end
end
