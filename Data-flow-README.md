معرفی پروژه  
این پروژه شامل یک اسکریپت Bash به نام log_sender.sh است که به صورت دوره‌ای (هر ۶۰ ثانیه) لاگ‌هایی شامل اطلاعات جمعیتی و آب‌وهوایی فرضی را به صورت JSON تولید و روی پورت 2285 لوکال ارسال می‌کند.  
همچنین یک فایل سرویس systemd به نام log_sender.service برای اجرای خودکار و مدیریت این اسکریپت روی سیستم وجود دارد.

---

ساختار دایرکتوری

log/
├── log_sender.sh          # اسکریپت Bash تولید و ارسال لاگ
└── log_sender.service     # فایل سرویس systemd برای اجرای اسکریپت

---

توضیح فایل‌ها

- log_sender.sh  
  اسکریپتی که هر دقیقه اجرا می‌شود و یک پیام لاگ شامل اطلاعات زیر می‌سازد و ارسال می‌کند:  
  - timestamp (زمان لاگ)  
  - جمعیت فرضی یک شهر (tehran) با مقادیر men، women، population  
  - مقادیر hOffset و vOffset  
  - وضعیت آب‌وهوا به صورت تصادفی از مجموعه حالات تعریف شده (sunny, rainy, cloudy, stormy, foggy, windy)  
  سپس پیام را با دستور logger به آدرس و پورت تعیین شده (127.0.0.1:2285) ارسال می‌کند.

- log_sender.service  
  فایل unit systemd برای اجرای اسکریپت log_sender.sh:  
  - اسکریپت به عنوان کاربر root اجرا می‌شود.  
  - در صورت توقف ناگهانی، سرویس به صورت خودکار ری‌استارت می‌شود.  
  - خروجی و خطاها به null هدایت می‌شوند.  
  - سرویس هنگام بوت سیستم به صورت خودکار فعال می‌شود.

---

نحوه راه‌اندازی و استفاده

1. اطمینان از دسترسی به اسکریپت و فایل سرویس:

   - اسکریپت log_sender.sh باید اجرایی باشد (chmod +x log_sender.sh).
   - مسیر اسکریپت در فایل log_sender.service باید صحیح باشد (در اینجا /root/task/log/log_sender.sh).

2. کپی فایل سرویس به systemd:

   ```bash
   sudo cp log_sender.service /etc/systemd/system/

  
1. تنظیم مقادیر متغیرهای FTP_USER و FTP_PASS در فایل .env مطابق با نیاز.

2. اجرای دستور زیر برای راه‌اندازی سرویس FTP:

   ```bash
   docker-compose up -d

  

ساختار پروژه:
- docker-compose.yml : فایل پیکربندی برای اجرای سرویس‌های Kafka و AKHQ با Docker Compose
- volumes:
  - kafka-data: برای ذخیره‌سازی داده‌های Kafka به صورت پایدار
- networks:
  - kafka-net: شبکه اختصاصی برای ارتباط بین کانتینرها

سرویس‌ها:
1. kafka:
   - تصویر Docker: confluentinc/cp-kafka:7.4.0
   - پورت: 9092
   - متغیرهای محیطی برای تنظیم کلاستر Kafka و نقش‌های Broker و Controller
   - بررسی سلامت با دستور kafka-broker-api-versions

2. akhq:
   - تصویر Docker: tchiotludo/akhq:latest
   - پورت: 8080
   - وابسته به سرویس kafka برای اطمینان از اجرای Kafka قبل از راه‌اندازی AKHQ
   - تنظیمات اتصال به Kafka از طریق bootstrap.servers

نحوه اجرا:
1. اطمینان از نصب Docker و Docker Compose بر روی سیستم
2. اجرای دستور زیر در مسیر پروژه:
   docker-compose up -d
3. دسترسی به AKHQ از طریق مرورگر به آدرس:
   http://localhost:8080

حذف سرویس‌ها:
برای توقف و حذف کانتینرها و شبکه‌ها و حجم‌ها:
   docker-compose down -v
# ELK Stack with Kafka Integration

معرفی پروژه:
در مرحله اخر این تسک سرویس  ELK Stack (Elasticsearch، Logstash، Kibana) با استفاده از Docker Compose راه اندازی شده است که لاگ‌ها را از Kafka دریافت کرده و پردازش می‌کند.  
هدف پروژه تحلیل و نمایش لاگ‌ها به صورت ساختاریافته با استفاده از ELK است.

ساختار پروژه:
- docker-compose.yml : تعریف سرویس‌های elasticsearch، kibana، logstash، شبکه‌ها و حجم داده‌ها  
- .env : شامل متغیرهای محیطی برای نام‌کاربری و رمز عبور  
- logstash.conf : پیکربندی Logstash برای دریافت داده‌ها از Kafka، پردازش لاگ‌ها با فیلتر grok و json و ارسال به Elasticsearch

جزئیات فایل‌ها:
- docker-compose.yml :  
  شامل سه سرویس اصلی:  
  elasticsearch با نسخه 8.6.0 و تنظیمات حافظه و امنیت  
  kibana به عنوان رابط کاربری برای مشاهده داده‌ها  
  logstash برای پردازش داده‌ها و دریافت پیام‌ها از Kafka  
