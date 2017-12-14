class UploadersController < ApplicationController
  before_action :load_aws

  def index
    @objects = @bucket.objects(prefix: "sgcimages/")
    @years = resp_year_to_array

  end

  def year
    @months = resp_month_to_array
  end

  def month
    @objects = @bucket.objects(prefix: "sgcimages/#{params[:year]}/#{params[:month]}")
    @count = 1
  end

  def file_name(name)
    array = name.split('/')
    array[2]
  end

  private

  def resp_year_to_array
    url_array = []
    @resp.contents.each do |object|
      url_array << object.key
    end
    year_strip(url_array)
  end

  def resp_month_to_array
    url_array = []
    @resp.contents.each do |object|
      url_array << object.key
    end
    month_strip(url_array)
  end

  def year_strip(url_array)
    new_array = []
    years = []
    url_array.each do |url|
      new_array << url.split('/')
      new_array.each do |year|
        years << year[1]
      end
    end
    years.uniq
  end

  def month_strip(url_array)
    new_array = []
    months = []
    url_array.each do |url|
      new_array << url.split('/')
      new_array.each do |month|
        months << month[2]
      end
    end
    months.uniq
  end



  def load_aws
    require 'aws-sdk'

    @signer = Aws::S3::Presigner.new
    @url = @signer.presigned_url(:get_object, bucket: "sgc-test-bucket", key: "sgcimages/2017/12/pdf.pdf")


    @s3 = Aws::S3::Client.new
    @resp = @s3.list_objects(bucket: ENV['S3_BUCKET'])

    s3 = Aws::S3::Resource.new
    @post = s3.bucket(ENV['S3_BUCKET']).presigned_post(
      key: "sgcimages/#{Time.current.year.to_i}/#{Time.current.month.to_i}/${filename}",
      allow_any: ['utf8', 'authenticity_token'],
      acl: "public-read",
      content_type: 'image/png',
      content_disposition: 'inline'
    )
    @bucket = s3.bucket(ENV['S3_BUCKET'])
  end
end
