## install php (ondrje php)
### add ondrje ppa
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

### install php8.2
sudo apt install -y php8.2

### install php modules (Laravel Project)
sudo apt install -y php8.2-mysql php8.2-mbstring php8.2-exif php8.2-bcmath php8.2-gd php8.2-zip php8.2-dom