- .env : متغیرهای ELASTIC_USER، ELASTIC_PASSWORD، KIBANA_USER، KIBANA_PASSWORD  
- logstash.conf :  
  ورودی kafka که به topic "my-script-logs" متصل می‌شود،  
  فیلتر grok برای استخراج timestamp، hostname، user، process، و پیام اپلیکیشن،  
  تبدیل رشته JSON به فیلدها،  
  تنظیم timezone Asia/Tehran،  
  و خروجی به Elasticsearch با ایندکس روزانه

نحوه راه‌اندازی:
1. فایل .env را با مقادیر مناسب برای نام‌کاربری و پسورد پر کنید.  
2. اگر شبکه kafka_kafka-net وجود ندارد، آن را ایجاد کنید:  
   docker network create kafka_kafka-net  
3. سرویس‌ها را با دستور زیر اجرا کنید:  
   docker-compose up -d

نحوه استفاده:
- دسترسی به Elasticsearch از طریق پورت 9200  
- دسترسی به Kibana از طریق پورت 5601  
- داده‌های Kafka توسط Logstash دریافت و پردازش می‌شوند و در Elasticsearch ذخیره می‌شوند.

نکات مهم:
- اطمینان حاصل کنید که Kafka broker با نام kafka_broker و پورت 9093 فعال است.  
- حجم داده‌ها در volums های es_data و kibana-data ذخیره می‌شوند تا داده‌ها پایدار باشند.  
- بررسی لاگ‌های سرویس‌ها برای عیب‌یابی:  
  docker logs elasticsearch  
  docker logs kibana  
  docker logs logstash

شبکه‌ها و حجم‌ها:
- elk-net : شبکه اختصاصی برای ELK  
- kafka_kafka-net : شبکه خارجی برای اتصال به Kafka  
- es_data : داده‌های Elasticsearch  
- kibana-data : داده‌های Kibana
---

ساختار دایرکتوری

rsyslog_config/
└── myapp.conf         # فایل پیکربندی اصلی rsyslog برای دریافت و ارسال لاگ

---

توضیح فایل‌ها  

- myapp.conf  
  - بارگذاری ماژول‌های لازم:  
    - imudp برای دریافت لاگ‌ها از طریق UDP  
    - omkafka برای ارسال لاگ‌ها به Kafka  
  - تعریف ورودی UDP روی پورت 2285  
  - شرط برای لاگ‌هایی که از imudp دریافت می‌شوند:  
    - ذخیره لاگ‌ها در فایل محلی /var/log/myapp_ftp/myapp_remote.log  
    - ارسال لاگ‌ها به موضوع (topic) Kafka به نام my-script-logs در broker لوکال localhost:9092  
  - استفاده از stop برای جلوگیری از پردازش بیشتر لاگ‌ها بعد از این تنظیمات

---

نحوه راه‌اندازی و استفاده

1. اطمینان از نصب و فعال بودن rsyslog با پشتیبانی از ماژول‌های UDP و Kafka.

2. کپی فایل پیکربندی myapp.conf به دایرکتوری پیکربندی rsyslog (معمولاً /etc/rsyslog.d/):

   ```bash
   sudo cp myapp.conf /etc/rsyslog.d/
 یک سرور FTP با استفاده از Docker Compose و ایمیج آماده‌ی vsftpd راه اندازی شده است.  
سرور FTP با تنظیمات حالت Passive فعال شده و دسترسی یوزر ftp را به  فایل‌های دریافتی در دایرکتوری /var/log/myapp_ftpفراهم میکند.

---

ساختار دایرکتوری

ftp/
├── docker-compose.yml   # تعریف سرویس FTP با Docker Compose
├── .env                 # متغیرهای محیطی شامل نام کاربری و پسورد FTP
└── vsftpd.conf          # فایل تنظیمات سرویس vsftpd

---

توضیح فایل‌ها

- docker-compose.yml  
  - سرویس ftp را با استفاده از ایمیج bogem/ftp:latest اجرا می‌کند.  
  - نام کانتینر ftp_server است.  
  - متغیرهای محیطی شامل نام کاربری و پسورد از فایل .env خوانده می‌شود.  
  - حالت Passive فعال است و محدوده پورت‌های Passive بین 47400 تا 47470 تنظیم شده است.  
  - پورت 21 و محدوده پورت‌های Passive از میزبان به کانتینر منتقل شده‌اند.  
  - دایرکتوری /var/log/myapp_ftp میزبان به مسیر /home/vsftpd کانتینر متصل شده است تا فایل‌ها ذخیره شوند.  
  - فایل تنظیمات vsftpd.conf روی کانتینر کپی می‌شود.  
  - سرویس در صورت توقف ناگهانی مجدداً راه‌اندازی می‌شود.

- .env  
  شامل متغیرهای محیطی:  
  - FTP_USER : نام کاربری FTP  
  - FTP_PASS : پسورد FTP

- vsftpd.conf  
  تنظیمات سرویس vsftpd:  
  - فعال بودن حالت گوش دادن روی IPv4 و غیر فعال بودن IPv6  
  - غیرفعال بودن لاگین ناشناس  
  - فعال بودن دسترسی کاربران محلی و اجازه نوشتن  
  - تنظیمات مربوط به پرمیشن‌ها و امنیت chroot  
  - فعال بودن حالت Passive و تعریف محدوده پورت‌های آن  
  - تعیین آدرس IP برای حالت Passive
1. تنظیم مقادیر متغیرهای FTP_USER و FTP_PASS در فایل .env مطابق با نیاز.

2. اجرای دستور زیر برای راه‌اندازی سرویس FTP:

   ```bash
   docker-compose up -d

  

