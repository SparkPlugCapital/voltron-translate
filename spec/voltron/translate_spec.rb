require "rails_helper"

describe Voltron::Translate do

	include Voltron::Translate

	before(:all) do
		Voltron.config.debug = false
		Voltron.config.translate.build_environment = :test
	end

	after(:all) { Voltron.config.debug = true }

	before(:each) { translator(:test).destroy }

	let(:translate) { translator(:test) }

	it "has a version number" do
		expect(Voltron::Translate::VERSION).not_to be nil
	end

	it "should log an error and return original interpolated text if locale is invalid" do
		Voltron.config.debug = false
		expect(Voltron.config.logger).to receive(:info).with("Locale can only contain the characters A-Z, and _ (Original Translation Text: Test)")
		__("Test", 123)
		Voltron.config.debug = true
	end

	it "should not translate if disabled" do
		translate["Test 1"] = "Test 2"

		Voltron.config.translate.enabled = false
		expect(__("Test 1", :test)).to eq("Test 1")

		Voltron.config.translate.enabled = true
		expect(__("Test 1", :test)).to eq("Test 2")
	end

	it "should write translations if not already existing" do
		expect(translate.list.length).to eq(0)

		__("Test", :test)
		expect(translate.list.length).to eq(1)
	end

	it "should not write translations if already exists" do
		expect(translate.list.length).to eq(0)

		__("Test", :test)
		expect(translate.list.length).to eq(1)

		__("Test", :test)
		expect(translate.list.length).to eq(1)
	end

	it "should reload the list if the translation file is modified" do
		expect(__("Test 1", :test)).to eq("Test 1")

		# Wait one second so the mtime will be at least 1 second different after the write operation
		sleep 1
		CSV.open(translate.path, "w", force_quotes: true) { |f| f.puts ["Test 1", "Test 2"] }

		expect(__("Test 1", :test)).to eq("Test 2")
	end
end
