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

###### 在为model文件添加下列格式
  
Mongomapper, Mongoid

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

model 配置介绍

```
uploder 设置uploader名称， :db 后台生成数据key

uploader_size #设置文件裁切大小及文件名, 裁切格式参考

uploader_dir #设置上传目录， 未指定，默认为uploader设置的name为目录名

uploader_mimetype_white #设置上传白名单

uploader_name_format #对上传文件进行重命名， 
```


ActiveRecord

先生成 model文件

	$ rails g model image

并修改migration文件, 为下列格式

```

class CreateImages < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :file_name
      t.string :content_type
      t.integer :file_size
      t.string :storage
      t.datetime :created_at
      t.timestamps
    end
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
  upyun_is_image: true # true: 又拍云为图片空间Balloon将只上传原图， false: 又拍云为普通空间， 将会上传所有图片
```




 