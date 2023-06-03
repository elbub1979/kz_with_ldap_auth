# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }
  describe '#short_name' do
    context 'without name' do
      it 'return username' do
        expect(user.short_name).to eq 'username1'
      end
    end
    context 'with last name' do
      it 'return last name' do
        user.update_column(:name, 'Petrov')
        expect(user.short_name).to eq 'Petrov'
      end
    end
    context 'with last name and first name' do
      it 'return last name and first letter in first name' do
        user.update_column(:name, 'Petrov Petr')
        expect(user.short_name).to eq 'Petrov P.'
      end
    end
    context 'with last name, first name and patronymic name' do
      it 'return last name and first letters in first name and patronymic name' do
        user.update_column(:name, 'Petrov Petr Petrovich')
        expect(user.short_name).to eq 'Petrov P.P.'
      end
    end
  end
  describe 'enum' do
    context 'default enum' do
      it 'return basic role by default' do
        expect(user.role).to eq 'basic'
      end
    end
    context 'admin enum' do
      it 'return admin role' do
        user.update_column(:role, '1')
        expect(user.role).to eq 'admin'
      end
    end
  end
end
