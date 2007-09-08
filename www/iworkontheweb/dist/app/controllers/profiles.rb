class Profiles < Application
  before :setup_latest_profiles

  def home
    @profile = @latest_profiles.last
  end

  def index
  end

  def show
    @profile = Profile.find(params[:id])
  end
  
  protected
    def setup_latest_profiles
      @latest_profiles = Profile.latest
    end
end
