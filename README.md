# Balloon 


Balloon是基于Ruby的图片上传插件， 并且可以完美配合Rails使用。


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

```
require 'balloon'

Balloon.configure do |config|
  config.store_storage = :file
end

class Upload < Balloon::Base
  uploader :avatar
  uploader_size t: "100x100"
  uploader_name_format 
end

file = File.new("file.jpg")

upload = Upload.new("file")

upload.upload_store #上传图片

upload.from_store(:t) #获得图片Path

```

## 在Rails中使用


在Rails应用程序中运行下述命令来完成Balloon插件的初始化

	$ rails g balloon:config
	
在运行命令后， 会在config目录中生成一个balloon.yml配置文件

###### 默认balloon.yml配置格式

````
defaults: &defaults
  store_storage: 'file' # 默认为文件储存， file: 文件储存， upyun: 又拍云存储
  asset_host : '' # asset 文件
  root: '' # 储存目录
  permissions: 0777 # 生成文件目录权限
  store_dir: "public" # 默认生成文件储存位置
  tmp_dir: "tmp" # 临时文件储存位置
  url_get_db_storage: true
  
development:
  <<: *defaults

test:
  <<: *defaults

production:
  <<: *defaults
````


###### 在为model文件添加下列格式
  
Mongomapper, Mongoid

```
  class Image 
    include MongoMapper::Document
    include Balloon::Up
    
    uploader :image, :db 
    uploader_size t: "45", s: "450", m: "770", l: "920>" # 图片上传操作
    uploader_dir "uploads/product" # 图片在"public"目录下指定位置
    uploader_mimetype_white %w{image/jpeg image/png image/gif} #允许上传图片格式
    uploader_name_format name: Proc.new{|p| p.id.to_s } #对上传文件重命名
  end 
```

ActiveRecord

先生成 model文件

	$ rails g model image

并修改migration文件, 为下列格式

```

class CreateImages < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.column :file_name, :string
      t.column :content_type, :string
      t.column :file_size, :integer
      t.column :storage, :string
      t.column :created_at, :datetime
      t.timestamps
    end
  end

  def down
    drop_table :pictures
  end
end

```

在 model 文件

```
class Image < ActiveRecord::Base
  include Balloon::Up
    
  uploader :image
end

```

###### rails实现图片上传

直接试用model原生操作， 用uploader设置的参数作为上传参数
  
 	@image = Images.new(image: file)
 	@image.save

###### 又拍云支持

将store_storage 修改为 ‘upyun’, 在config/balloon.yml内添加下列内容

```
  upyun_domain: ""
  upyun_bucket: "" 
  upyun_username: ""
  upyun_password: ""
  upyun_timeout: 600
  upyun_is_image: true # true: 又怕云为图片空间Balloon将只上传原图， false: 又拍云为普通空间， 将会上传所有图片
```




 