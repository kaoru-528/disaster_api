require 'selenium-webdriver'

class ScrapingController < ApplicationController
  def index
    # Seleniumでブラウザを起動
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') # ブラウザを非表示で実行
    options.add_argument('--disable-gpu') # GPUを無効化（必要に応じて）
    options.add_argument('--no-sandbox') # Sandboxを無効化（Linux環境用）

    driver = Selenium::WebDriver.for(:chrome, options: options)

    begin
      # 日本気象庁の地震情報ページにアクセス
      url = 'https://www.jma.go.jp/bosai/#pattern=default&area_type=class20s&area_code=1320100'
      driver.get(url)

      # JavaScriptによるデータロードを待機（最大10秒）
      wait = Selenium::WebDriver::Wait.new(timeout: 10)
      wait.until { driver.find_element(id: 'bosaitop-bosai_earthquake_div') }

      # 指定されたIDの情報を取得
      element = driver.find_element(id: 'bosaitop-bosai_earthquake_div')
      @quake_info = element.attribute('outerHTML') # HTML全体を取得
    rescue Selenium::WebDriver::Error::TimeoutError
      @error = '地震情報の読み込みに失敗しました。'
    ensure
      # ブラウザを閉じる
      driver.quit
    end
  end
end