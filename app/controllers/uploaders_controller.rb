class UploadersController < ApplicationController
  require 'aws-sdk'
  def index
    s3 = Aws::S3::Resource.new
    @post = s3.bucket(ENV['S3_BUCKET']).presigned_post(
      key: "uploads/#{Time.now.to_i}/${filename}",
      allow_any: ['utf8', 'authenticity_token'],
      acl: "authenticated-read",
    )
  end
end
