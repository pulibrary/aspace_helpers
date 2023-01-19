# frozen_string_literal: false

require_relative '../../../reports/aspace2alma/get_ao2MARC_data.rb'
require 'spec_helper.rb'

RSpec.describe 'regular aspace2alma process' do
  it "turns literal ampersands into html entities" do
    expect(entify_ampersands("Jack & Jill")).to eq("Jack &amp; Jill")
    expect(entify_ampersands("Jack & Jill")).to eq("Jack &amp; Jill")
    expect(entify_ampersands("Jack&nbsp;&amp; Jill")).to eq("Jack&nbsp;&amp; Jill")
    expect(entify_ampersands("Jack&Jill")).to eq("Jack&amp;Jill")
    expect(entify_ampersands("Jack &quot; Jill")).to eq("Jack &quot; Jill")
  end
end
