FROM ruby:2.7.1

RUN RAILS_ENV="production"

RUN gem install bundler rake
RUN bundle config set path 'vendor'

WORKDIR /var/www/html
RUN git clone -b dev https://github.com/wasuken/repbl
WORKDIR /var/www/html/repbl

# npm
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt update -y
RUN apt install -y build-essential nodejs
RUN apt install -y yarn

ADD ./master.key /var/www/html/repbl/config/master.key

RUN bundle install
RUN yarn install --check-files
RUN RAILS_ENV=production rake db:migrate
RUN RAILS_ENV=production rake assets:precompile

RUN gem install rails

# ENTRYPOINT [ "/var/www/html/repbl/bin/rails" "s" "-b" "0.0.0.0" ]
RUN sed -i '20iconfig.serve_static_assets = true' /var/www/html/repbl/config/environments/production.rb
RUN bash -l -c 'RAILS_ENV=production bundle exec rake repo:insert[https://github.com/wasuken/nippo/archive/master.zip,nippo]'
CMD bash -l -c 'RAILS_ENV=production bundle exec rails s'
