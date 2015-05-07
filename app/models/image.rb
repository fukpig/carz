class Image < ActiveRecord::Base
	mount_uploader :image_file_name, CarUploader
end
