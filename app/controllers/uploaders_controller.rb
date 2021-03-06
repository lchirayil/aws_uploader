class UploadersController < ApplicationController
  before_action :load_aws
  before_action :check_db, only: [:search, :index, :month]
  helper_method :signer

  def search
    search_attribute = params[:search]
    if search_attribute
      @bucket_search = Bucket.order(last_moddy: :desc).kinda_spelled_like(params[:search])
    end
  end

  def index
    @objects = @bucket.objects(prefix: "sgcimages/")
    @years = resp_year_to_array
    @bucket_search = Bucket.order(last_moddy: :desc).limit(10)
  end

  def year
    @months = resp_month_to_array.sort
  end

  def month
    @objects = Bucket.where("url like ?", "%sgcimages/#{params[:year]}/#{params[:month]}%").order(last_moddy: :desc)
  end

  def file_name(name)
    array = name.split('/')
    array[3]
  end

  private

  def check_db
    @resp.contents.each do |item|
      @bucket_check = Bucket.where(key: item.key)
      if @bucket_check == []
        Bucket.create(
          url: "https://s3.us-east-2.amazonaws.com/sgc-test-bucket/#{item.key}",
          filename: file_name(item.key),
          key: item.key,
          last_mod: item.last_modified.strftime('%m-%e-%y %H:%M'),
          last_moddy: item.last_modified
        )
      end
      if @bucket_check != []
        if @bucket_check.first.last_moddy != item.last_modified
          @bucket_check.first.destroy
            Bucket.create(
              url: "https://s3.us-east-2.amazonaws.com/sgc-test-bucket/#{item.key}",
              filename: file_name(item.key),
              key: item.key,
              last_mod: item.last_modified.strftime('%m-%e-%y %H:%M'),
              last_moddy: item.last_modified
            )
        end
      end
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
