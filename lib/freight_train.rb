# to be mixed into an ActionController
module FreightTrain
  include FreightTrain::Core
  
  
  Tags = {
    :table => :table,
    :thead => :thead,
    :tbody => :tbody,
    :tr => :tr,
    :th => :th,
    :td => :td
  }
  
  
  def self.included(other_module)
    
    # include all FreightTrain helpers
    dir = "vendor/plugins/freight_train/lib/freight_train/helpers"
    extract = /^#{Regexp.quote(dir)}\/?(.*).rb$/
    Dir["#{dir}/**/*_helper.rb"].each do |file|
      h = "freight_train/helpers/#{file.sub(extract,'\1')}"
      require h
      # puts "ActionController::Base.add_template_helper(#{h.camelize.constantize})"
      # ActionController::Base.add_template_helper(h.camelize.constantize)
      other_module.send :helper, h.camelize.constantize
    end
    
    other_module.extend ClassMethods
  end
  
  
  module ClassMethods

    # allows substituting builders
    def default_form_builder; ActionView::Base.default_form_builder; end
    def default_form_builder=(value); ActionView::Base.default_form_builder = value; end
    def default_row_builder; FreightTrain::Builders::RowBuilder.default_row_builder; end
    def default_row_builder=(value); FreightTrain::Builders::RowBuilder.default_row_builder = value; end  
    def default_editor_builder; FreightTrain::Builders::EditorBuilder.default_editor_builder; end
    def default_editor_builder=(value); FreightTrain::Builders::EditorBuilder.default_editor_builder = value; end
    
    
    # TODO: accept parameters e.g. :paginate => {:per_page => 20}
    def uses_freight_train
      define_method "responder" do
        FreightTrain::Responder
      end
    end


  end

  ActionView::Base.default_form_builder = FreightTrain::Builders::FormBuilder

end


# TODO: require everything in the freight_train directory?
dir = "vendor/plugins/freight_train/lib/freight_train/builders"
extract = /^#{Regexp.quote(dir)}\/?(.*).rb$/
Dir["#{dir}/**/*.rb"].each do |file|
  h = "freight_train/builders/#{file.sub(extract,'\1')}"
  require h
end

require 'freight_train/extensions/java_script_generator'