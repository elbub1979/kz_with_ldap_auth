require 'rails_helper'

RSpec.describe User, type: :model do
    let(:user) { create(:user) }

    describe '#short_name' do
      context 'without name' do
        it '123' do
          expect(user.name).to eq '123'
        end
      end
    end

  #describe '#save' do
  #  describe 'instance attribute name ' do
  #    it 'name present' do
  #      user = User.create(username: 'user', name: 'test_user')

  #      expect(user.name).to eq 'test_user'
  #    end
  #    it 'name NOT present' do
  #      user = User.create(username: 'user')

  #      expect(user.name).to eq 'user'
  #    end
  #  end
  # end
    it 'can not have comment' do
    end
end
