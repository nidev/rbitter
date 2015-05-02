# encoding: utf-8
require "rbitter/dlthread"

describe Rbitter::DLThread do
  # TODO:
  #t = DLThread.new(".")
  #t << ["https://www.google.co.kr/images/nav_logo195.png"]
  #sleep 4

  it 'is presented' do
    expect(Rbitter::DLThread).to be_a(Class)
  end
end
