FROM alpine:3.23.5

WORKDIR /app

COPY content.txt .

CMD ["cat", "/app/content.txt"]
