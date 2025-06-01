module ApplicationHelper
    def cat_color_filter(cat_customization)
      return 0 unless cat_customization
      
      color_filters = {
        'orange' => 30,
        'blue' => 200,
        'green' => 120,
        'purple' => 270,
        'pink' => 320,
        'default' => 0
      }
      
      color_filters[cat_customization.base_color] || 0
    end
  end