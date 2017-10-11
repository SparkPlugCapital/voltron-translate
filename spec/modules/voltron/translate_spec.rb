require 'spec_helper'

describe Voltron::Translate, type: :module do

  include Voltron::Translate

  before(:all) do
    Voltron.config.debug = false
    Voltron.config.translate.build_environment = :test
    Voltron.config.translate.locales = [:test]
  end

  after(:all) { Voltron.config.debug = true }

  before(:each) do
    Rails.cache.clear
    translator(:test).destroy
  end

  let(:translate) { translator(:test) }

  it 'has a version number' do
    expect(Voltron::Translate::VERSION).not_to be nil
  end

  it 'should log an error and return original interpolated text if locale is invalid' do
    expect(Voltron.config.logger).to receive(:info).with('Locale can only contain the characters A-Z, and _ (Original Translation Text: Test)')
    'Test'._(123)
  end

  it 'should not translate if disabled' do
    CSV.open(translator(:test).path, 'a', force_quotes: true) { |f| f.puts ['Test 1', 'Test 2'] }

    Voltron.config.translate.enabled = false
    expect('Test 1'._(:test)).to eq('Test 1')

    Voltron.config.translate.enabled = true
    expect('Test 1'._(:test)).to eq('Test 2')
  end

  it 'should write translations if not already existing' do
    expect(translator(:test).full_list.length).to eq(0)
    'Test'._(:test)
    expect(translator(:test).full_list.length).to eq(1)
  end

  it 'should not write translations if already exists' do
    expect(translator(:test).full_list.length).to eq(0)

    'Test'._(:test)
    expect(translator(:test).full_list.length).to eq(1)

    'Test'._(:test)
    expect(translator(:test).full_list.length).to eq(1)
  end

  it 'should reload the list if the translation file is modified' do
    expect('Test 1'._(:test)).to eq('Test 1')

    sleep 1
    CSV.open(translator(:test).path, 'a', force_quotes: true) { |f| f.puts ['Test 1', 'Test 2'] }

    expect('Test 1'._(:test)).to eq('Test 2')
  end
end
