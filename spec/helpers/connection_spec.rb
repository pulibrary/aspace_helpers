# frozen_string_literal: true
require_relative '../../helper_methods'
require 'spec_helper.rb'

RSpec.describe 'connection' do
  before do
    stub_aspace_login
  end
  it 'can log in to aspace' do
    aspace_login
  end
end
