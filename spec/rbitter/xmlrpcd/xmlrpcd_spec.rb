# encoding: utf-8

require "rbitter/xmlrpcd/xmlrpcd"

describe Rbitter do
  it 'Rbitter is a module' do
    expect(Rbitter.class === Module).to be(true)
  end
end
