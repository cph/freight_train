module FreightTrain
  module Helpers
    module PageScriptHelper
      
      
      
      def make_interactive(path, table_name, options)
        options[:destroy] = true unless options.key?(:destroy)
        model_name = table_name.classify
        
        javascript_tag do
          raw <<-JS
            var FT=window.FT||{};
            FT.#{model_name}=(function(){
              var name='#{model_name}', collection='#{table_name}', path='#{path}', o, editor_writer=#{editor_writer_method(table_name.singularize)};
              return {
                 init: function(){o=new Observer();#{reset_on_create_method(table_name, options)}}
               , collection: function(){return collection;}
               , path: function(){return path;}
               , observe: function(n,f){o.observe(n,f);}
               , unobserve: function(n,f){o.unobserve(n,f);}
               #{initialize_editor_method(table_name, options)}
               #{activate_editing_method(table_name, options)}
               #{update_in_place_method(table_name)}
               #{destroy_method(table_name, options)}
               #{hookup_row_method options}
              };
            })();
          JS
        end
      end
      
      
      
      def include_freight_train(options={})
        adapter = options[:adapter].to_s
        adapter = "prototype" unless %w{prototype jquery}.member?(adapter)
        adapter_js = "freight_train/#{adapter}_adapter.js"
        
        raw <<-HTML
          #{javascript_include_tag('freight_train/observer.js')}
          #{javascript_include_tag('freight_train/inline_editor.js')}
          #{javascript_include_tag('freight_train/core.js')}
          #{javascript_include_tag(adapter_js)}
          #{ft_init(options)}
        HTML
      end
      
      
      
      def ft_init(options={})
        unless @already_initialized
          @already_initialized = true
          javascript_tag do
            raw <<-JS
              FT.init({
                token: '#{request_forgery_protection_token}='+encodeURIComponent('#{escape_javascript(form_authenticity_token)}'),
                adapter: #{options[:adapter].to_json},
                enable_keyboard_navigation: #{options[:enable_keyboard_navigation] || false}
              });
            JS
          end
        end
      end
      
      
      
    private
      
      
      
      def editor_writer_method(singular)
        editor_fn = @inline_editor.to_s.gsub(/\r|\n/, " ").gsub(/\s+</, "<").gsub(/>\s+/, ">")
        if editor_fn.blank?
          editor_fn = "return null;"
        else
          editor_fn = "var html='#{editor_fn}';" <<
                      "return FT.Helpers.createEditor('#{FreightTrain.tag(:tr)}',html,'#{singular}');"
        end
        "function(tr){#{editor_fn}}"
      end
      
      
      
      def reset_on_create_method(table_name, options)
        "FT.Helpers.resetOnCreate(name, #{options[:reset_on_create].to_json});"
      end
      
      
      
      def initialize_editor_method(table_name, options)
        ", initializeEditor: function(tr,tr_edit){#{@after_init_edit}}"
      end
      
      
      
      def activate_editing_method(table_name, options)
        if @inline_editor != "function(tr){}"
          ", activateEditing: function(row){FT.Helpers.editRowInline(row,path,editor_writer);}"
        elsif (options[:editable] != false)
          ", activateEditing: function(row){FT.Helpers.editRow(row,path);}"
        end
      end
      
      
      
      def update_in_place_method(table_name)
        ", updateInPlace: function(property,id,value){" <<
          "FT.xhr((path+'/'+id+'/update_'+property),'put',('#{table_name.singularize}['+property+']='+value));" <<
        "}"
      end
      
      
      
      def destroy_method(table_name, options)
        msg = options.key?(:confirm) ? options[:confirm] : "Delete #{table_name.to_s.singularize.titleize}?"
        ", destroy: function(idn){" <<
          "return FT.destroy(#{msg ? "'#{msg}'" : "false"},('#{table_name.to_s.singularize}_'+idn),(path+'/'+idn));" <<
        "}"
      end
      
      
      
      def hookup_row_method(options)
        ", hookupRow: function(row){" <<
          "o.fire('hookup_row',row);" <<
        "}"
      end
      
      
      
    end
  end
end