README - Reverse Proxy with Nginx and Docker Compose

معرفی پروژه  
این پروژه شامل یک Reverse Proxy ساده با Nginx است که با استفاده از Docker Compose ساخته شده است.  
دو سرویس سایت (site1 و site2) با Nginx روی شبکه مشترک frontend اجرا می‌شوند و محتویات دایرکتوری shared-site را سرو می‌کنند.  
Reverse Proxy ترافیک را بین این دو سایت از طریق upstream load balancing توزیع می‌کند و با SSL محافظت شده است.

---

ساختار دایرکتوری  

revers-proxy/
├── proxy/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── reverse-proxy/
│   │   └── nginx.conf
│   ├── ssl.crt
│   └── ssl.key
└── web/
    ├── docker-compose.yml
    └── shared-site/
        └── index.html

---

توضیح فایل‌ها  

- web/docker-compose.yml  
  شامل دو سرویس site1 و site2 که از ایمیج nginx:alpine استفاده می‌کنند و دایرکتوری shared-site را به عنوان محتوای وب‌سایت در مسیر /usr/share/nginx/html قرار می‌دهند.  
  هر دو سرویس به شبکه خارجی به نام frontend متصل هستند.

- proxy/Dockerfile  
  بر پایه nginx:alpine ساخته شده و فایل پیکربندی Nginx (reverse-proxy/nginx.conf) و گواهی‌های SSL (ssl.crt و ssl.key) را درون کانتینر کپی می‌کند.

- proxy/docker-compose.yml  
  شامل سرویس reverse-proxy است که با Dockerfile ساخته می‌شود، روی پورت‌های 80 و 443 گوش می‌دهد و به شبکه frontend متصل است.

- proxy/reverse-proxy/nginx.conf  
  تنظیمات Nginx که دو سرور تعریف می‌کند:  
  - سرور روی پورت 80 که تمام درخواست‌ها را به نسخه HTTPS (پورت 443) ریدایرکت می‌کند.  
  - سرور روی پورت 443 که با SSL فعال شده و درخواست‌ها را به upstream به نام backend که شامل دو سرور site1 و site2 است پروکسی می‌کند.  
