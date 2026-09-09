# syntax=docker/dockerfile:1.7

FROM ghcr.io/cirruslabs/flutter:3.22.1

WORKDIR /workspace/app

RUN flutter config --enable-web --no-analytics

COPY app/pubspec.yaml app/pubspec.lock ./
RUN --mount=type=cache,target=/root/.pub-cache \
	touch .env && flutter pub get

COPY app/ ./
COPY docker/entrypoint.sh /usr/local/bin/swifty-companion
RUN chmod +x /usr/local/bin/swifty-companion

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/swifty-companion"]
