# Stratosphere

### Lightning fast, easy-to-use, magic attachment handling for Ruby on Rails Applications

In today's day and age we have Dropbox, Google Drive, iCloud, etc. Shouldn't file uploading and attachment handling be easier and alot faster in Ruby on Rails Applications?
Stratosphere makes it easy to **upload directly to cloud storage providers at lightning fast speeds** while maintaining that "magic" Ruby on Rails **convention-over-configuration** we all know and love.

Currently only supporting AWS S3.

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
sudo apt-get install -y imagemagick libmagickwand-dev
```

If your using **Amazon Linux**, **CentOS**, **Red Hat**, or other **RPM** based Linux distros you can install ImageMagick with:

```bash
sudo yum install -y ImageMagick ImageMagick-devel
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

You will be asked your S3 Bucket name in order for Stratosphere to generate an appropriate initializer.

After running the `rails g stratosphere:install` command make sure you include `stratosphere.bundled.min` in the asset pipeline AFTER jquery.

```javascript
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require stratosphere.bundled.min
//= require_tree .
```

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

##### Configuration

By default, Stratosphere will create an initializer with the following code after running the `rails g stratosphere:install` command:

```ruby
Stratosphere.configure do |config|
  config.cloud      = :aws
  config.domain     = 'http://s3.amazonaws.com/<your-s3-bucket-name>'
  config.aws        = {
      access_key: ENV['AWS_ACCESS_KEY_ID'],
      secret: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION'],
      s3_bucket: '<your-s3-bucket-name>'
  }
end
```

You can also add specification configuration per each Stratosphere model like so:

```ruby
class Post < ActiveRecord::Base
  # configuration options here will be merged with the global config
  # from the Stratosphere initalizer.
  has_attachment :image, type: :image, config: {
    aws: {
      s3_bucket: 'a-different-bucket-name'
    }
  }
end
```

To add a directory prefix to provide Stratosphere a better, global insight to where your attachments will be stored in your S3 bucket you can add `config.dir_prefix = 'path/to/attachments'` to the `Stratosphere.configure` block above. Also if you are using Cloudfront to serve assets in you S3 bucket you can change the `config.domain` option to your CloudFront domain name or CNAME.

##### Attachment URLs

To get a URL for your attachment simply execute:

```ruby
@document = Document.find(1)
@document.attachment.url
```

Or for image and video attachments that have additional styles, pass the style that you wish to retrieve a url for as a symbol to the attachment's url method:

```ruby
@post = Post.find(1)
@post.image.url(:thumb)
```

If you do not pass a style to the url method and your attachment has multiple styles, it will default to original.

### Images & Videos

For image/video attachments, you can set the `:type` option in your Model's `has_attachment` method:

```ruby
class Post < ActiveRecord::Base
  has_attachment :image, type: :image
end
```

```ruby
class MusicVideo < ActiveRecord::Base
  has_attachment :video, type: :video
end
```

This provides addition features such as a `:default` option, the ability to add additional styles, a `crop` method for images, and an `encode` method for videos.

##### Setting a Default Image/Video

Set a default image by passing a string with the path to the default image from root of your S3 bucket to the `:default` option in your Model's `has_attachment` method:

```ruby
class Post < ActiveRecord::Base
  has_attachment :image, type: :image, default: 'path/to/default.jpg'
end
```

##### Styles

Adding additional styles to your image attachment is as easy as passing an array of hashes with the name of the style and the dimensions of that style in an array ([width, height]):

```ruby
class Post < ActiveRecord::Base
  has_attachment :image, type: :image, styles: [ { name: :thumb, dimensions: [64, 64] }, { name: :medium, dimensions: [300, 300] } ]
end
```

##### Image Cropping

To crop your image attachment first make sure that you have at least one style set in your Model's `has_attachment` method. Cropping can be done simply making a PATCH request with the following parameters to the relative controller's `update` method:

```javascript
{
  crop_params: [x, y, width, height]
}
```

You can also manually crop your attachment by executing the following code:

```ruby
@post = Post.find(1)
@post.crop(0, 0, 300, 500)
```

##### Video Encoding

To enable AWS ElasticTranscoder video encoding, add the following `:transcoder` option to the `config.aws` hash in `config/initializers/stratosphere.rb`:

```ruby
Stratosphere.configure do |config|
  config.aws = {
    transcoder: {
      pipeline: '<pipeline-id>',
      formats: { mp4: '<preset-id>', webm: '<preset-id>' }
    }
  }
end
```

Video attachments with multiple styles containing different `:format` options will call encode automatically after your Model's attachment has changed.

You can also manually call the encode method by executing the following code:

```ruby
@music_video = MusicVideo.find(1)
@music_video.encode
```

By default if video encoding is enabled, a :thumb style will be automatically generated. To access the :thumb style simply add the following configuration to your Model's `has_attachment` method:

```ruby
class MusicVideo < ActiveRecord::Base
  has_attachment :video, type: :video, styles: [ { name: :thumb, format: :jpg, suffix: '-00001' } ]
end
```

## Example

<a href="http://stratosphere.zacharygolba.com" target="_blank">Check out a live production RoR App with different attachment demonstrations.</a>

The source code for the example app is <a href="https://github.com/zacharygolba/stratosphere-demo" target="_blank">available here</a>.

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
