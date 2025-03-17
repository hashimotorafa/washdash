module WashAndGo
  require "nokogiri"

  class BaseCrawler
    SELENIUM_URL            = "http://selenium:4444/wd/hub"
    URL                     = "https://dash.omolavanderiacompartilhada.com.br"
    class PageTimedOutError < StandardError; end
    class LoginFailedError  < StandardError; end

    class << self
      private

      def setup_driver
        Selenium::WebDriver.for :remote, url: SELENIUM_URL, options: options
      end

      def options
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument("--headless=new") # Optional: Run Chrome in headless mode
        options.add_preference(:download, download_preferences)
        puts "options: #{options.to_json}"
        options
      end

      def download_preferences
        {
          download: {
            prompt_for_download: false,
            default_directory:   "/home/seluser/Downloads"
          }
        }
      end


      # Helper Methods
      def wait_until
        wait = Selenium::WebDriver::Wait.new(timeout: 20)
        return true if wait.until { yield }

        raise PageTimedOutError, "Page Exceeded Wait Time"
      end

      def page_loaded
        @driver.execute_script('return document.readyState === "complete";')
      end

      def redirect_login_page
        @driver.navigate.to(URL)

        wait_until { page_loaded }
      end

      def login(email, password)
        redirect_login_page

        puts "Log In - Start"
        @driver.find_element(id: "admin_usuario_email").send_keys(email)
        @driver.find_element(id: "admin_usuario_password").send_keys(password)
        @driver.find_element(name: "commit").click()
        puts "Log In - Submitted Email and Password"

        wait_until { admin_page_loaded }

        puts "Log In - Done"
      rescue => _e
        raise LoginFailedError, "Login Step Failed"
      end

      def admin_page_loaded
        @driver.current_url == "#{URL}/admin" && page_loaded
      end
    end
  end
end
