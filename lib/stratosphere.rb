require 'aws-sdk'
require 'stratosphere/aws'
require 'stratosphere/attachment'
require 'stratosphere/config'
require 'stratosphere/engine'
require 'stratosphere/has_attachment'
require 'stratosphere/image'
require 'stratosphere/style'
require 'stratosphere/upload'
require 'stratosphere/video'

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