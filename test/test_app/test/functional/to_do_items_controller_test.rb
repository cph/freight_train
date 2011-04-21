require 'test_helper'

class ToDoItemsControllerTest < ActionController::TestCase
  setup do
    @to_do_item = to_do_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:to_do_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create to_do_item" do
    assert_difference('ToDoItem.count') do
      post :create, :to_do_item => @to_do_item.attributes
    end

    assert_redirected_to to_do_item_path(assigns(:to_do_item))
  end

  test "should show to_do_item" do
    get :show, :id => @to_do_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @to_do_item.to_param
    assert_response :success
  end

  test "should update to_do_item" do
    put :update, :id => @to_do_item.to_param, :to_do_item => @to_do_item.attributes
    assert_redirected_to to_do_item_path(assigns(:to_do_item))
  end

  test "should destroy to_do_item" do
    assert_difference('ToDoItem.count', -1) do
      delete :destroy, :id => @to_do_item.to_param
    end

    assert_redirected_to to_do_items_path
  end
end
