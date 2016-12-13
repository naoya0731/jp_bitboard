module JpBitboard

  require 'net/http'
  require 'uri'
  require 'json'
  require 'openssl'
  require 'open-uri'

  class Bitboard
     attr_accessor :data, :updated_at, :markets
     def initialize()
        @updated_at = Time.now
        @markets = [Market.new("bitFlyer", "https://api.bitflyer.jp/v1/ticker", "JPY"),
                    Market.new("Zaif", "http://api.zaif.jp/api/1/ticker/btc_jpy", "JPY"),
                    Market.new("Coincheck", "https://coincheck.jp/api/ticker", "JPY"),
                    Market.new("BtcBox", "https://www.btcbox.co.jp/api/v1/ticker/", "JPY"),
                    Market.new("Quoine", "https://api.quoine.com/products", "JPY"),
                    Market.new("OKCoin(USD)", "https://www.okcoin.com/api/v1/ticker.do?symbol=btc_usd", "USD"),
                    Market.new("OKCoin(CNY)", "https://www.okcoin.com/api/v1/ticker.do?symbol=btc_cny", "CNY")
                    ]
        #データのfetch
        @markets.each_with_index do |market,i|
            market.fetch
        end
     end
  end

  class Market
    attr_accessor :name, :url, :data, :currency

    def initialize(name,url,currency)
        @name = name
        @url = url
        @currency = currency
        @data = {bid: "N/A", ask: "N/A", last_price: "N/A", volume: "N/A"}
    end

    def fetch
        begin
           uri = URI.parse(@url)
           response = Net::HTTP.get_response(uri)

           if response.code == "200"
                @data = parse_data(JSON.parse(response.body))
           end
        rescue Exception => e
           @data = {bid: "N/A", ask: "N/A", last_price: "N/A", volume: "N/A"} 
        end
    end

    def parse_data(json)
        if json.nil?
            {bid: "N/A", ask: "N/A", last_price: "N/A", volume: "N/A"}
        else
            case @name 
            when "bitFlyer"
                tmp = {bid: json["best_bid"], ask: json["best_ask"], last_price: json["ltp"], volume: json["volume"]}
            when "Zaif"
                tmp = {bid: json["bid"], ask: json["ask"], last_price: json["last"], volume: json["volume"]}
            when "Coincheck"
                tmp = {bid: json["bid"], ask: json["ask"], last_price: json["last"], volume: json["volume"]}
            when "BtcBox"
                tmp = {bid: json["buy"], ask: json["sell"], last_price: json["last"], volume: json["vol"]}
            when "Quoine"
                tmp = {bid: json[2]["market_bid"], ask: json[2]["market_ask"], last_price: json[2]["last_traded_price"], volume: json[2]["volume_24h"]}
            when "OKCoin(USD)"
                tmp = {bid: json["ticker"]["buy"], ask: json["ticker"]["sell"], last_price: json["ticker"]["last"], volume: json["ticker"]["vol"]}
            when "OKCoin(CNY)"
                tmp = {bid: json["ticker"]["buy"], ask: json["ticker"]["sell"], last_price: json["ticker"]["last"], volume: json["ticker"]["vol"]}
            end

            tmp[:bid] = tmp[:bid].to_i
            tmp[:ask] = tmp[:ask].to_i
            tmp[:last_price] = tmp[:last_price].to_i
            tmp[:volume] = tmp[:volume].to_i
            tmp
        end
    end
  end
end
