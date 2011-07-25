module FreightTrain
  module Helpers
    module RowHelper
      
      
      # delegate :concat, :alt_content_tag, :fields_for, :to => :@template
      
      # this doesn't work when records are recreated
      # attr_reader :model_name # !HACK!
      
      def row_for(record, *args, &block)
        options = args.extract_options!.reverse_merge!(
          :last_child => true)
        singular = record.class.name.tableize.singularize
        
        if @update_row
          raw_or_concat row_guts_for(record, options, &block)
        else
          css = ["row", singular]
          disabled = (options.key?(:disabled) ? options[:disabled] : false)
          interactive = (options.key?(:interactive) ? options[:interactive] : true)
          editable = (options.key?(:editable) ? options[:editable] : true)
          interactive = true if editable
          interactive, editable = false, false if disabled
          css << "disabled" if disabled
          css << "interactive" if interactive
          css << "editable" if editable
          
          # this makes striping work on IE7 and Firefox 3
          @alt = !@alt
          css << "alt" if !@alt
          css << options[:class] if options[:class]
          
          raw_or_concat( alt_content_tag(:tr, :class => css.join(" "), :id => idof(record), :name => singular) {
            row_guts_for(record, options, &block)
          })
        end
      end
      
      
      
      def idof(record)
        raise(ArgumentError, "'record' cannot be nil") if record.nil?
        "#{record.class.name.underscore}_#{record.to_param}"
      end
      
      
      
    private
      
      
      
      def row_guts_for(record, options, &block)
        # name = ActionController::RecordIdentifier.singular_class_name(record)
        name = record.class.name.tableize.singularize
        builder = FreightTrain::Builders::RowBuilder.default_row_builder.new(self, name, record, options)
        html = capture(builder, &block)
        html << last_child(builder, options) unless !options[:last_child] or builder.commands_called?
        html
      end
      
      
      
      def last_child(builder, options)
        (alt_content_tag :td, :class => "last-child" do # IE7 doesn't support the CSS selector :last-child
          builder.commands_for(options[:commands])
        end)
      end
      
      
      
    end
  end
end