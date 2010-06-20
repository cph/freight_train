class FreightTrain::Builders::CheckListBuilder

  delegate :tag, :to => :@template

  def initialize(method, array, value, template)
    @method, @array, @value, @template = method, array, value, template
  end

  def check_box(*args)
    options = args.extract_options!
    options.merge!(
      :type => "checkbox",
      :id => "#{@method}_#{@value}".parameterize('_'),
      :name => "#{@method}[]",
      :value => @value)
    options.merge!(:checked => "checked") if @array.member?(@value)
    tag(:input, options)
=begin
    content = "<input type=\"checkbox\" name=\"#{@method}[]\" value=\"#{@value}\""
    content << " checked=\"checked\"" if @array.member?(@value)
    content << " />"
=end    
  end

end