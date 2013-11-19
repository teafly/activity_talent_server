#!/usr/bin/env ruby

require 'sinatra'
require 'mongoid'
require 'mongoid_fulltext'

Mongoid.load!("../conf/mongoid.yml", :production)

module Serialize

	class S11nFactory

		def initialize(config = {})

			@alias = config
		end

		def serialize(datas)

			return if datas.nil?

			if datas.is_a? Array

				results = []
				datas.each do |data|
					res = _serialize data
					results.push res
				end
				results.to_json
			else
				_serialize(datas).to_json
			end
		end


		private
		def _serialize(data)

			res = {}
			data = JSON.parse(data.to_json)[data.class.to_s.downcase]

			data.each do |key, val|

				if @alias.include? key.to_sym

					res[@alias[key.to_sym]] = val
				elsif ! val.nil?

					res[key] = val
				end
			end
			res
		end
	end

	def self.create(config = {})

		S11nFactory.new config
	end

end

s11n = Serialize.create({:_id => "id"})

class Activity
	include Mongoid::Document
	include Mongoid::FullTextSearch

	store_in collection: "activity", database: "activity_talent", session: "default"

	field :createTime,		type: String
	field :modifiedTime,	type: String
	field :title,					type: String
	field :address,				type: String
	field :time,					type: String
	field :detail,				type: String

	fulltext_search_in :title, :address, :detail
end

get '/activities' do

	at = Activity.only(:title).all()
	s11n.serialize at
end

get '/activity/:id' do |id|

	at = Activity.find(id)
	s11n.serialize at
end

get '/activities/:keyword' do |keyword|

	#Activity.update_ngram_index
	at = Activity.fulltext_search(keyword)
	s11n.serialize at
end

post '/add-activity' do

	request.body.rewind  # in case someone already read it
	data = JSON.parse request.body.read
	ac = Activity.new(data)
	ac.createTime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	ac.modifiedTime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	ac.save!
end

get '/test' do

	ac = Activity.new
	ac.address = 'hello'
	ac.save
end
