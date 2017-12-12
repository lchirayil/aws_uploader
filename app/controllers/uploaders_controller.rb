class UploadersController < ApplicationController
  before_action :load_aws

  def year
    @objects = @bucket.objects(prefix: "sgcimages/#{params[:year]}")
  end


  private

  def load_aws
    require 'aws-sdk'
    @s3 = Aws::S3::Client.new
    @resp = @s3.list_objects(bucket: ENV['S3_BUCKET'])

    s3 = Aws::S3::Resource.new
    @post = s3.bucket(ENV['S3_BUCKET']).presigned_post(
      key: "sgcimages/#{Time.current.year.to_i}/#{Time.current.month.to_i}/${filename}",
      allow_any: ['utf8', 'authenticity_token'],
      acl: "authenticated-read",
    )
    @bucket = s3.bucket(ENV['S3_BUCKET'])
  end
end
