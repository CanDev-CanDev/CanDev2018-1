class StaticPagesController < ApplicationController

	def home
		@pub_med = get_pub_med_data(
							url_ids: "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=science%5bjournal%5d+OR+vaccine+influenza+OR+2008%5bpdat%5d&retmode=json&retmax=10",
		 					url_abstracts: "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=text&rettype=abstract&id=" 
		 				)



		@twitter_data = get_twitter_data()

		debugger
	end
end
