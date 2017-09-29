# frozen_string_literal: true

require 'spec_helper'

describe BetterEnv do
  let(:options) { {} }
  let(:env_files) { [{ 'file1' => [] }] }
  let(:environment) { {} }

  def add_file_stubs
    env_files.each do |file|
      name, content = file.first
      allow(File).to receive(:exist?).with(name).and_return(true)
      allow(File).to receive(:readlines).with(name).and_return(content)
    end
  end

  def stub_environment(hash, &block)
    ClimateControl.modify(hash, &block)
  end

  def load_subject
    described_class.load(options, env_files.map { |file| file.keys.first })
  end

  before do |example|
    unless example.metadata[:skip_before]
      add_file_stubs
      stub_environment(environment) { load_subject }
    end
  end

  it 'has a version number' do
    expect(BetterEnv::VERSION).not_to be nil
  end

  context 'when passing the configuration' do
    context 'when the configuration is a hash' do
      let(:options) { { 'VAR' => { 'default' => false, 'type' => 'boolean' } } }

      it 'applies it correctly' do
        expect(BetterEnv[:VAR]).to eq false
      end
    end

    context 'when the configuration is a filename', skip_before: true do
      let(:options) { filename }
      let(:filename) { 'some_file.yml' }

      it 'reads the file contents' do
        add_file_stubs
        expect(YAML).to receive(:load_file).with(filename).and_return({})
        load_subject
      end
    end
  end

  context 'when accessing a value' do
    let(:options) { { 'VALUE' => { 'type' => 'string' } } }
    let(:env_files) do
      [{ 'file' => ['VALUE=one'] }]
    end

    it 'it accepts a string' do
      expect(BetterEnv['VALUE']).to eq 'one'
    end

    it 'it accepts a symbol' do
      expect(BetterEnv[:VALUE]).to eq 'one'
    end
  end

  context 'value precedence' do
    let(:options) do
      { 'VARIABLE' => { 'type' => 'boolean' } }
    end

    context 'when there are duplicate variables' do
      context 'in multiple files' do
        let(:env_files) do
          [{ 'file1' => ['VARIABLE=true'] }, { 'file2' => ['VARIABLE=false'] }]
        end

        it 'the last file has precedence' do
          expect(BetterEnv[:VARIABLE]).to eq false
        end
      end

      context 'in one file' do
        let(:env_files) do
          [{ 'file' => ['VARIABLE=true', 'VARIABLE=false'] }]
        end

        it 'the last occurence has precedence' do
          expect(BetterEnv[:VARIABLE]).to eq false
        end
      end

      context 'in ENV and in a file' do
        let(:environment) { { VARIABLE: 'false' } }
        let(:env_files) do
          [{ 'file' => ['VARIABLE=true'] }]
        end

        it 'the ENV one takes precedence' do
          expect(BetterEnv[:VARIABLE]).to eq false
        end
      end
    end

    context 'when variable is missing in ENV' do
      let(:environment) { {} }
      let(:env_files) do
        [{ 'file' => ['VARIABLE=true'] }]
      end

      it 'returns the value from .env' do
        expect(BetterEnv[:VARIABLE]).to eq true
      end
    end

    context 'when variable is missing in .env' do
      let(:environment) { { VARIABLE: 'true' } }
      let(:env_files) do
        [{ 'file' => [] }]
      end

      it 'returns the value from ENV' do
        expect(BetterEnv[:VARIABLE]).to eq true
      end
    end

    context 'when variable is missing in .env and ENV' do
      let(:environment) { {} }
      let(:env_files) do
        [{ 'file' => [] }]
      end

      context 'and there is a default set' do
        let(:options) do
          { 'VARIABLE' => { 'type' => 'boolean', 'default' => 'true' } }
        end

        it 'returns the default value' do
          expect(BetterEnv[:VARIABLE]).to eq true
        end
      end

      context 'and there is no default set' do
        it 'returns nil' do
          expect(BetterEnv[:VARIABLE]).to eq nil
        end
      end
    end
  end

  context 'when variable has default value configured' do
    let(:options) do
      { 'VARIABLE_WITH_DEFAULT' => { 'default' => 'one' } }
    end

    context 'when value is empty' do
      let(:env_files) do
        [{ 'file' => ['VARIABLE_WITH_DEFAULT='] }]
      end

      it 'sets to default value' do
        expect(BetterEnv[:VARIABLE_WITH_DEFAULT]).to eq 'one'
      end
    end

    context 'when it is defined as required' do
      let(:options) do
        { 'REQUIRED_WITH_DEFAULT' => { 'default' => 'one', 'required' => true } }
      end

      it 'raises exception for missing configuration', skip_before: true do
        add_file_stubs
        expect { load_subject }.to raise_error(/REQUIRED_WITH_DEFAULT/)
      end
    end

    context 'when variable is missing' do
      let(:options) do
        { 'DEFAULT' => { 'default' => 'one' } }
      end

      it 'fallbacks to default value' do
        expect(BetterEnv[:DEFAULT]).to eq 'one'
      end
    end

    context 'when type is boolean' do
      let(:options) do
        { 'DEFAULT_BOOL' => { 'default' => true, 'type' => 'boolean' } }
      end

      it 'sets value correctly from the default' do
        expect(BetterEnv[:DEFAULT_BOOL]).to eq true
      end
    end

    context 'when type is minutes' do
      let(:options) do
        { 'DEFAULT_MINUTES' => { 'default' => 2, 'type' => 'minutes' } }
      end

      it 'transforms the value to minutes' do
        expect(BetterEnv[:DEFAULT_MINUTES]).to eq 2 * 60
      end
    end
  end

  context 'when variable has cast type configured' do
    context 'when variable is missing in .env' do
      let(:options) do
        { 'MISSING_WITH_TYPE' => { 'type' => 'path' } }
      end

      it 'returns nil for its value' do
        expect(BetterEnv[:MISSING_WITH_TYPE]).to eq nil
      end
    end

    context 'when type is :boolean' do
      let(:options) do
        {
          'FALSE_DOWNCASE' => { 'type' => 'boolean' },
          'FALSE_UPCASE' => { 'type' => 'boolean' },
          'FALSE_CAPITALIZED' => { 'type' => 'boolean' },
          'TRUE_DOWNCASE' => { 'type' => 'boolean' },
          'TRUE_UPCASE' => { 'type' => 'boolean' },
          'TRUE_CAPITALIZED' => { 'type' => 'boolean' }
        }
      end
      let(:env_files) do
        [{
          'file' => ['FALSE_DOWNCASE=false',
                     'FALSE_UPCASE=FALSE',
                     'FALSE_CAPITALIZED=False',
                     'TRUE_DOWNCASE=true',
                     'TRUE_UPCASE=TRUE',
                     'TRUE_CAPITALIZED=True']
        }]
      end

      it 'returns a ruby boolean type' do
        expect(BetterEnv[:FALSE_DOWNCASE]).to eq false
        expect(BetterEnv[:FALSE_UPCASE]).to eq false
        expect(BetterEnv[:FALSE_CAPITALIZED]).to eq false
        expect(BetterEnv[:TRUE_DOWNCASE]).to eq true
        expect(BetterEnv[:TRUE_UPCASE]).to eq true
        expect(BetterEnv[:TRUE_CAPITALIZED]).to eq true
      end
    end

    context 'when type is :integer' do
      let(:options) do
        { 'INTEGER' => { 'type' => 'integer' } }
      end
      let(:env_files) do
        [{ 'file' => ['INTEGER=1'] }]
      end

      it 'returns a ruby integer type' do
        expect(BetterEnv[:INTEGER]).to be_an(Integer)
      end
    end

    context 'when type is :minutes' do
      let(:options) do
        { 'TIME' => { 'type' => 'minutes' } }
      end
      let(:env_files) do
        [{ 'file' => ['TIME=10'] }]
      end

      it 'returns a ruby time object' do
        expect(BetterEnv[:TIME]).to be_an(Integer)
        expect(BetterEnv[:TIME]).to eq 10 * 60
      end
    end

    context 'when type is :path' do
      let(:options) do
        { 'SOME_PATH' => { 'type' => 'path' } }
      end
      let(:env_files) do
        [{ 'file' => ['SOME_PATH=/some/path/to/here/'] }]
      end

      it 'strips leading and trailing slashes' do
        expect(BetterEnv[:SOME_PATH]).to eq 'some/path/to/here'
      end
    end

    context 'when type is :url' do
      let(:options) do
        { 'URL' => { 'type' => 'url' } }
      end
      let(:env_files) do
        [{ 'file' => ['URL=https://some-website.co.uk/to/here/'] }]
      end

      it 'strips trailing slash' do
        expect(BetterEnv[:URL]).to eq 'https://some-website.co.uk/to/here'
      end
    end

    context 'when type is :symbol' do
      let(:options) do
        { 'CAPYBARA_JAVASCRIPT_DRIVER' => { 'type' => 'symbol' } }
      end
      let(:env_files) do
        [{ 'file' => ['CAPYBARA_JAVASCRIPT_DRIVER=poltergeist'] }]
      end

      it 'casts the string to a symbol' do
        expect(BetterEnv[:CAPYBARA_JAVASCRIPT_DRIVER]).to eq :poltergeist
      end
    end

    context 'when no type is defined' do
      let(:options) do
        { 'WHATEVER' => { 'required' => true } }
      end
      let(:env_files) do
        [{ 'file' => ['WHATEVER=string'] }]
      end

      it 'returns string by default' do
        expect(BetterEnv[:WHATEVER]).to be_a String
      end
    end
  end

  context 'when variable is configured as required' do
    let(:options) do
      { 'REQUIRED' => { 'required' => true } }
    end

    it 'raises exception for missing configuration', skip_before: true do
      add_file_stubs
      expect { load_subject }.to raise_error(/REQUIRED/)
    end
  end

  describe 'support for comments' do
    let(:options) do
      { 'VAR' => { 'type' => 'string' } }
    end

    context 'when lines contain only the comment symbol (#)' do
      let(:env_files) do
        [{ 'file' => ['#', '  #', 'VAR=value'] }]
      end

      it 'parses the file ingoring the commented lines' do
        expect(BetterEnv[:VAR]).to eq('value')
      end
    end

    context 'when lines contain comment symbol (#) in the middle' do
      let(:env_files) do
        [{ 'file' => ['VAR=value  #  some comment'] }]
      end

      it 'parses the file ingoring the comments' do
        expect(BetterEnv[:VAR]).to eq('value')
      end
    end

    context 'when lines end with comment symbol (#)' do
      let(:env_files) do
        [{ 'file' => ['VAR=value #'] }]
      end

      it 'parses the file ingoring the comments' do
        expect(BetterEnv[:VAR]).to eq('value')
      end
    end
  end
end
