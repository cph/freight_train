class QuestionsController < ApplicationController
  uses_freight_train
  respond_to :html

  def index
    @questions = Question.all
    @new_question = Question.new.tap {|q| q.answers.build}
    respond_with @questions
  end

  def new
    @question = Question.new
    respond_with @question
  end

  def create
    @question = Question.new(params[:question])
    @question.save
    respond_with @question
  end

  def update
    @question = Question.find(params[:id])
    @question.update_attributes(params[:question])
    respond_with @question
  end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    respond_with @question
  end
end
