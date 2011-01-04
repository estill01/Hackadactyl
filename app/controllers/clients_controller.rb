class ClientsController < ApplicationController

  def create

    @found_client = Client.find_by_email(params[:client][:email])
    if @found_client
      flash.now[:notice] = "Email is already signuped up #{link_to 'resend welcome email', resend_welcome_email_client_path( @found_client.email)}"
      render(static_pages("home"))
    end
    @client = Client.new(params[:client])
    @client.save!
    @client.send_welcome_email
    redirect_to create_account_path(@client.account_token)
  rescue ActiveRecord::RecordInvalid
    render(:template => "static_pages/home")
    flash.now[:notice] = "Missing Info"
  end

  def resend_welcome_email
  end

end
