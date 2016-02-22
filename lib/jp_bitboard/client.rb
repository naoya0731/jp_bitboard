module JpBitboard

  require 'net/http'
  require 'uri'
  require 'json'
  require 'openssl'
  require 'open-uri'

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
        @data["okcoin_usd"] = update_okcoin_usd
        @data["okcoin_cny"] = update_okcoin_cny
        @updated_at = Time.now
     end

     def get_json(url)
      uri = URI.parse(url)
      json = Net::HTTP.get(uri)
      return JSON.parse(json)
     end

     def update_bitflyer
        data = get_json('https://api.bitflyer.jp/v1/ticker')
        return {bid: data["best_bid"], ask: data["best_ask"], last_price: data["ltp"], volume: data["volume_by_product"].to_i}
     end

     def update_zaif
        data = get_json('http://api.zaif.jp/api/1/ticker/btc_jpy')
        return {bid: data["bid"], ask: data["ask"], last_price: data["last"], volume: data["volume"].to_i}
     end

     def update_coincheck
        data = get_json('https://coincheck.jp/api/ticker')
        return {bid: data["bid"], ask: data["ask"], last_price: data["last"], volume: data["volume"].to_i}
     end

     def update_btcbox
        data = get_json('https://www.btcbox.co.jp/api/v1/ticker/')
        return {bid: data["buy"], ask: data["sell"], last_price: data["last"], volume: data["vol"].to_i}
     end

     def update_quoine
        data = get_json('https://api.quoine.com/products')
        return {bid: data[2]["market_bid"], ask: data[2]["market_ask"], last_price: data[2]["last_traded_price"], volume: data[2]["volume_24h"].to_i}
     end

     def update_okcoin_usd
        data = get_json('https://www.okcoin.com/api/v1/ticker.do?symbol=btc_usd')
        return {bid: data["ticker"]["buy"], ask: data["ticker"]["sell"], last_price: data["ticker"]["last"], volume: data["ticker"]["vol"]}
     end

     def update_okcoin_cny
        data = get_json('https://www.okcoin.cn/api/v1/ticker.do?symbol=btc_cny')
        return {bid: data["ticker"]["buy"].to_i, ask: data["ticker"]["sell"].to_i, last_price: data["ticker"]["last"].to_i, volume: data["ticker"]["vol"].to_i}
     end
  end
end
