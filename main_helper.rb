module Themes::Efashion::MainHelper
  def self.included(klass)
    # klass.helper_method [:my_helper_method] rescue "" # here your methods accessible from views
  end

  def efashion_settings(theme)
    # callback to save custom values of fields added in my_theme/views/admin/settings.html.erb
  end

  # callback called after theme installed
  def efashion_on_install_theme(theme)
    group = theme.add_field_group({name: "Home Slider", slug: "home_slider", description: ""})
    group.add_field({"name"=>"Text Slider", "slug"=>"home_slider_tabs"},{field_key: "text_box", translate: true, multiple: true})
    group.add_field({"name"=>"Home Slider Image (1000px1000px)", "slug"=>"home_slider_bg"},{field_key: "image" })
    group.add_field({"name"=>"Home Slider Product", "slug"=>"home_slider_product"},{field_key: "select_eval", required: true, command: 'options_from_collection_for_select(current_site.the_posts("commerce").decorate, :id, :the_title)' })
    theme.save_field_value('home_slider_tabs', ['One Click Installation', 'Easy Configuration', 'Easy Administration', 'Shop Online'])
    # # Sample Custom Field
    # unless theme.get_field_groups.where(slug: "fields").any?
    #   group = theme.add_field_group({name: "Main Settings", slug: "fields", description: ""})
    #   group.add_field({"name"=>"Background color", "slug"=>"bg_color"},{field_key: "colorpicker"})
    #   group.add_field({"name"=>"Links color", "slug"=>"links_color"},{field_key: "colorpicker"})
    #   group.add_field({"name"=>"Background image", "slug"=>"bg"},{field_key: "image"})
    # end

    # # Sample Meta Value
    # theme.set_meta("installed_at", Time.current.to_s) # save a custom value
    if current_site.plugin_installed?('ecommerce')
      efashion_ecommerce_after_install({})
    else
      plugin_install('ecommerce')
    end

    plugin_install('cama_subscriber') unless current_site.plugin_installed?('cama_subscriber')
  end

  # callback executed after theme uninstalled
  def efashion_on_uninstall_theme(theme)
    post_type = current_site.the_post_type('commerce')
    if post_type.present?
      post_type.set_option('posts_feature_image_dimension', current_theme.get_option('backup_posts_feature_image_dimension'))
    end
    theme.destroy
  end
  
  def efashion_ecommerce_after_install(args)
    post_type = current_site.the_post_type('commerce')
    if post_type.present?
      current_theme.set_option('backup_posts_feature_image_dimension', post_type.get_option('posts_feature_image_dimension'))
      post_type.set_option('posts_image_dimension', '380x480')
      field = post_type.get_field_object('ecommerce_photos')
      field.set_options({dimension: '760x1100'}) if field.present?
    end
  end
  def efashion_custom_inputs_for_products(args)
    args[:html] << render(partial: theme_view('admin/extra_product_form'), locals:{args: args }) if args[:post_type].slug == 'commerce'
  end  
  def efashion_extra_custom_fields(args)
    current_theme.add_field({"name"=>"Home Slider 4", "slug"=>"home_slider4"}, {field_key: "my_slider", translate: true, multiple: true, default_values: [{"image":"http://camaleon.tuzitio.com/media/132/test_images/screen.shot.2016-05-12.at.6.47.38.pm.png","title":"Slider 1","descr":"This is a sample description"}, {"image":"http://camaleon.tuzitio.com/media/132/test_images/screen.shot.2016-05-12.at.6.47.47.pm.png","title":"Slider 2","descr":"This is a sample description 2"}]})
    args[:fields][:my_slider] = {
        key: 'my_slider',
        label: 'My Slider',
        render: theme_view('custom_field/my_slider.html.erb'),
        options: {
            required: true,
            multiple: true,
        },
        extra_fields:[
            {
                type: 'text_box',
                key: 'dimension',
                label: 'Dimensions',
                description: 'Crop images with dimension (widthxheight), sample:<br>400x300 | 400x | x300 | ?400x?500 | ?1400x (? => maximum, empty => auto)'
            }
        ]
    }
  end
end
