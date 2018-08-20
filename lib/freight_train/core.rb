module FreightTrain
  module Core
    include FreightTrain::Helpers::FormattingHelper
    include FreightTrain::Helpers::RowHelper

    # !todo: refactor these names?
    # !todo: refactor 'show_error_for' using LailExtensions' flash updater?



    def refresh_on_create(record, options={})
      options.merge!(ft_params)

      options       = options.with_indifferent_access
      partial_name  = options[:partial] || record.class.name.underscore
      content       = render_to_string(:partial => partial_name, :object => record)
      page          = JavascriptGenerator.new

      page.call "FT.#{ft_model_name(record)}.addRow", content
      yield page if block_given?
      render :inline => page.to_s,
             :content_type => "application/javascript"
    end



    def refresh_on_update(record, options={})
      options.merge!(ft_params)

      # this is kind of a clunky way of solving this problem; but I want row_for to know whether
      # it is creating a row or updating a row (whether it should write the TR tags or not).
      @update_row = true

      options       = options.with_indifferent_access
      id            = idof(record)
      partial_name  = options[:partial] || record.class.name.underscore
      content       = render_to_string(:partial => partial_name, :object => record)
      page          = JavascriptGenerator.new


      page.call "FT.#{ft_model_name(record)}.updateRow", id, content
      yield page if block_given?
      render :inline => page.to_s,
             :content_type => "application/javascript"
    end



    def remove_deleted(record)
      id            = idof(record)
      page          = JavascriptGenerator.new

      page.call "FT.#{ft_model_name(record)}.deleteRow", id
      yield page if block_given?
      render :inline => page.to_s,
             :content_type => "application/javascript"
    end



    def show_error(*args)
      options       = args.extract_options!.with_indifferent_access
      message       = args.first
      id            = options[:error_id] || "flash_error"
      page          = JavascriptGenerator.new

      page << <<-JS
      var e = FT.$.find_by_id('#{id}');
      if(e) {
        FT.$.replace(e, #{message.to_json});
        FT.$.show(e);
        #{!!options[:alert]} && alert(#{options[:alert].to_json});
      }
      JS
      yield page if block_given?
      render :inline => page.to_s,
             :content_type => "application/javascript"
    end



    def show_errors_for(record, options={})
      show_error(format_errors(record), options)
    end



    def ft_params
      params[:ft] || {}
    end



    class JavascriptGenerator

      def initialize
        @js = ""
      end

      def <<(*lines)
        lines.each do |line|
          @js << line << ";"
        end
      end

      def call(method, *args)
        params = args.map(&method(:javascript_object_for)).join(", ")
        self << "#{method}(#{params})"
      end

      def to_s
        @js
      end

    private

      def javascript_object_for(object)
        ::ActiveSupport::JSON.encode(object)
      end

    end



    def ft_model_name(record)
      record.class.name
    end



  end
end
