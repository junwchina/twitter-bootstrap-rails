require 'rails/generators'

module Bootstrap
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      source_root File.expand_path("../templates", __FILE__)
      desc "This generator installs Bootstrap to Asset Pipeline"
      argument :stylesheets_type, :type => :string, :default => 'static', :banner => '*less or static'

      def add_assets

        js_manifest = 'app/assets/javascripts/application.js'

        if File.exist?(js_manifest)
          insert_into_file js_manifest, "//= require twitter/bootstrap\n", :after => "jquery_ujs\n"
        else
          copy_file "application.js", js_manifest
        end

        css_manifest = 'app/assets/stylesheets/application.css'

        if File.exist?(css_manifest)
          # Add our own require:
          content = File.read(css_manifest)
          if content.match(/require_tree\s+\.\s*$/)
            # Good enough - that'll include our bootstrap_and_overrides.css.less
          else
            style_require_block = " *= require bootstrap_and_overrides\n"
            insert_into_file css_manifest, style_require_block, :after => "require_self\n"
          end
        else
          copy_file "application.css", "app/assets/stylesheets/application.css"
        end

      end

      def add_bootstrap
        if use_coffeescript?
          copy_file "bootstrap.coffee", "app/assets/javascripts/bootstrap.js.coffee"
        else
          copy_file "bootstrap.js", "app/assets/javascripts/bootstrap.js"
        end
        copy_file "bootstrap_and_overrides.css", "app/assets/stylesheets/bootstrap_and_overrides.css"
      end

      def add_locale
        if File.exist?("config/locales/en.bootstrap.yml")
          localez = File.read("config/locales/en.bootstrap.yml")
          insert_into_file "config/locales/en.bootstrap.yml", localez, :after => "en\n"
        else
          copy_file "en.bootstrap.yml", "config/locales/en.bootstrap.yml"
        end
      end

    private
      def use_coffeescript?
        ::Rails.configuration.app_generators.rails[:javascript_engine] == :coffee
      end
    end
  end
end
