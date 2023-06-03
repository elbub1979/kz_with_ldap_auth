# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "username#{n}" }
  end
end
