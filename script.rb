#!/usr/bin/env ruby

require 'tanakai'
require "uri"

class Spider < Tanakai::Base
    @name = "so_spread_spider"
    @engine = :selenium_chrome
    @start_urls = ["https://stackoverflow.com"]
    @config = {
      user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
      before_request: { delay: 4..7 }
    }

    def parse(response, url:, data: {})
        self.go_to_login_page
        self.fill_email_password_and_login
        self.run_user_activities
        self.log_success_message
    end

    def log_success_message
        found_avatar = browser.has_css?(".s-avatar--image")
        puts found_avatar ? "Successfully logged in to Stackoverflow today!" : "Unable to Login today"
    end

    def go_to_login_page
        browser.find("//*[@data-gps-track='login.click']").click
        puts "now on the login page"
    end

    def fill_email_password_and_login
        browser.find("//*[@id='email']").fill_in with: ENV['SO_EMAIL']
        browser.find("//*[@id='password']").fill_in with: ENV['SO_PASSWORD']
        browser.current_window.resize_to(1_200, 800)
        browser.find("//*[@id='submit-button']").click
        puts "successfully logged in"
    end

    def run_user_activities
        browser.click_on "Accept all cookies"
        browser.find("//*[@id='question-mini-list']//a", match: :first).click
        browser.find("//a[@rel='tag']", match: :first).click
        puts "ran user activities"
    end
end

unless ENV["SO_EMAIL"].is_a?(String) && ENV["SO_EMAIL"].size > 0
    puts "Set the stackoverflow email with the env variable SO_EMAIL"
    exit(-1)
end

unless ENV["SO_PASSWORD"].is_a?(String) && ENV["SO_PASSWORD"].size > 0
    puts "Set the stackoverflow email with the env variable SO_PASSWORD"
    exit(-1)
end

Spider.crawl!
