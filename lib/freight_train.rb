require 'freight_train/responder'


# to be mixed into an ActionController
module FreightTrain
  
  
  def FreightTrain.tag(tag)
    tags[tag] || tag
  end
  def FreightTrain.tags
    @@tags ||= {
      :table => :div,
      :tbody => :ol,
      :thead => :ol,
      :tr => :li,
      :th => :div,
      :td => :div
    }
  end
  def FreightTrain.tags=(new_tags)
    @@tags = new_tags
  end
  
  
  def self.included(other_module)
    
    # include all FreightTrain helpers
    dir = File.expand_path(File.join(File.dirname(__FILE__), 'freight_train', 'helpers'))
    p dir
    # dir = "vendor/plugins/freight_train/lib/freight_train/helpers"
    extract = /^#{Regexp.quote(dir)}\/?(.*).rb$/
    Dir["#{dir}/**/*_helper.rb"].each do |file|
      h = "freight_train/helpers/#{file.sub(extract,'\1')}"
      require h
      # puts "ActionController::Base.add_template_helper(#{h.camelize.constantize})"
      # ActionController::Base.add_template_helper(h.camelize.constantize)
      other_module.send :helper, h.camelize.constantize
    end
    
    ActionView::Base.default_form_builder = FreightTrain::Builders::FormBuilder
    
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
      self.responder = FreightTrain::Responder
    end
    
    
  end
  
  
  include FreightTrain::Core
end



# TODO: require everything in the freight_train directory?
dir = "vendor/plugins/freight_train/lib/freight_train/builders"
extract = /^#{Regexp.quote(dir)}\/?(.*).rb$/
Dir["#{dir}/**/*.rb"].each do |file|
  h = "freight_train/builders/#{file.sub(extract,'\1')}"
  require h
end

require 'freight_train/extensions/request'