ساختار پروژه:
- docker-compose.yml : فایل پیکربندی برای اجرای سرویس‌های Kafka و AKHQ با Docker Compose
- volumes:
  - kafka-data: برای ذخیره‌سازی داده‌های Kafka به صورت پایدار
- networks:
  - kafka-net: شبکه اختصاصی برای ارتباط بین کانتینرها

سرویس‌ها:
1. kafka:
   - تصویر Docker: confluentinc/cp-kafka:7.4.0
   - پورت: 9092
   - متغیرهای محیطی برای تنظیم کلاستر Kafka و نقش‌های Broker و Controller
   - بررسی سلامت با دستور kafka-broker-api-versions

2. akhq:
   - تصویر Docker: tchiotludo/akhq:latest
   - پورت: 8080
   - وابسته به سرویس kafka برای اطمینان از اجرای Kafka قبل از راه‌اندازی AKHQ
   - تنظیمات اتصال به Kafka از طریق bootstrap.servers

نحوه اجرا:
1. اطمینان از نصب Docker و Docker Compose بر روی سیستم
2. اجرای دستور زیر در مسیر پروژه:
   docker-compose up -d
3. دسترسی به AKHQ از طریق مرورگر به آدرس:
   http://localhost:8080

حذف سرویس‌ها:
برای توقف و حذف کانتینرها و شبکه‌ها و حجم‌ها:
   docker-compose down -v
# ELK Stack with Kafka Integration

معرفی پروژه:
در مرحله اخر این تسک سرویس  ELK Stack (Elasticsearch، Logstash، Kibana) با استفاده از Docker Compose راه اندازی شده است که لاگ‌ها را از Kafka دریافت کرده و پردازش می‌کند.  
هدف پروژه تحلیل و نمایش لاگ‌ها به صورت ساختاریافته با استفاده از ELK است.

ساختار پروژه:
- docker-compose.yml : تعریف سرویس‌های elasticsearch، kibana، logstash، شبکه‌ها و حجم داده‌ها  
- .env : شامل متغیرهای محیطی برای نام‌کاربری و رمز عبور  
- logstash.conf : پیکربندی Logstash برای دریافت داده‌ها از Kafka، پردازش لاگ‌ها با فیلتر grok و json و ارسال به Elasticsearch

جزئیات فایل‌ها:
- docker-compose.yml :  
  شامل سه سرویس اصلی:  
  elasticsearch با نسخه 8.6.0 و تنظیمات حافظه و امنیت  
  kibana به عنوان رابط کاربری برای مشاهده داده‌ها  
  logstash برای پردازش داده‌ها و دریافت پیام‌ها از Kafka  
- .env : متغیرهای ELASTIC_USER، ELASTIC_PASSWORD، KIBANA_USER، KIBANA_PASSWORD  
- logstash.conf :  
  ورودی kafka که به topic "my-script-logs" متصل می‌شود،  
  فیلتر grok برای استخراج timestamp، hostname، user، process، و پیام اپلیکیشن،  
  تبدیل رشته JSON به فیلدها،  
  تنظیم timezone Asia/Tehran،  
  و خروجی به Elasticsearch با ایندکس روزانه

نحوه راه‌اندازی:
1. فایل .env را با مقادیر مناسب برای نام‌کاربری و پسورد پر کنید.  
2. اگر شبکه kafka_kafka-net وجود ندارد، آن را ایجاد کنید:  
   docker network create kafka_kafka-net  
3. سرویس‌ها را با دستور زیر اجرا کنید:  
   docker-compose up -d

نحوه استفاده:
- دسترسی به Elasticsearch از طریق پورت 9200  
- دسترسی به Kibana از طریق پورت 5601  
- داده‌های Kafka توسط Logstash دریافت و پردازش می‌شوند و در Elasticsearch ذخیره می‌شوند.

نکات مهم:
- اطمینان حاصل کنید که Kafka broker با نام kafka_broker و پورت 9093 فعال است.  
- حجم داده‌ها در volums های es_data و kibana-data ذخیره می‌شوند تا داده‌ها پایدار باشند.  
- بررسی لاگ‌های سرویس‌ها برای عیب‌یابی:  
  docker logs elasticsearch  
  docker logs kibana  
  docker logs logstash

شبکه‌ها و حجم‌ها:
- elk-net : شبکه اختصاصی برای ELK  
- kafka_kafka-net : شبکه خارجی برای اتصال به Kafka  
- es_data : داده‌های Elasticsearch  
- kibana-data : داده‌های Kibana

