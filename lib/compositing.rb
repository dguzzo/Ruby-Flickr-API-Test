require 'pry'
require 'pry-nav'

module RMagickBlend

    module Compositing

        OPTIMIZED_NUM_OPERATION_SMALL = 14
        
        def self.composite_images(options={})
            defaults = {
                num_operations: OPTIMIZED_NUM_OPERATION_SMALL, 
                append_operation_to_filename: false, 
                shuffle_composite_operations: false,
                directories: { output: 'images/image-composites' },
                input_file_format: 'jpg',
                output_file_format: 'jpg',
                save_history: true,
                use_history: false,
                switch_src_dest: false
            }

            options = defaults.merge(options)
            options[:num_operations] = $flags[:num_operations].to_i if $flags[:num_operations]
            options[:switch_src_dest] = $flags[:switch_src_dest] if $flags[:switch_src_dest]

            if options[:use_history]
                src, dst = RMagickBlend::FileUtils::get_image_pair_from_history(options)
            else
                src, dst = options[:directories] ? RMagickBlend::FileUtils::get_image_magick_pair(options[:directories], $input_file_format) : RMagickBlend::FileUtils::get_image_pair_via_image_pool($input_file_format, 'images')
            end

            src, dst = RMagickBlend::FileUtils::swap_directories(src, dst) if options[:switch_src_dest]

            compositeArray = options[:shuffle_composite_operations] ? Magick::CompositeOperator.values.dup.shuffle : Magick::CompositeOperator.values.dup
            compositeArray.delete_if { |op| $COMP_SETS[:avoid].include?(op.to_s) }

            if $specific_comps_to_run
                range = 0...compositeArray.length
                options[:num_operations] = $specific_comps_to_run.length
            else
                # first two CompositeOperator are basically no-ops, so skip 'em. also, don't go out of bounds with the index
                range = 2...[options[:num_operations] + 2, Magick::CompositeOperator.values.length].min
            end

            puts "\nbeginning composites processing, using #{Utils::ColorPrint::green(options[:num_operations])} different operations"
            output_dir = RMagickBlend::FileUtils::createDirIfNeeded(options[:directories][:output])

            compositeArray[range].each_with_index do |composite_style, index|
                next if $specific_comps_to_run && !$specific_comps_to_run.include?(composite_style.to_s)

                print "#{(index.to_f/options[:num_operations]*100).round}% - " unless $specific_comps_to_run
                print "#{Utils::ColorPrint::green(composite_style.to_s)}\n"
                append_string = options[:append_operation_to_filename] ? composite_style.to_s : index
                start_time = Time.now
                result = dst.composite(src, 0, 0, composite_style)
                end_time = Time.now
                puts "PERF PROFILING .composite(): #{Utils::ColorPrint::yellow(end_time-start_time)} seconds." if $flags[:perf_profile]

                start_time = Time.now
                result.write("./#{output_dir}/#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{RMagickBlend::FileUtils::pretty_file_name(dst)}--#{append_string}.#{options[:output_file_format]}")
                end_time = Time.now
                puts "PERF PROFILING .write(): #{Utils::ColorPrint::yellow(end_time-start_time)} seconds." if $flags[:perf_profile]
            end

            RMagickBlend::FileUtils::save_history(src: src, dst: dst, options: options) if options[:save_history]
            $batches_ran += 1
            puts Utils::ColorPrint::green("\ndone!")
        end
        
    end
    
end