module FreightTrain
  module Helpers
    module PageScriptHelper


      def make_interactive(path, table_name, options)
        options[:destroy] = true unless options.key?(:destroy)
    
        html = "<script type=\"text/javascript\">\n" << 
           "//<![CDATA[\n" <<
       
           # create a namespace for record-specific functions
           "FT.#{table_name.classify}=(function(){\n" <<
           "  var path='#{path}';\n" <<
           "  var obsv=new Observer();\n" 
       
        if @inline_editor
          html << "  var editor_writer=#{editor_writer_method(table_name, options)};\n"
          html << "  InlineEditor.observe('after_init', #{after_edit_method(table_name, options)});\n"
        end
      
          html << "  return {\n" <<
               "    path: function(){return path;},\n" <<
               "    observe: function(n,f){obsv.observe(n,f);},\n" <<
               "    unobserve: function(n,f){obsv.unobserve(n,f);},\n" <<
               "    update_in_place: function(property,id,value){FT.xhr((path+'/'+id+'/update_'+property),'put',('#{table_name.singularize}['+property+'='+value));},\n"
          html << "    #{destroy_method(table_name, options)},\n" if options[:destroy]
          html << "    #{hookup_row_method options}\n" <<
               "  };\n" <<
               "})();\n"
           
        # methods in global namespace
        if options[:reset_on_create] != :none
          options[:reset_on_create] = :all unless options[:reset_on_create].is_a?(Array)
          html << reset_on_create_method(table_name, options) << "\n"
        end
      
          html << "//]]>\n" <<
               "</script>\n"
        @already_defined = true
        html
      end
  
  
  
      # !todo: move as much of this as possible to core.js
      def ft_init(options={})
        if @already_initialized
          return ""
        else
          @already_initialized = true
        end
        <<-HTML
        <script type="text/javascript">
          //<![CDATA[
          FT.init({
            token: '#{request_forgery_protection_token}='+encodeURIComponent('#{escape_javascript(form_authenticity_token)}'),
            enable_keyboard_navigation: #{options[:enable_keyboard_navigation] || false}
          });
          //]]>
        </script>
        HTML
      end


    private
  
  
  
      def destroy_method(table_name, options)
        msg = options.key?(:confirm) ? options[:confirm] : "Delete #{table_name.to_s.singularize.titleize}?"
        "destroy: function(idn){" <<
          "return FT.destroy(#{msg ? "'#{msg}'" : "false"},('#{table_name.to_s.singularize}_'+idn),(path+'/'+idn));" <<
        "}"
      end
  
  
  
      def hookup_row_method(options)
        content = "hookup_row: function(row){"
        content << "if(row.hasClassName('interactive')) {FT.Helpers.hoverRow(row);}"
        if @inline_editor
          content << "if(row.hasClassName('editable')) {FT.Helpers.editRowInline(row,path,editor_writer);}"
        elsif (options[:editable] != false)
          if (fn=options[:editor])
            content << "if(row.hasClassName('editable')) FT.Helpers.editRow(row,#{fn});"
          else
            content << "if(row.hasClassName('editable')) FT.Helpers.editRow(row,path);"
          end
        end
        content << "obsv.fire('hookup_row',row);"
        content << "}"
      end
  
  
  
      def reset_on_create_method(table_name, options)
        arg = options[:reset_on_create]
        "$(document.body).observe('ft:create', function(event) {" <<
          "$$('form[data-model=\"#{table_name.classify}\"] #add_row').each(function(row){" <<
            "FT.reset_form_fields_in(row" << ((arg == :all) ? "" : ", {only: #{arg.to_json}}") << ");" <<
            "FT.select_first_field_in(row);" <<
          "});" <<
        "});"
      end
  
  
  
      def editor_writer_method(table_name, options)
        "function(tr){" <<  
          "var e;" <<
          "var html='" << @inline_editor.gsub(/\r|\n/, " ").gsub(/\s+</, " <").gsub(/>\s+/, "> ") << "';" <<
          "var tr_edit = $(document.createElement('#{FreightTrain.tag(:tr)}'));" << 
          "tr_edit.className = 'row editor #{table_name}';" << 
          "tr_edit.id = 'edit_row';" << 
          "tr_edit.update(html);" << 
          "return tr_edit;" <<
        "}"
      end
  
  
  
      def after_edit_method(table_name, options)
        content =  "function(tr,tr_edit){"
        content <<   "if(tr.up('form[data-model=\"#{table_name.classify}\"]')){"
        content <<     "tr_edit.select('.nested').each(FT.reset_add_remove_for);" if @enable_nested_records
        content <<     @after_init_edit if @after_init_edit
        content <<   "}"
        content << "}"
      end
  
  
  
    end
  end
end