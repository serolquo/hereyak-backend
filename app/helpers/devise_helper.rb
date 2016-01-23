module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?

    dupped_errors = Hash.new   
    resource.errors.each {|key,message|
      dupped_errors[key] = message if resource.errors[key].size > 1 and dupped_errors[key].nil?
    }
    dupped_errors.each {|key,value|
      resource.errors.set(key,[value])
    }
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = "#{sentence}<ul>#{messages}</ul>"
    javascript_tag "$.prompt(\"#{html}\", {persistent: false});".html_safe
  end
end
