# encoding: utf-8
require "rbitter/records"

describe Rbitter::Record do
  # TODO: Perform test...
  it 'has ActiveRecord class named Record' do
    expect(Rbitter::Record).to be_a(Class)
  end

  it 'has supportive module of ActiveRecord' do
    expect(ARSupport).to be_a(Module)
  end
end
