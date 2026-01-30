# مرحله اول: Build
FROM node:18.13.0-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npx tsc

# مرحله دوم: Production
FROM node:18.13.0-alpine

# ایجاد گروه و یوزر
RUN apk update && addgroup -S app && adduser -S -G app app

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/views ./views
# اگر پوشه public داری این خط رو از کامنت در بیار:
# COPY --from=builder /app/public ./public

# --- حل مشکل اصلی اینجاست ---
# ایجاد پوشه‌های مورد نیاز و دادن دسترسی کامل به یوزر app
RUN mkdir -p /app/logs /app/data && \
    chown -R app:app /app/logs /app/data && \
    chmod -R 755 /app/logs /app/data

# حالا سوییچ می‌کنیم روی یوزر app
USER app

EXPOSE 8080

CMD ["node", "dist/app.js"]
