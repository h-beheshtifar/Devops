Prometheus and Grafana Monitoring Stack with cAdvisor, Node Exporter, 
=====================================================================

معرفی پروژه  
این پروژه شامل یک ستاپ مانیتورینگ  با استفاده از Prometheus، cAdvisor، Node Exporter و Grafana است که توسط Docker Compose اجرا می‌شود.  
Prometheus داده‌های مانیتورینگ را از cAdvisor و Node Exporter جمع‌آوری می‌کند و Grafana امکان مشاهده و تحلیل این داده‌ها را فراهم می‌کند.

---

ساختار دایرکتوری

prometheus/
├── docker-compose.yml
├── prometheus.yml
└── node_exporter.service

---

توضیح فایل‌ها  

- docker-compose.yml  
  فایل اصلی Docker Compose که سه سرویس زیر را تعریف می‌کند:  
  - cadvisor: جمع‌آوری اطلاعات عملکرد کانتینرهای داکر.  
  - prometheus: سیستم مانیتورینگ و ذخیره‌سازی metrics، با پیکربندی موجود در prometheus.yml.  
  - grafana: داشبورد گرافیکی برای نمایش داده‌های Prometheus، با یوزرنیم و پسورد پیش‌فرض prometheus.  
  همچنین یک volume به نام grafana-storage برای ذخیره داده‌های Grafana تعریف شده است.

- prometheus.yml  
  پیکربندی Prometheus که زمان‌بندی جمع‌آوری داده (scrape interval) را روی ۱۵ ثانیه تنظیم کرده و اهداف زیر را برای جمع‌آوری داده معرفی می‌کند:  
  - cAdvisor در آدرس cadvisor:8080  
  - Node Exporter روی آدرس IP مشخص شده (مثلاً 172.30.255.169:9100)

- node_exporter.service  
  فایل systemd unit برای اجرای Node Exporter روی ماشین میزبان.  
  - سرویس به کاربر node_exporter اجرا می‌شود.  
  - مسیر باینری Node Exporter در /usr/local/bin/node_exporter قرار دارد.

---

نحوه اجرا

1. اجرای سرویس‌ها با Docker Compose:

   docker-compose up -d

2. نصب و راه‌اندازی Node Exporter روی ماشین میزبان:

   - قرار دادن فایل باینری node_exporter در مسیر /usr/local/bin/.
   - کپی فایل node_exporter.service به دایرکتوری /etc/systemd/system/.
   - اجرای دستورات زیر:

     sudo systemctl daemon-reload
     sudo systemctl enable node_exporter
     sudo systemctl start node_exporter

3. دسترسی به داشبوردها:

   - Grafana: http://localhost:3000  
     (یوزرنیم و پسورد: prometheus/prometheus)

   - Prometheus: http://localhost:9090

   - cAdvisor: http://localhost:8081

---

نکات مهم

- IP مربوط به Node Exporter در فایل prometheus.yml را با IP ماشین میزبان خود تنظیم کنید.  
- داده‌ها هر ۱۵ ثانیه جمع‌آوری می‌شوند و می‌توانید داشبورد Grafana را برای نمایش بهتر داده‌ها شخصی‌سازی کنید.  
- برای امنیت بیشتر، پیشنهاد می‌شود دسترسی‌ها و یوزرنیم/پسوردها را در محیط تولید تغییر دهید.

