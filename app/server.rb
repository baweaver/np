# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'rubocop-ast'
require 'parser/current'
require 'yaml'
require_relative '../lib/np'

DOCS = YAML.load_file("#{__dir__}/docs.yaml").freeze

DOCS_URL = 'https://docs.rubocop.org/rubocop-ast/node_pattern.html'

get '/' do
  slim :home
end

post '/update' do
  h = params.to_h.transform_keys!(&:to_sym)
  @info = Np::Debugger.new(**h)
  begin
    html = %i[ruby_ast matches].to_h do |id|
      [id, slim(id, layout: false)]
    end
    json({
      html: html,
      node_pattern_unist: @info.node_pattern_to_unist,
      comments_unist: @info.comments_to_unist,
      best_match: @info.best_match_to_unist,
      also_matched: @info.also_matched,
    })
  rescue Exception => e
    @error = e
    json({
      html: {matches: slim(:error, layout: false)},
      exception: {message: e.message, trace: e.backtrace},
    })
  end
end
