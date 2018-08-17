class FormTestsController < ApplicationController
  uses_freight_train
  respond_to :html

  def index
    @form_tests = FormTest.all
    respond_with @form_tests
  end

  def new
    @form_test = FormTest.new
    respond_with @form_test
  end

  def create
    attributes = params[:form_test]
    attributes[:money] = Money.from_hash(attributes.delete(:money))
    @form_test = FormTest.new(attributes)
    @form_test.save
    respond_with @form_test
  end

  def update
    @form_test = FormTest.find(params[:id])
    attributes = params[:form_test]
    attributes[:money] = Money.from_hash(attributes.delete(:money))
    @form_test.update_attributes(attributes)
    respond_with @form_test
  end

  def destroy
    @form_test = FormTest.find(params[:id])
    @form_test.destroy
    respond_with @form_test
  end
end
