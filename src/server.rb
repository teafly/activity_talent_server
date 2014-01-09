#!/usr/bin/env ruby

require 'sinatra'
require 'mongoid'
require 'mongoid_fulltext'
require 'json_bean/mongoid'

Mongoid.load!("../conf/mongoid.yml", :production)

class Activity
	include Mongoid::Document
	include Mongoid::FullTextSearch
	include JsonBean::Mongoid

	store_in collection: "activity", database: "activity_talent", session: "default"

	field :createTime,		type: String
	field :modifiedTime,	type: String
	field :title,					type: String
	field :address,				type: String
	field :time,					type: String
	field :detail,				type: String

	fulltext_search_in :title, :address, :detail
	bean_alias _id: "id"
end

get '/activities' do

	at = Activity.only(:title).all()
	at.to_json_bean
end

get '/activity/:id' do |id|

	Activity.find(id).to_json_bean
end

get '/activities/:keyword' do |keyword|

	Activity.update_ngram_index
	Activity.fulltext_search(keyword).to_json_bean
end

post '/add-activity' do

	request.body.rewind  # in case someone already read it
	data = JSON.parse request.body.read
	ac = Activity.new(data)
	ac.createTime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	ac.modifiedTime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	ac.save!
end
