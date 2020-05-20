#!/usr/bin/env ruby

require 'colorize'
require 'terminal-table'
require 'httparty'


def round_and_colorize(str)
    num_f = str.to_f    
    color = num_f <= 0 ? :red : :green
    str.to_f.round(2).to_s.colorize(color)
end

def round(str)
    str.to_f.round(2).to_s
end

def format_result(item)
    [item["symbol"].colorize(:yellow), round(item["regularMarketPrice"]).colorize(:bold).bold, round_and_colorize(item["regularMarketChange"]), "(#{round_and_colorize(item["regularMarketChangePercent"])}%)"]
end

def calculate_rows(symbols)
    rows = []
    api_url = "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com&symbols=#{symbols}"    
    http_result = HTTParty.get api_url    

    http_result["quoteResponse"]["result"].each do |quote|
        rows << format_result(quote)
    end
   rows 
end

def empty_row 
    [["-","-","-","-"]]
end

def create_table(symbols)

    table_rows = []

    symbols.each do |sym|          
        group_rows = calculate_rows(sym)        
        table_rows = table_rows + group_rows
    end

    table = Terminal::Table.new :rows => table_rows, :headings => ["Symbol", "MKT Price", "MKT Change", "MKT Change %"], :style => { :alignment => :right, :all_separators => true }
    puts table        
    
end

if ARGV[0] == nil
    abort "Usage: ticker AAPL,MSFT"
    exit!
else
    symbols = [ARGV[0]]
    create_table(symbols)
end










