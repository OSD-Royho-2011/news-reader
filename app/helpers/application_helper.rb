module ApplicationHelper
  def view_next_button? next_page, data, total_page 
    return false if next_page.blank?
    return next_page <= total_page if total_page.present?
    data.present?
  end
end
