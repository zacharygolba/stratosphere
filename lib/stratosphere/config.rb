module Stratosphere
  class Config
    attr_accessor :aws, :cloud, :domain, :dir_prefix

    def initialize(options={})
      @aws        = options[:aws]
      @cloud      = options[:cloud]
      @domain     = options[:domain]
      @dir_prefix = options[:dir_prefix]
    end

    def to_hash
      hash = {}
      self.instance_variables.each do |attr|
        hash[attr.to_s.delete('@').to_sym] = self.instance_variable_get(attr)
      end
      hash
    end
  end
end
