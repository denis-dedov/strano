require 'spec_helper'
require 'digest/sha1'

describe User do

  describe "upload Strano SSH key to users Github account after creation" do
    use_vcr_cassette 'Github_Key/_create', :erb => true

    it "should upload SSH key to Github" do
      user = FactoryGirl.create(:user)
      user.ssh_key_uploaded_to_github?.should == true
    end
  end

  describe "#authorized_for_github?" do
    before(:each) { User.disable_ssh_github_upload = true }

    it { FactoryGirl.build(:user, :github_access_token => nil).authorized_for_github?.should == false }
    it { FactoryGirl.create(:user).authorized_for_github?.should == true }
  end

  describe "#github" do
    before(:each) { User.disable_ssh_github_upload = true }

    it { FactoryGirl.build(:user, :github_access_token => nil).github.should be_nil }
    it { FactoryGirl.create(:user).github.should be_a(Github) }
  end

end

describe User do
  let(:password) { 'password' }
  let(:user) { create(:user, password: password) }
  context 'hashed password' do
    subject { user }

    its(:hashed_password) { should == Digest::SHA1.hexdigest(password) }
  end

  context 'checking password' do
    context 'with correct password' do
      let(:check) { user.check_password(password) }

      it 'should return true' do
        check.should be_true
      end
    end

    context 'with incorrect password' do
      let(:check) { user.check_password('incorrect') }

      it 'should return true' do
        check.should be_false
      end
    end
  end

  context 'try to login' do
    context 'with invalid user name' do
      let(:current_user) { User.try_to_login('fake', 'password') }

      it 'should return nil' do
        current_user.should be_nil
      end
    end

    context 'with valid username and invalid password' do
      let(:current_user) { User.try_to_login(user.username, 'fake password') }

      it 'should return nil' do
        current_user.should be_nil
      end
    end

    context 'with valid username and password' do
      let(:current_user) { User.try_to_login(user.username, user.password) }

      it 'should return current user' do
        current_user.should == user
      end
    end
  end
end
