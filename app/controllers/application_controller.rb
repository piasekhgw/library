class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: I18n.t("errors.not_found") }, status: :not_found
  end
end
