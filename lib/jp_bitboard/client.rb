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
        @markets = [Market.new("bitFlyer", "bitflyer", "https://api.bitflyer.jp/v1/ticker", "JPY","https://bitflyer.jp/ja/"),
                    Market.new("Zaif", "zaif","http://api.zaif.jp/api/1/ticker/btc_jpy", "JPY","https://zaif.jp/"),
                    Market.new("Coincheck", "coincheck","https://coincheck.jp/api/ticker", "JPY", "https://coincheck.jp"),
                    Market.new("BtcBox", "btcbox","https://www.btcbox.co.jp/api/v1/ticker/", "JPY","https://www.btcbox.co.jp"),
                    Market.new("Quoine", "quoine","https://api.quoine.com/products", "JPY","https://www.quoine.com"),
                    Market.new("OKCoin(USD)", "okcoin_usd","https://www.okcoin.com/api/v1/ticker.do", "USD","https://www.okcoin.com"),
                    Market.new("OKCoin(CNY)", "okcoin_cny","https://www.okcoin.cn/api/v1/ticker.do", "CNY","https://www.okcoin.cn"),
                    Market.new("bitbank", "bitbank","https://bitbanktrade.jp/api/spot_ticker","USD","https://bitbanktrade.jp")
                    ]
        #データのfetch
        @markets.each do |market|
            market.fetch
        end
     end

     def method_missing(method, *args)
        @markets.each do |mk|
          if mk.code == method.to_s
            return mk
          end
        end
     end

     def average
        markets = @markets.select{|market| market.currency == "JPY" && market.data[:last_price] > 0}
        sum = markets.collect{|market| market.data[:last_price]}.inject(:+)
        (sum / markets.count).to_i
     end
  end

  class Market
    attr_accessor :name, :url, :code, :data, :currency, :web

    def initialize(name,code,url,currency,web)
        @name = name
        @code = code
        @url = url
        @currency = currency
        @web = web
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
            when "bitbank"
                tmp = {bid: json["ticker"]["buy"], ask: json["ticker"]["sell"], last_price: json["ticker"]["last"], volume: json["ticker"]["vol"], tts: json["exchange_rate"]["TTS"]}
            end

            if @currency == "JPY" || @currency == "CNY"
              tmp[:bid] = tmp[:bid].to_i
              tmp[:ask] = tmp[:ask].to_i
              tmp[:last_price] = tmp[:last_price].to_i
              tmp[:volume] = tmp[:volume].to_i
              tmp[:tts] = tmp[:tts].to_f
            elsif @currency == "USD"
              tmp[:bid] = tmp[:bid].to_f
              tmp[:ask] = tmp[:ask].to_f
              tmp[:last_price] = tmp[:last_price].to_f
              tmp[:volume] = tmp[:volume].to_i
              tmp[:tts] = tmp[:tts].to_f
            end

            tmp
        end
    end
  end
end
