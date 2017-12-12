class UploadersController < ApplicationController
  require 'aws-sdk'
  def create
    # Make an object in your bucket for your upload
    obj = Aws::S3::Resource.new.bucket([ENV['S3_BUCKET']]).objects[params[:file].original_filename]

    # Upload the file
    obj.write(
      file: params[:file],
      acl: :public_read
    )

    # Create an object for the upload
    @upload = Upload.new(
    	url: obj.public_url,
		  name: obj.key
    	)

    if @upload.save
      redirect_to '/'
    else

      flash.now[:notice] = 'There was an error'
      redirect_to '/failed'
    end
  end
  def show

  end
end
