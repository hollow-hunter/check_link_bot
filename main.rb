# frozen_string_literal: true

require 'redd'

flair = ENV['REDDIT_FLAIR']
session = Redd.it(
  user_agent: 'Redd:CheckSauce:v1.0.0 (by /u/NelsonBelmont)',
  client_id: ENV['REDDIT_CLIENT_ID'],
  secret: ENV['REDDIT_SECRET'],
  username: ENV['REDDIT_USERNAME'],
  password: ENV['REDDIT_PASSWORD']
)
loop do
  session.subreddit(ENV['SUBREDDIT']).new.each do |post|
    next unless post.link_flair_text == flair && !post.saved

    time_passed = (Time.now - Time.at(post.created_utc)) / 60
    next unless time_passed >= 15

    if post.comments.any? { |c| c.body.include?('https://imgur.com') && c.author_fullname == post.author_fullname }
      post.save
      puts 'post safe'
    else
      post.remove
      puts 'post removed'
    end
  end
  puts 'Now waiting 10 minutes...'
  sleep(600)
end
