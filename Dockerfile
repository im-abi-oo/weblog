# مرحله اول: Build
FROM node:18.13.0-alpine AS builder

WORKDIR /app

# کپی فایل‌های مورد نیاز برای نصب پکیج‌ها
COPY package*.json ./

# نصب همه وابستگی‌ها (حتی devDependencies برای کامپایل)
RUN npm install

# کپی کل پروژه
COPY . .

# کامپایل تایپ‌اسکریپت به جاوااسکریپت (خروجی در پوشه dist می‌رود)
RUN npx tsc

# مرحله دوم: Production
FROM node:18.13.0-alpine

# تنظیم کاربر غیر ریشه برای امنیت
RUN apk update && addgroup -S app && adduser -S -G app app

WORKDIR /app

# کپی فایل‌های مورد نیاز
COPY package*.json ./

# فقط نصب پکیج‌های اصلی (بدون انواع تایپ و ابزارهای بیلد)
RUN npm install --only=production

# کپی کردن خروجی کامپایل شده از مرحله قبل
COPY --from=builder /app/dist ./dist

# اگر پروژه شما به پوشه views (برای EJS) یا public نیاز دارد، این خط را اضافه کنید:
COPY --from=builder /app/views ./views
# COPY --from=builder /app/public ./public

# ایجاد پوشه دیتا
RUN mkdir data && chown app:app /app/data

USER app

EXPOSE 8080

# اجرا از پوشه dist
CMD ["node", "dist/app.js"]
