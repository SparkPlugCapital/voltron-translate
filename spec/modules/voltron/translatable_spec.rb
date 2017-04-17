require 'rails_helper'

describe Voltron::Translatable, type: :module do

  let(:company) { FactoryGirl.build(:company) }

  before(:each) do
    Voltron.config.translate.locales = [:en, :es, :de, :"en-GB"]
  end

  it 'should have a translates class method' do
    expect(company.class).to respond_to(:translates)
  end

  it 'should have a translations association' do
    expect(company.class.reflect_on_all_associations(:has_many).map(&:name)).to include :translations
  end

  it 'creates locale specific methods for defined attributes' do
    [:name_en, :name_en=, :name_en?, :name_en_changed?, :name_en_was, :name_en_will_change!].each do |m|
      expect(company.methods).to include m
    end
  end

  it 'should flag a modified attribute as having changes' do
    expect(company.changes).to be_blank
    company.name_es = 'Test'
    expect(company.changes).to_not be_blank
    expect(company.changes).to have_key('name_es')
    expect(company.changes['name_es']).to eq([nil, 'Test'])
  end

  it 'should be changed?' do
    company.name_es = 'Test'
    expect(company.name_es_changed?).to eq(true)
  end

  it 'can force an attribute to be changed' do
    expect(company.name_es_changed?).to eq(false)
    company.name_es_will_change!
    expect(company.name_es_changed?).to eq(true)
  end

  it 'will return whether attribute is present' do
    expect(company.name_es?).to eq(false)
    company.name_es = 'Test'
    expect(company.name_es?).to eq(true)
  end

  it 'should return the previous value of the translation' do
    expect(company.name_es).to eq(nil)
    company.name_es = 'Test'
    expect(company.name_es).to eq('Test')
    expect(company.name_es_was).to eq(nil)
  end

  it 'should return the text in the current I18n locale, if defined' do
    company.assign_attributes(name: 'Test Original', name_es: 'Test Spanish', name_de: 'Test German')
    company.save

    I18n.locale = :en
    expect(company.name).to eq('Test Original')

    I18n.locale = :es
    expect(company.name).to eq('Test Spanish')

    I18n.locale = :de
    expect(company.name).to eq('Test German')
  end

  it 'should return the text in the defined locale' do
    company.assign_attributes(name: 'Test Original', name_es: 'Test Spanish', name_de: 'Test German')
    company.save

    I18n.locale = :en

    expect(company.name).to eq('Test Original')
    expect(company.name(:es)).to eq('Test Spanish')
    expect(company.name(:de)).to eq('Test German')
    expect(company.name(:invalid)).to eq('Test Original')
  end

  it 'should return the text in the default locale when specified' do
    company.assign_attributes(name: 'Test Original', name_es: 'Test Spanish', name_de: 'Test German')
    company.save

    company.class.translates :name, default: :es

    # Set to english locale, to ensure our default is working
    I18n.locale = :en

    expect(company.name).to eq('Test Spanish')
  end

  it 'should raise UnknownAttributeError if defined translation attribute does not exist' do
    expect { company.class.translates(:bologne) }.to raise_error(ActiveRecord::UnknownAttributeError)
  end

  it 'should raise InvalidColumnTypeError if defined translation attribute is not of type [string, text]' do
    expect { company.class.translates(:id) }.to raise_error(Voltron::Translate::InvalidColumnTypeError)
  end

end
