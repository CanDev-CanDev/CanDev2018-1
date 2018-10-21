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
		# require 'HTTParty'
		# require 'nokogiri'

		main_dictionary = {}

		page = HTTParty.get("https://clinicaltrials.gov/ct2/results?cond=vaccine+reaction+influenza")
		parsed_page ||= Nokogiri::HTML(page)
		data = parsed_page.css('//*[@id="theDataTable"]/tbody/tr[1]').text
		filter_rule = data.split("\r\n\t\t    \t\t")
		final_array = filter_rule.reject {|x| x.length < 20}

		countries = [ "Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard and McDonald Islands", "Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic of", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan", "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic Of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "Rwanda", "Saint Barthelemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"]
		relevant_words = 'Influenza'


		countries_list = []

		countries.each do |country|
			final_array.each do |val|
				if val.include?(country)
					countries_list.push(country)
				end
			end
		end

		countries_list = countries_list.uniq

		relevant_details = []

		final_array.each do |val|
			if val.include?(relevant_words)
				relevant_details.push(val)
			end
		end

		final_dictionary_data = {}
		final_dictionary_data[countries_list] = relevant_details

########################################################################################################################

		data_two = parsed_page.css('//*[@id="theDataTable"]/tbody/tr[2]').text
		filter_rule_two = data_two.split("\r\n\t\t    \t\t")
		final_array_two = filter_rule_two.reject {|x| x.length < 20}
		
		countries_list_two = []

		countries.each do |country|
			final_array_two.each do |val|
				if val.include?(country)
					countries_list_two.push(country)
				end
			end
		end

		countries_list_two = countries_list_two.uniq

		relevant_details_two = []

		final_array_two.each do |val|
			if val.include?(relevant_words)
				relevant_details_two.push(val)
			end
		end

		final_dictionary_data_two = {}
		final_dictionary_data_two[countries_list_two] = relevant_details_two

########################################################################################################################


		data_three = parsed_page.css('//*[@id="theDataTable"]/tbody/tr[3]').text
		filter_rule_three = data_three.split("\r\n\t\t    \t\t")
		final_array_three = filter_rule_three.reject {|x| x.length < 20}

	    
	    countries_list_three = []

	    countries.each do |country|
	      final_array_three.each do |val|
	        if val.include?(country)
	          countries_list_three.push(country)
	        end
	      end
	    end

	    countries_list_three = countries_list_three.uniq

	    relevant_details_three = []

	    final_array_three.each do |val|
	      if val.include?(relevant_words)
	        relevant_details_three.push(val)
	      end
	    end

	    final_dictionary_data_three = {}
	    final_dictionary_data_three[countries_list_three] = relevant_details_three



########################################################################################################################

		data_four = parsed_page.css('//*[@id="theDataTable"]/tbody/tr[4]').text

		filter_rule_four = data_four.split("\r\n\t\t    \t\t")
	    final_array_four = filter_rule_four.reject {|x| x.length < 20}
	    
	    countries_list_four = []

	    countries.each do |country|
	      final_array_four.each do |val|
	        if val.include?(country)
	          countries_list_four.push(country)
	        end
	      end
	    end

	    countries_list_four = countries_list_four.uniq

	    relevant_details_four = []

	    final_array_four.each do |val|
	      if val.include?(relevant_words)
	        relevant_details_four.push(val)
	      end
	    end

	    final_dictionary_data_four = {}
	    final_dictionary_data_four[countries_list_four] = relevant_details_four


########################################################################################################################

		data_five = parsed_page.css('//*[@id="theDataTable"]/tbody/tr[5]').text
		filter_rule_five = data_five.split("\r\n\t\t    \t\t")
		final_array_five = filter_rule_five.reject {|x| x.length < 20}

	    
	    countries_list_five = []

	    countries.each do |country|
	      final_array_five.each do |val|
	        if val.include?(country)
	          countries_list_five.push(country)
	        end
	      end
	    end

	    countries_list_five = countries_list_five.uniq

	    relevant_details_five = []

	    final_array_five.each do |val|
	      if val.include?(relevant_words)
	        relevant_details_five.push(val)
	      end
	    end

	    final_dictionary_data_five = {}
	    final_dictionary_data_five[countries_list_five] = relevant_details_five




	    main_dictionary[1] = final_dictionary_data
	    main_dictionary[2] = final_dictionary_data_two
	    main_dictionary[3] = final_dictionary_data_three
	    main_dictionary[4] = final_dictionary_data_four
	    main_dictionary[5] = final_dictionary_data_five


	    return main_dictionary
	end

	GUARDIAN_API="https://content.guardianapis.com/search?q=influenza&api-key=4a3e22f3-07c9-4fe0-9a92-df4083702d43"

	def get_guradian_data()
		data = HTTParty.get(GUARDIAN_API)
		titles = data.parsed_response["response"]["results"].map{ |val|  val["webTitle"] }
		return titles
	end

end
