#!/usr/bin/env ruby

require 'colorize'
require 'terminal-table'
require 'httparty'

MARKET_STATE_INDICATOR = {"REGULAR" => "", "PRE" => "-", "POST" => "+"}


def round_and_colorize(str)
    num_f = str.to_f    
    color = num_f <= 0 ? :red : :green
    str.to_f.round(2).to_s.colorize(color)
end

def round(str)
    str.to_f.round(2).to_s
end

def get_indicator(market_state)
    MARKET_STATE_INDICATOR[market_state]
end

def format_result(item)
    market_state = item['marketState']    
    display = get_indicator(market_state) + item['symbol'].colorize(:yellow)
    price = market_state == "REGULAR" ? item["regularMarketPrice"] : market_state == "POST" ? item["postMarketPrice"] : item["preMarketPrice"]
    change_usd = market_state == "REGULAR" ? item["regularMarketChange"] : market_state == "POST" ? item["postMarketChange"] : item["preMarketChange"]
    change_percent = market_state == "REGULAR" ? item["regularMarketChangePercent"] : market_state == "POST" ? item["postMarketChangePercent"] : item["preMarketChangePercent"]
    [display, round(price).colorize(:bold).bold, round_and_colorize(change_usd), "(#{round_and_colorize(change_percent)}%)"]
end

def calculate_rows(symbols)
    rows = []
    api_url = "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com&symbols=#{symbols}"    
    http_result = HTTParty.get(api_url, {
        headers: {"User-Agent" => "Httparty", "cache-control": "public, max-age=1, stale-while-revalidate=9"},        
      })

    http_result["quoteResponse"]["result"].each do |quote|
        rows << format_result(quote)
    end
   rows 
end

def empty_row 
    [["-","-","-","-"]]
end

def print_legend    
    puts ""

    MARKET_STATE_INDICATOR.each do |key,value|
        puts "#{value} #{key} Market" if value != ""
    end  
end

def create_table(symbols)

    table_rows = []

    symbols.each do |sym|          
        group_rows = calculate_rows(sym)        
        table_rows = table_rows + group_rows
    end

    table = Terminal::Table.new :rows => table_rows, :headings => ["Symbol", "MKT Price", "MKT Change $", "MKT Change %"], :style => { :alignment => :right, :all_separators => true }
    puts table        
    puts "Last updated: #{Time.now.strftime("%A, %d %b %Y %l:%M:%S %p %Z")}"
    print_legend
    
end

if ARGV[0] == nil
    abort "Usage: ticker AAPL,MSFT"
    exit!
else
    symbols = [ARGV[0]]
    create_table(symbols)    
end










