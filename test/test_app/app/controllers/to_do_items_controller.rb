class ToDoItemsController < ApplicationController
  uses_freight_train
  respond_to :html
  
  def index
    @to_do_items = ToDoItem.all
    respond_with @to_do_items
  end
  
  def new
    @to_do_item = ToDoItem.new
    respond_with @to_do_item
  end
  
  def create
    @to_do_item = ToDoItem.new(params[:to_do_item])
    @to_do_item.save
    respond_with @to_do_item
  end
  
  def update
    @to_do_item = ToDoItem.find(params[:id])
    @to_do_item.update_attributes(params[:to_do_item])
    respond_with @to_do_item
  end
  
  def destroy
    @to_do_item = ToDoItem.find(params[:id])
    @to_do_item.destroy
    respond_with @to_do_item
  end
end