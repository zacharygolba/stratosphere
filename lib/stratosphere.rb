require 'aws-sdk'
require 'open-uri'
require 'rmagick'
require 'stratosphere/aws'
require 'stratosphere/attachment'
require 'stratosphere/config'
require 'stratosphere/engine'
require 'stratosphere/has_attachment'
require 'stratosphere/style'

module Stratosphere
  class << self
    attr_writer :config
  end

  def self.config
    @configuration ||= Stratosphere::Config.new
  end

  def self.configure
    yield config
  end
end