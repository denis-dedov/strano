require 'spec_helper'
require 'rspec/mocks/standalone'

describe JobsController do

  include AuthHelper

  render_views

  before { Project.any_instance.stub({ clone_repo: true, update_data: true }) }
  before(:each) do
    class Job
      private

        def execute_task
          self.completed_at = Time.now
          save!
        end
    end
  end

  context 'athentication' do

    context 'with existing project' do
      let(:project) { Project.create(url: 'git@github.com:johndoe/unknown.git') }

        context 'with no_gui param' do
        let(:params) { { project_id: project.to_param, no_gui: true } }

        context 'with invalid login & password' do
          before { xhr :post, :create, params }

          it { should respond_with(401) }
        end

        context 'with existing user' do
          let(:wrong_password) { 'wrong password' }
          let(:correct_password) { 'correct password' }
          let(:user) { create(:user, password: correct_password) }

          context 'with invalid username & wrong password' do
            before { http_login('fake', wrong_password) }
            before { xhr :post, :create, params }

            it { should respond_with(401) }
          end

          context 'with valid username & wrong password' do
            before { http_login(user.username, wrong_password) }
            before { xhr :post, :create, params }

            it { should respond_with(401) }
          end

          context 'with valid username & password' do
            before { http_login(user.username, correct_password) }
            before { xhr :post, :create, params }

            it { should respond_with(200) }

            it "should create job" do
              assigns(:job).should be
            end
          end
        end
      end

      context 'without no_gui param' do
        let(:params) { { project_id: project.to_param } }

        context 'try to deploy' do
          before { xhr :post, :create, params }

          it { should respond_with(302) }
          it { should redirect_to(sign_in_path) }
        end
      end
    end
  end

  context 'with existing project and user' do
    let(:project) { Project.create(url: 'git@github.com:johndoe/unknown.git') }
    let(:user) { create(:user, password: 'example') }

    context 'deploying without gui' do
      let(:task) { 'deploy' }
      let(:stage) { 'staging_dp' }
      let(:branch) { 'master' }
      let(:verbosity) { 'vv' }
      let(:params) { { project_id: project.to_param, no_gui: true, task: task, stage: stage, branch: branch, verbosity: verbosity } }
      before { http_login(user.username, user.password) }
      before { xhr :post, :create, params }

      it 'should create relevant job' do

        assigns(:job).task.should == task
        assigns(:job).stage.should == stage
        assigns(:job).branch.should == branch
        assigns(:job).verbosity.should == verbosity
      end

      it 'should start job' do
        assigns(:job).completed_at.should be
      end
    end
  end
end
