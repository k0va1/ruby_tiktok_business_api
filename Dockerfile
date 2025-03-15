FROM ruby:3.2-alpine

# Install build dependencies for native extensions
RUN apk add --no-cache build-base git bash

# Set up working directory
WORKDIR /gem

# Copy dependency files
COPY Gemfile* tiktok_business_api.gemspec /gem/
COPY lib/tiktok_business_api/version.rb /gem/lib/tiktok_business_api/

# Install dependencies
RUN bundle install

# Copy the rest of the application
COPY . /gem/

# Make sure scripts are executable
RUN mkdir -p /gem/bin && chmod +x /gem/bin/* || true

# Set default command
CMD ["bundle", "exec", "rake", "--tasks"]