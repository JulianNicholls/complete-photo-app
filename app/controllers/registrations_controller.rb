# Controller for user registrations that takes payment via Stripe first
class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

    resource.class.transaction do
      resource.save

      yield resource if block_given?

      if resource.persisted?
        return unless process_payment

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource,
                       location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource,
                       location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:payment)
  end

  private

  def process_payment
    flash[:error] = 'Please check registration errors' unless payment.valid?

    begin
      payment.process_payment
      payment.save
    rescue Exception => ex
      flash[:error] = ex.message

      resource.destroy
      puts 'Payment Failed'
      render :new
      return false
    end

    true
  end

  def payment
    @payment ||= Payment.new(
      email:    params['user']['email'],
      token:    params[:payment]['token'],
      user_id:  resource.id
    )
  end
end
