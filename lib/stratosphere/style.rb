module Stratosphere
  class Style
    attr_accessor :file_name, :name, :format, :dimensions, :suffix

    def initialize(options={})
      self.name       = options[:name]
      self.format     = options[:format]
      self.dimensions = options[:dimensions]
      self.suffix     = options[:suffix]
      self.file_name  = options[:file_name]

      adjust_name if format || suffix
    end

    def adjust_name
      if format
        self.file_name = "#{file_name.gsub("#{File.extname(file_name)}", "")}#{suffix}.#{format.to_s}"
      else
        self.file_name = "#{file_name.gsub("#{File.extname(file_name)}", "")}#{suffix}.#{File.extname(file_name)}"
      end
    end
  end
end