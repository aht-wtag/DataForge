module ApplicationHelper
  def sidebar_link_to(name, path, icon: nil)
    active = request.path == path || (request.path.start_with?(path) && path != "/")
    classes = [
      "flex items-center px-3 py-2 text-sm font-medium rounded-md",
      active ? "bg-blue-50 text-blue-700" : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
    ].join(" ")
    link_to path, class: classes do
      content_tag(:span, name)
    end
  end

  def page_title(title)
    content_for(:page_title) { title }
  end

  def role_badge(user)
    color_class = case user.role
                  when "admin" then "bg-red-100 text-red-800"
                  when "developer" then "bg-blue-100 text-blue-800"
                  when "viewer" then "bg-green-100 text-green-800"
                  else "bg-gray-100 text-gray-800"
                  end
    tag.span(user.role.upcase, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{color_class}")
  end

  def status_badge(status)
    color_map = {
      active: "bg-green-100 text-green-800",
      running: "bg-blue-100 text-blue-800",
      error: "bg-red-100 text-red-800",
      disabled: "bg-gray-100 text-gray-800",
      pending: "bg-yellow-100 text-yellow-800",
      completed: "bg-green-100 text-green-800",
      failed: "bg-red-100 text-red-800",
      partial: "bg-orange-100 text-orange-800"
    }
    content_tag :span, status.to_s.humanize,
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{color_map[status.to_sym] || 'bg-gray-100 text-gray-800'}"
  end
end
