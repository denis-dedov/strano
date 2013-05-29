require 'spec_helper'
require 'rspec/mocks/standalone'

describe ProjectsController do

  include AuthHelper

  render_views

  before { Project.any_instance.stub({ clone_repo: true, update_data: true }) }

  context 'with existing project' do
    let(:project) { Project.create(url: 'git@github.com:johndoe/unknown.git') }

    context 'with invalid login & password' do
      before { xhr :get, :deploy, id: project.to_param }

      it { should respond_with(401) }
    end

    context 'with existing user' do
      let(:wrong_password) { 'wrong password' }
      let(:correct_password) { 'correct password' }
      let(:user) { create(:user, password: correct_password) }

      context 'with invalid username & wrong password' do
        before { http_login('fake', wrong_password) }
        before { xhr :get, :deploy, id: project.to_param }

        it { should respond_with(401) }
      end

      context 'with valid username & wrong password' do
        before { http_login(user.username, wrong_password) }
        before { xhr :get, :deploy, id: project.to_param }

        it { should respond_with(401) }
      end

      context 'with valid username & password' do
        before { http_login(user.username, correct_password) }
        before { xhr :get, :deploy, id: project.to_param }

        it { response.should be_ok }
      end
    end
  end
end
