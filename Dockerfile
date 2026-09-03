FROM ghcr.io/cirruslabs/flutter:3.22.1

WORKDIR /workspace/app

COPY app/pubspec.yaml app/pubspec.lock ./
RUN touch .env && flutter pub get

COPY app/ ./
COPY docker/entrypoint.sh /usr/local/bin/swifty-companion
RUN chmod +x /usr/local/bin/swifty-companion

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/swifty-companion"]
