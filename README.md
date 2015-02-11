# Stratosphere

### Lightning fast, easy-to-use, magic attachment handling for Ruby on Rails Applications

In today's day and age we have Dropbox, Google Drive, iCloud, etc. Shouldn't file uploading and attachment handling be easier and alot faster in Ruby on Rails Applications?
Stratosphere makes it easy to **upload directly to cloud storage providers at lightning fast speeds** while maintaining that "magic" Ruby on Rails **convention-over-configuration** we all know and love.

Currently only supporting AWS S3.

## Requirements

### Ruby/Rails

Stratosphere requires **Ruby >= 2.0** and **Rails >= 4.0**.

### ImageMagick

ImageMagick and it's relevant development libraries are required for Stratosphere to provide image proccessing.

If your using **Mac OSX** and **homebrew** you can install ImageMagick with:

```bash
brew install imagemagick
```

If your using **Ubuntu** or other **Debian** based Linux distros you can install ImageMagick with:

```bash
sudo apt-get install -y ImageMagick libmagickwand-dev
```

If your using **Amazon Linux**, **CentOS**, **Red Hat**, or other **RPM** based Linux distros you can install ImageMagick with:

```bash
sudo yum install -y ImageMagick ImageMagick-devel
```

## Prerequisites

### AWS Setup

Make sure your AWS User has access to your S3 bucket and has the permissions necessary to **list**, **upload**, and **delete**.

![AWS S3 Config](http://cdn.zacharygolba.com/stratosphere/docs/img/s3-configuration.jpg)

In order for Stratoshpere to properly load your AWS configuration in your ~/.bash_profile or ~/.bashrc:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_REGION="s3-bucket-region"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stratosphere'
```

From the root of your rails app execute:

```bash
bundle
```

And then:

```bash
rails g stratosphere:install
```

You will be asked your S3 Bucket **name** in order for Stratosphere to generate an appropriate initializer.

After running the `rails g stratosphere:install` command make sure you include **stratosphere.bundled.min** in the asset pipeline AFTER jquery.

## Usage

### General

To generate an attachment on one of your models execute the following from the root of your rails application:

```bash
rails g stratosphere:attachment <model> <attachment_name>
```

Executing the command above with **document** in place of model and **attachment** in place of attachment_name would generate the following migration:

```ruby
class AddAttachmentToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :attachment_file, :string
    add_column :documents, :attachment_content_type, :string
    add_column :documents, :attachment_content_length, :int8
  end
end
```

Now just add your attachment configuration to your Model with the has_attachment method:

```ruby
class Document < ActiveRecord::Base
  has_attachment :attachment
end
```

And in any the view:

```erb
<%= render partial: 'stratosphere/attachment_field', locals: { model: @post } %>
```

:cloud: Thats it! No additional routes. No methods or strong parameters to add to your controllers. Just kick ass, highly scalable, lightning fast, AJAX file uploads!

### Images

For image attachments, you can set the `:type` option in your Model's `has_attachment` method:

```ruby
class Post < ActiveRecord::Base
  has_attachment :image, type: :image
end
```

This provides addition features such as a `crop` method, a "default" option, the ability to add additional styles.

##### Setting a Default Image

Set a default image by passing a string with the path to the default image from root of your S3 bucket to the `:default` option in your Model's `has_attachment` method:

```ruby
class Post < ActiveRecord::Base
  has_attachment :image, type: :image, default: 'path/to/default.jpg'
end
```

#### Styles

Adding additional styles to your image attachment is as easy as passing an array of hashes with the name of the style and the dimensions of that style in an array ([width, height]):

```ruby
class Post < ActiveRecord::Base
  has_attachment :image, type: :image, styles: [ { name: :thumb, dimensions: [64, 64] }, { name: :medium, dimensions: [300, 300] } ]
end
```

#### Cropping

Coming Soon!

#### Videos

Coming Soon!

## Example

Coming Soon!

## To Do
  
- [ ] Better tests
- [ ] Multiple attachment support per each ActiveRecord Model
- [ ] Add additional cloud service providers (Google Cloud Storage, Azure Storage Box, Zencoder Video Encoding)

## Contributing

1. Fork it ( https://github.com/zacharygolba/stratosphere/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request