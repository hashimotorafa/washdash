FROM ruby:3.1

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN wget https://chromedriver.storage.googleapis.com/2.38/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN mv chromedriver /bin

RUN apt-get update -qq && apt-get install -y nodejs npm postgresql-client yarn cron systemctl vim


RUN mkdir /web
WORKDIR /web
COPY Gemfile /web/Gemfile
COPY Gemfile.lock /web/Gemfile.lock
RUN bundle install

COPY . /web

# RUN whenever --update-crontab --set 'environment=development'

# RUN systemctl enable cron.service
# RUN systemctl restart cron

COPY ./docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]