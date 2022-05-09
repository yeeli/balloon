# Balloon 


Balloon是基于mini_magick的Rails项目图片上传插件。



## 安装


将下列文字添加到你程序中的Gemfile里

```
  gem 'balloon'
  
  或者
  
  gem 'ballon', github: 'yeeli/balloon'
```

并执行:

    $ bundle

或者直接通过命令安装:

    $ gem install balloon



## 单独使用

Class 例子

```ruby
require 'balloon'

Balloon.configure do |config|
  config.store_storage = :file
  config.root = "output"
end

class Upload < Balloon::Base
  uploader :image
  uploader_dir 'uploads'
  uploader_mimetype_white %w[image/jpeg image/png image/gif image/webp]
  uploader_name_format name: "output", format: "upcase" # 输出文件名
  uploader_type_format 'webp' # ImageMagick支持的类型
  uploader_size thumb: "100x100", small: "200x", medium: '500x>' # https://legacy.imagemagick.org/Usage/resize/
end
```

文件上传

````ruby
file = File.new("input.jpg")
upload = Upload.new(file)

or

upload = Upload.new("input.jpg")

upload.upload_store #上传图片
upload.image #获取图片上传信息

upload.from_store(:t) #获得图片Path
````



## 在Rails中使用


在Rails应用程序中运行下述命令来完成Balloon插件的初始化

	$ rails g balloon:config

在运行命令后， 会在config目录中生成一个balloon.yml配置文件

###### 默认生成balloon.yml文件

````
defaults: &defaults
  store_storage: 'file' 
  
development:
  <<: *defaults

test:
  <<: *defaults

production:
  <<: *defaults
````

balloon.yml 配置介绍

```
store_storage:  设置 文件储存位置， file: 文件储存， upyun: 又拍云存储

asset_host : 设置 asset
  
root: 设置主目录， 默认为当前应用程序的主目录
  
permissions: 设置生成文件目录权限， 默认为0777

store_dir: 设置存储目录， 默认为主目录下的"public"目录
  
cache_dir: "tmp" # 设置临时文件储存目录， 默认为主目录下的“tmp”目录
```



model 配置介绍

```
uploder 设置uploader名称， :db 后台生成数据key

uploader_size #设置文件裁切大小及文件名, 裁切格式参考

uploader_dir #设置上传目录， 未指定，默认为uploader设置的name为目录名

uploader_mimetype_white #设置上传白名单

uploader_name_format #对上传文件进行重命名， 
```



#### ActiveRecord

先生成 model文件

	$ rails g model image

并修改migration文件, 为下列格式

```ruby

class CreateImages < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :file_id, null: false, index: true
      t.string :file_name
      t.integer :width
      t.integer :height
      t.string :content_type
      t.bigint :file_size
      t.string :storage
      
      # Postgresql 可以JSONB 作为metadata格式
      t.jsonb :metadata 
      # Mysql和其它需要使用text
      t.text :metadata
   
      t.timestamps
    end
  end
end

```

model 文件

```ruby
class Picture < ActiveRecord::Base
  include Balloon::Up
    
  uploader :image, :db
  uploader_dir 'uploads/images'
  uploader_mimetype_white %w[image/jpeg image/png image/gif image/webp]
  uploader_name_format name: proc { |img| img.file_id }
  uploader_type_format 'webp'
  uploader_size thumb: '150x', small: '450x>'
    
  before_validation :create_file_id, on: :create
  
  def create_file_id
    self.file_id = generate_file_id
  end

  def generate_file_id
    loop do
      token = SecureRandom.hex
      break token unless Picture.exists?(file_id: token)
    end
  end  
end

```



####  Mongoid

```
  class Image 
    include MongoMapper::Document
    include Balloon::Up
    
    uploader :image, :db 
    uploader_size t: "45", s: "450", m: "770"
    uploader_dir "uploads/product"
    uploader_mimetype_white %w{image/jpeg image/png image/gif}
    uploader_name_format name: Proc.new{|p| p.id.to_s }
  end 
```



#### rails 实现图片上传

直接试用model原生操作， 用uploader设置的参数作为上传参数

```ruby
@picture = Picture.new(image: params[:image])
@picture.save

@picture.url #获取原图
@picture.url(size) #获得图片地址
```



##### 又拍云支持

将store_storage 修改为 ‘upyun’, 在config/balloon.yml内添加下列内容

```yaml
  upyun_domain: ""
  upyun_bucket: "" 
  upyun_username: ""
  upyun_password: ""
  upyun_timeout: 600
  upyun_is_image: true # true: 又拍云为图片空间Balloon将只上传原图， false: 又拍云为普通空间， 将会上传所有图片
```



