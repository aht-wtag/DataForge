# ===== Stage 1: Base =====
FROM ruby:3.3.8-slim AS base

ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      build-essential \
      libpq-dev \
      libyaml-dev \
      libffi-dev \
      git \
      curl \
      libvips \
      pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'production' && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

# ===== Stage 2: Development =====
FROM base AS development

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
