class ApplicationController < ActionController::Base

	def get_pub_med_data(options = { url_ids: "", url_abstracts: "" } )

		data = HTTParty.get(options[:url_ids])
		list = data["esearchresult"]["idlist"]

		first = list[0]
		second = list[1]
		third = list[2]

		first_json = HTTParty.get(options[:url_abstracts]+first)
		second_json = HTTParty.get(options[:url_abstracts]+second)
		third_json = HTTParty.get(options[:url_abstracts]+third)

		first_abstract = first_json.parsed_response
		second_abstract = second_json.parsed_response
		third_abstract = third_json.parsed_response

		first_abs_list = first_abstract.split("\n\n")
		second_abs_list = second_abstract.split("\n\n")
		third_abs_list = third_abstract.split("\n\n")

		first_abs_title = first_abs_list[1]
		first_full_abstract = first_abs_list.max_by(&:length)
		second_abs_title = second_abs_list[1]
		second_full_abstract = second_abs_list.max_by(&:length)
		third_abs_title = third_abs_list[1]
		third_full_abstract = third_abs_list.max_by(&:length)

		dictionary_of_data = {}

		dictionary_of_data[first_abs_title] = first_full_abstract
		dictionary_of_data[second_abs_title] = second_full_abstract
		dictionary_of_data[third_abs_title] = third_full_abstract

		return dictionary_of_data
	end

	def get_twitter_data()

		#gem install twitter
		#require 'Twitter'
        client = Twitter::REST::Client.new do |config|
		  config.consumer_key = "d0rI0KFko5SQzSpF4maX11gYF"
		  config.consumer_secret = "2rtIqOoiBOWIp8WHhFkUYu9tNsXqJe4dT0Y3h4TYcnWMpIGack"
		  config.access_token = "31041225-CMdgCtoUtP9AjqGiOa9VYf0WkliKzBiXyZ8jLvJwe"
		  config.access_token_secret = "8HElIlqp1VEP7Cv6rkV4x2g1m5mfRnKh0xIvtYPS8dtfO"
		end

		#gem  'sentimental'
		#require 'sentimental'
		analyzer = Sentimental.new
		analyzer.load_defaults
		analyzer.threshold = 0.1

		dictionary_of_tweets = {}
		client.search("#influenza",result_type: "recent").take(30).each do |tweet|
			dictionary_of_tweets[tweet.text] = analyzer.sentiment tweet.text
		end

		list_of_values = []
		dictionary_of_tweets.keys.each do |v|
			list_of_values.push(dictionary_of_tweets[v])

		final_counts = list_of_values.group_by(&:itself).transform_values(&:count)

	#proportion of positive,negative,neutral tweets
		total_count = final_counts.values.sum.to_f
		positive_count_proportion = ((final_counts[:positive]).to_f / total_count)*100
		negative_count_proportion = ((final_counts[:negative]).to_f / total_count)*100
		neutral_count_proportion = ((final_counts[:neutral]).to_f / total_count)*100


	#now store the total count and proportions
	#then recalculate them the next day
	#and then return a change calculation ((new / old) - 1)


		change_dictionary = {}
		change_dictionary['yesterday_total'] = 2
		change_dictionary['yesterday_positive'] = 3
		change_dictionary['yesterday_negative'] = 8
		change_dictionary['yesterday_neutral'] = 12
		change_dictionary['total_count'] = total_count
		change_dictionary['positive_count_proportion'] = positive_count_proportion
		change_dictionary['negative_count_proportion'] = negative_count_proportion
		change_dictionary['neutral_count_proportion'] = neutral_count_proportion

		change_in_total_count = (change_dictionary['yesterday_total'].to_f - change_dictionary['total_count'].to_f) * 100
		change_in_positive_proportion = (change_dictionary['yesterday_positive'].to_f - change_dictionary['positive_count_proportion'].to_f) * 100
		change_in_negative_proportion = (change_dictionary['yesterday_negative'].to_f - change_dictionary['negative_count_proportion'].to_f) * 100
		change_in_neutral_proportion = (change_dictionary['yesterday_neutral'].to_f - change_dictionary['neutral_count_proportion'].to_f) * 100
		
		return change_dictionary

		end
	end

	def get_vaccine_data()
		#find new vaccines for diseases
		#list its side effects
		#list its ingredients

		
	end

end
