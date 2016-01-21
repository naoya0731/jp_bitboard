module JpBitboard

  require 'net/http'
  require 'uri'
  require 'json'

  class Client
     def initialize(options = {})
        @data = Hash.new
        @updated_at = Time.now
        update
     end

     def data
        @data
     end

     def updated_at
        @updated_at
     end

     def update
        @data["bitflyer"] = update_bitflyer
        @data["zaif"] = update_zaif
        @data["coincheck"] = update_coincheck
        @data["btcbox"] = update_btcbox
        @data["quoine"] = update_quoine
        @updated_at = Time.now
     end

     def get_json(url)
      uri = URI.parse(url)
      json = Net::HTTP.get(uri)
      return JSON.parse(json)
     end

     def update_bitflyer
        data = get_json('https://api.bitflyer.jp/v1/ticker')
        return {bid: data["best_bid"], ask: data["best_ask"], last_price: data["ltp"]}
     end

     def update_zaif
        data = get_json('https://api.zaif.jp/api/1/ticker/btc_jpy')
        return {bid: data["bid"], ask: data["ask"], last_price: data["last"]}
     end

     def update_coincheck
        data = get_json('https://coincheck.jp/api/ticker')
        return {bid: data["bid"], ask: data["ask"], last_price: data["last"]}
     end

     def update_btcbox
        data = get_json('https://www.btcbox.co.jp/api/v1/ticker/')
        return {bid: data["buy"], ask: data["sell"], last_price: data["last"]}
     end

     def update_quoine
        data = get_json('https://api.quoine.com/products')
        return {bid: data[2]["market_bid"], ask: data[2]["market_ask"], last_price: data[2]["last_traded_price"]}
     end
  end
end
