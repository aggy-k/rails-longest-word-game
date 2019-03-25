require 'open-uri'
require 'time'

class GamesController < ApplicationController

  def new
    @alphabets = ('A'..'Z').to_a
    @letters = []
    10.times { @letters << @alphabets.sample }
    @start_time = Time.now
  end

  def score
    # raise
    @word = params[:word]
    @grid = params[:grid]
    # @time = (params[:end_time] - params[:start_time])
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    game(@word, @grid, @start_time, @end_time)
    # game(@word)
  end

  def game(word, grid, start_time, end_time)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    serialized = open(url).read
    word_found = JSON.parse(serialized)['found']
    @time = end_time - start_time
    @score = (word.length / @time).round
    session[:score] = session[:score].nil? ? 0 : session[:score]

    if !word_found
      @score = 0
      @message = "Word not found"
      session[:score] += @score
      @total_score = session[:score]
    elsif !(validation?(word, grid))
      @score = 0
      @message = "Please use only provided letters"
      session[:score] += @score
      @total_score = session[:score]
    else
      @message = "Your score: #{@score}, time spent: #{@time}"
      session[:score] += @score
      @total_score = session[:score]
    end
  end

  def validation?(word, grid)
    word = word.upcase
    word_split = word.split('')
    word_split.all? { |l| word_split.count(l) <= grid.count(l) }
  end
end
