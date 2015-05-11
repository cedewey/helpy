class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  add_breadcrumb 'Home', :root_path

  before_action :set_locale
  before_filter :instantiate_tracker

  private

  def set_locale
    if user_signed_in?
      I18n.locale = current_user.language
    else
      I18n.locale = I18n.default_locale
    end
  end

  def fetch_counts
    @new = Topic.unread.count
    @unread = Topic.unread.count
    @pending = Topic.mine(current_user.id).pending.count
    @open = Topic.open.count
    @active = Topic.active.count
    @mine = Topic.mine(current_user.id).count
    @closed = Topic.closed.count
    @spam = Topic.spam.count

    @admins = User.admins
  end

  def verify_admin
      (current_user.nil?) ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end

  def instantiate_tracker
    # instantiate a tracker instance for GA Measurement Protocol pushes
    # this is used to track events happening on the serverside, like email support ticket creation
    if params[:client_id]
      logger.info("initiate tracker with client id")
      @tracker = Staccato.tracker(Settings.google_analytics_id, params[:client_id])
    else
      logger.info("!!! initiate tracker without client id !!!")
      @tracker = Staccato.tracker(Settings.google_analytics_id)
    end
  end

end
