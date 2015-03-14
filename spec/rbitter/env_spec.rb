# encoding: utf-8

require "rbitter"

describe Rbitter do
  it 'has env_reset function and clears Rbitter.env,' do
    Rbitter.env_reset
    expect(Rbitter.env).to be_a(Hash)
    expect(Rbitter.env.length).to be(0)
  end

  context 'when config.json is not installed,' do
    it 'fails on loading' do
      expect{Rbitter.config_initialize}.to raise_error(Rbitter::ConfigurationFileError)
    end
  end

  context 'when path to config.json is invalid,' do
    it 'fals on loading' do
      expect{Rbitter.config_initialize("/silly/dummy/.")}.to raise_error(Rbitter::ConfigurationFileError)
    end
  end


  context 'when default config.json is installed,' do
    before(:all) do
      Rbitter.bootstrap(['configure'])
      expect(File.file?('config.json')).to be(true)
    end

    it 'loads configuration successfully with autodetection' do
      expect{Rbitter.config_initialize}.to_not raise_error
    end

    it 'makes Rbitter.env provide config.json contents' do
      expect(Rbitter.env.length > 0).to be(true)
    end

    it 'loads configuration successfully with given config.json path' do
      expect{Rbitter.config_initialize('config.json')}.to_not raise_error
    end

    it 'checks that Rbitter.env returns Hash' do
      expect(Rbitter.env).to be_a(Hash)
    end

    after(:all) do
      File.delete('config.json')
    end
  end

  context 'when config.json is corrupted' do
    # TODO: Perform test with spec/config/default.json
    # TODO: Adding configuration validator on env.rb
  end

  # TODO: Perform test with spec/config/default.json
end
