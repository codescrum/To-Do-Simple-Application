require 'spec_helper'

describe TasksController do
  # This should return the minimal set of attributes required to create a valid
  # Task. As you add validations to Task, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { name: "Buy Milk", deadline: DateTime.tomorrow, done: false }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TasksController. Be sure to keep this updated too.
  def valid_session
    { return_to: tasks_path }
  end

  describe 'task listing', :clean_db do
    describe "GET index" do
      it "assigns all tasks as @tasks" do
        task = Task.create! valid_attributes
        get :index, {}, valid_session
        assigns(:tasks).should eq([task])
      end
    end

    describe "GET done" do
      it "assigns done tasks as @tasks" do
        task = Task.create! valid_attributes.merge(done: true)
        get :done, {}, valid_session
        assigns(:tasks).should eq([task])
      end
    end

    describe "GET pending" do
      it "assigns pending tasks as @tasks" do
        task = Task.create! valid_attributes
        get :pending, {}, valid_session
        assigns(:tasks).should eq([task])
      end
    end

    describe "GET expired" do
      it "assigns tasks as @tasks" do
        task = Task.create! valid_attributes.merge(deadline: Date.yesterday)
        get :expired, {}, valid_session
        assigns(:tasks).should eq([task])
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested task as @task" do
      task = Task.create! valid_attributes
      get :edit, { :id => task.to_param }, valid_session
      assigns(:task).should eq(task)
    end

    it "redirects to previous page in session[:return_to]" do
      task = Task.create! valid_attributes
      get :edit, {:id => task.to_param }
      session.keys.should include 'return_to' #value was not set!
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Task" do
        expect {
          post :create, { :task => valid_attributes }, valid_session
        }.to change(Task, :count).by(1)
      end

      it "assigns a newly created task as @task" do
        post :create, { :task => valid_attributes }, valid_session
        assigns(:task).should be_a(Task)
        assigns(:task).should be_persisted
      end

      it "redirects to the created task" do
        post :create, { :task => valid_attributes }, valid_session
        response.should redirect_to(tasks_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved task as @task" do
        # Trigger the behavior that occurs when invalid params are submitted
        Task.any_instance.stub(:save).and_return(false)
        post :create, { :task => {} }, valid_session
        assigns(:task).should be_a_new(Task)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Task.any_instance.stub(:save).and_return(false)
        post :create, { :task => {} }, valid_session
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested task" do
        task = Task.create! valid_attributes
        # Assuming there are no other tasks in the database, this
        # specifies that the Task created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Task.any_instance.should_receive(:update_attributes).with({ 'these' => 'params' })
        put :update, {:id => task.to_param, :task => { 'these' => 'params'} }, valid_session
      end

      it "assigns the requested task as @task" do
        task = Task.create! valid_attributes
        put :update, { :id => task.to_param, :task => valid_attributes }, valid_session
        assigns(:task).should eq(task)
      end

      it "redirects to the task" do
        task = Task.create! valid_attributes
        put :update, { :id => task.to_param, :task => valid_attributes }, valid_session
        response.should redirect_to(session[:return_to])
      end
    end

    describe "with invalid params" do
      it "assigns the task as @task" do
        task = Task.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Task.any_instance.stub(:save).and_return(false)
        put :update, { :id => task.to_param, :task => {} }, valid_session
        assigns(:task).should eq(task)
      end

      it "re-renders the 'edit' template" do
        task = Task.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Task.any_instance.stub(:save).and_return(false)
        put :update, { :id => task.to_param, :task => {} }, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested task" do
      task = Task.create! valid_attributes
      expect {
        delete :destroy, { :id => task.to_param }, valid_session
      }.to change(Task, :count).by(-1)
    end

    it "redirects to the tasks list" do
      task = Task.create! valid_attributes
      delete :destroy, { :id => task.to_param }, valid_session
      response.should redirect_to(tasks_url)
    end
  end

  describe 'private methods' do
    describe "#apply_filters" do

      before do
        @controller.send :apply_filters
      end

      it 'should return a ransack search object' do
        assigns(:search).should be_a Ransack::Search
      end

      it "should modify parameters to include query parameter 'q'" do
        params.should have_key :q
      end

      it "should modify query parameters to include default sorting by deadline" do
        params[:q][:s].should == 'deadline asc'
      end

      it "should override default by-deadline sorting query parameters if params present" do
        params = { q: { s: 'anything'} }
        @controller.send :apply_filters
        params[:q][:s].should == 'anything'
      end
    end

    describe "#initialize_task" do
      it 'should initialize a brand new task instance' do
        @controller.send :initialize_task
        assigns(:task).should be_a_new Task
      end
    end
  end

  def params
    @controller.instance_eval do
      params
    end
  end

  def params=(forced_params)
    @controller.instance_eval do
      params = forced_params.with_indiferent_access
    end
  end
end
