module NovaFabrica
  module RememberPage

    def remember_page
      if params[:page].blank?
        params[:page] = recall_page_from_session
      else
        retain_page_in_session(:page => params[:page])
      end
    end

    def retain_page_in_session(options={})
      if options[:page]
        ctl_name = options[:controller] ||= self.controller_name
        act_name = options[:action] ||= self.action_name
        session[:page_memory] ||= {}
        session[:page_memory][ctl_name] ||= {}
        session[:page_memory][ctl_name][act_name] = {:page => options[:page].to_i}
      end
    end

    def recall_page_from_session(options={})
      ctl_name = options[:controller] ||= self.controller_name
      act_name = options[:action] ||= self.action_name
      session[:page_memory][ctl_name][act_name][:page] rescue nil
    end

    def clear_page_from_session(options={})
      ctl_name = options[:controller] ||= self.controller_name
      act_name = options[:action] ||= self.action_name
      session[:page_memory][ctl_name][act_name][:page] = nil rescue nil
    end

  end
end
