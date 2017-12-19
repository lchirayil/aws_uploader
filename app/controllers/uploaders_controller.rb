class UploadersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_aws
  before_action :populate_db, only: [:search]
  helper_method :signer

  def search
    search_attribute = params[:search]
    if search_attribute
      @bucket_search = Bucket.kinda_spelled_like(params[:search])
    end
    @count = 1
  end

  def index
    @objects = @bucket.objects(prefix: "sgcimages/")
    @years = resp_year_to_array
    @bucket_search = Bucket.order(last_moddy: :desc).limit(10)
    @count = 1
  end

  def year
    @months = resp_month_to_array
  end

  def month
    @temp_obj = @bucket.objects(prefix: "sgcimages/#{params[:year]}/#{params[:month]}")
    small_db
    @objects = Bucket.order(last_moddy: :desc)
    @count = 1
  end

  def signer(key)
    @signer.presigned_url(:get_object, bucket: ENV['S3_BUCKET'],key: key)
  end

  def file_name(name)
    array = name.split('/')
    array[3]
  end

  private

  def small_db
    Bucket.destroy_all
    @temp_obj.each do |item|
      Bucket.create(
        url: "https://s3.us-east-2.amazonaws.com/#{item.key}",
        filename: file_name(item.key),
        key: item.key,
        last_mod: item.last_modified.strftime('%m-%e-%y %H:%M'),
        last_moddy: item.last_modified
      )
    end
  end

  def populate_db
    Bucket.destroy_all
    @resp.contents.each do |item|
      Bucket.create(
        url: "https://s3.us-east-2.amazonaws.com/#{item.key}",
        filename: file_name(item.key),
        key: item.key,
        last_mod: item.last_modified.strftime('%m-%e-%y %H:%M'),
        last_moddy: item.last_modified
      )
    end
  end

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
    @bucket_name = ENV['S3_BUCKET']
    @signer = Aws::S3::Presigner.new

    @s3 = Aws::S3::Client.new
    @resp = @s3.list_objects(bucket: ENV['S3_BUCKET'])

    s3 = Aws::S3::Resource.new
    @post = s3.bucket(ENV['S3_BUCKET']).presigned_post(
      key: "sgcimages/#{Time.current.year.to_i}/#{Time.current.month.to_i}/${filename}",
      allow_any: ['utf8', 'authenticity_token'],
      acl: "public-read",
      content_type: "",
      content_disposition: 'inline',
      metadata: {tag: ""}
    )
    @bucket = s3.bucket(ENV['S3_BUCKET'])

  end
end
