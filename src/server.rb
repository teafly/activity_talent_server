#!/usr/bin/env ruby

require 'sinatra'
require 'mongoid'
require 'mongoid_fulltext'

Mongoid.load!("../conf/mongoid.yml", :production)

class Activity
	include Mongoid::Document
	include Mongoid::FullTextSearch

	store_in collection: "activity", database: "activity_talent", session: "default"

	field :createTime,		type: DateTime
	field :modifiedTime,	type: DateTime
	field :title,					type: String
	field :address,				type: String
	field :time,					type: String
	field :detail,				type: String

	fulltext_search_in :title, :address, :detail
end

get '/activity/all' do

	at = Activity.only(:title).all()
	"#{at.to_json}"
end

get '/activity/:id' do |id|

	at = Activity.find(id)
	"#{at.to_json}"
end

get '/activities/:keyword' do |keyword|

	#Activity.update_ngram_index
	at = Activity.fulltext_search(keyword)
	"#{at.to_json}"
end

get '/activity/test' do

	Activity.create([
	  { createTime: Time.now, modifiedTime: Time.now, title: "apple to donow", address: "abc", time: "2013-11-11 12:00", detail: "Guangxi NanNing" },
	  { createTime: Time.now, modifiedTime: Time.now, title: "xigua to pinaow", address: "bcd", time: "2013-11-11 12:00", detail: "Guangxi Nfdasfadsfadsfg" },
	  { createTime: Time.now, modifiedTime: Time.now, title: "longqi to donow", address: "efd", time: "2013-11-11 12:00", detail: "Guangxi Shanghai" }
	])
	"hello"
end
