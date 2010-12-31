class AutoPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    skip_validation = value.nil? || (record.password.blank? && record.email_confirmation.blank?)
    unless skip_validation || record.is_authenticated?(value)
      record.errors[attribute] << "is incorrect."
    end
  end
end
