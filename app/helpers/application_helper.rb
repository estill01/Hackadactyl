module ApplicationHelper

  def truncate_on_space(text, *args)
    options = args.extract_options!
    options.reverse_merge!(:length => 30, :omission => "...")
    return text if text.blank? || text.size <= options[:length]

    new_text = truncate(text, :length => options[:length] + 1, :omission => "")
    while last = new_text.slice!(-1, 1)
      return new_text + options[:omission] if last == " "
    end
  end

  def possessive_from(word)
    word.scan(/s$/).empty? ? word + "'s" : word + "'"
  end


  def status_tag(boolean, options={})
    options[:true]        ||= ''
    options[:true_class]  ||= 'status true'
    options[:false]       ||= ''
    options[:false_class] ||= 'status false'

    if boolean
      content_tag(:span, options[:true], :class => options[:true_class])
    else
      content_tag(:span, options[:false], :class => options[:false_class])
    end
  end

  # Format text for display.
  def format(text)
    sanitize(markdown(text))
  end

  def cancel_button(link)
    "<input type='button' value='Cancel' class='cancel-button' onclick=\"window.location.href='#{link}';\" />".html_safe
  end

  def create_photo_list(parent, association, ancestors = [])
    string = ""
    for photo in parent.send(association)
      unless photo.new_record?
        url =  url_for([:staff] + ancestors + [parent, photo])
        string << "<li style='display:block;' id='#{photo.class.name.underscore.gsub("_", "-")}-#{photo.id}' class='photo-thumb'>"
        string << link_to(image_tag(photo.image(:thumb)), url)
        string << "<small>#{link_to "X",
              uurl,
              :method => :delete,
              :class => "delete-image-link action"
              }
              </small>"
      end
    end
    string.html_safe
  end

end
