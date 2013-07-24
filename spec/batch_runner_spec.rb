require 'spec_helper'
require_relative '../lib/utils.rb'
require_relative '../lib/rmagick-blend.rb'

describe "Batch Runner" do

    describe "large_previous_batch?" do

        it "returns true with empty input" do
            RMagickBlend::BatchRunner::stub(:gets).and_return('')
            RMagickBlend::BatchRunner::large_previous_batch?.should be_true
        end

        it "returns true with a 'y' as input" do
            RMagickBlend::BatchRunner::stub(:gets).and_return('y')
            RMagickBlend::BatchRunner::large_previous_batch?.should be_true
        end

        it "returns true with a 'yes' as input" do
            RMagickBlend::BatchRunner::stub(:gets).and_return('yes')
            RMagickBlend::BatchRunner::large_previous_batch?.should be_true
        end

        it "returns false otherwise" do
            RMagickBlend::BatchRunner::stub(:gets).and_return('n')
            RMagickBlend::BatchRunner::large_previous_batch?.should be_false

            RMagickBlend::BatchRunner::stub(:gets).and_return('no')
            RMagickBlend::BatchRunner::large_previous_batch?.should be_false

            RMagickBlend::BatchRunner::stub(:gets).and_return('noyes')
            RMagickBlend::BatchRunner::large_previous_batch?.should be_false
        end

    end

    describe 'delete_last_batch' do
        
        it 'returns nil if no files found' do
            Settings = double("directories", directories: { output_dir: '.' } )
            RMagickBlend::BatchRunner.delete_last_batch.should be_nil
        end
        
        it 'returns an integer if files are found and then deleted' do
            dir = "#{Dir.getwd}/spec/assets/source"
            Settings = double("directories", directories: { output_dir: dir } )
            create_temp_file('source')
            RMagickBlend::BatchRunner.delete_last_batch.should be_a_kind_of(Fixnum)
            clean_assets_directory('source')
        end
        
    end

end