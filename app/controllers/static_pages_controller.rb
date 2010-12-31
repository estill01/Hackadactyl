class StaticPagesController < ApplicationController

  layout 'public'

  verify :params => :name, :only => [:show], :redirect_to => :root_url
  before_filter :logged_in?
  before_filter :ensure_valid, :only => [:show]

  def show
    @page_title = current_page.titleize unless current_page == 'home'
    render(current_page.underscore)
  end

  protected

    def current_page
      params[:name].to_s.downcase
    end

    def ensure_valid
      valid_pages = ['about']
      unless valid_pages.include?(current_page)
        render_404
      end
    end

end
