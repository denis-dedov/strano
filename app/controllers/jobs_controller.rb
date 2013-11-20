class JobsController < InheritedResources::Base

  belongs_to :project, finder: :find_by_id_or_name
  actions :all, :except => :index
  respond_to :json, :only => :show

  before_filter :authenticate_user!, unless: :no_gui?
  before_filter :basic_authentication!, if: :no_gui?
  before_filter :ensure_unlocked_project, :only => [:new, :create, :delete]
  before_filter :normalize_params!, if: :no_gui?

  rescue_from Strano::ProjectCapError do |e|
    redirect_to parent
  end


  def new
    @job = parent.jobs.build params[:job]
    # TODO write in the README that all the projects that use multistage need one
    # default_stage configuration
    @job.stage = parent.cap.default_stage if parent.cap.namespaces.keys.include?(:multistage)

    new!
  end

  def create
    create! :notice => "Your new job is being processed..."
    head :ok if no_gui?
  end


  private

    def begin_of_association_chain
      params[:job] ||= {}
      params[:job][:task] ||= params[:task]
      params[:job][:user] = current_user

      super
    end

    def ensure_unlocked_project
      if parent.job_in_progress?
        redirect_to parent, :alert => "Unable to run tasks while a job is in progress." and return
      end
    end

    def basic_authentication!
      authenticate_or_request_with_http_basic do |username, password|
        current_user = User.try_to_login(username, password)
        session[:user_id] = current_user.id if current_user.present?
      end
    end

    def basic_logged?
      request.authorization.present?
    end

    def no_gui?
      params[:no_gui].present?
    end

    def normalize_params!
      params[:job] = params.slice(:task, :stage, :branch, :notes, :verbosity).merge(params[:job] || {})
    end
end
