#!/bin/bash

# 电商数据库设置脚本
# 安装必要的Python依赖并运行数据库设置

set -e

# 初始化python环境

# 写入bashrc文件进行初始化
echo "source /mnt/workspace/04-model-app/env-openmanus/bin/activate" >> /etc/bash.bashrc
source /mnt/workspace/04-model-app/env-openmanus/bin/activate


echo "=============================================="
echo "电商数据库设置脚本"
echo "=============================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本"
  echo "示例: sudo $0"
  exit 1
fi

# 检测操作系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif [ -f /etc/debian_version ]; then
    OS="Debian"
else
    echo "警告: 无法确定操作系统类型，假设为 Debian/Ubuntu 系列"
    OS="Debian"
fi

echo "检测到操作系统: $OS"

echo "安装数据库"

bash /mnt/workspace/02-tools/04-crt-db/install_postgres.sh

# 安装Python和pip
install_python() {
    if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
        echo "更新包索引..."
        apt update
        
        echo "安装 Python 和 pip..."
        apt install -y python3 python3-pip python3-dev python3-psycopg2
        
        # 安装Python包
        echo "安装Python依赖..."
        pip3 install psycopg2-binary
    else
        echo "不支持的操作系统: $OS"
        echo "此脚本仅支持 Debian/Ubuntu 系统"
        exit 1
    fi
}

# 运行数据库设置脚本
run_database_setup() {
    echo "运行电商数据库设置..."
    
    # 检查脚本是否存在
    if [ ! -f "/mnt/workspace/02-tools/04-crt-db/ecommerce_data_setup.py" ]; then
        echo "错误: 数据库设置脚本不存在"
        exit 1
    fi
    
    # 运行Python脚本
    python3 /mnt/workspace/02-tools/04-crt-db/ecommerce_data_setup.py
}

# 验证安装
verify_installation() {
    echo "验证电商数据库..."
    
    # 检查数据库是否存在
    sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw ecommerce_db && echo "✅ 电商数据库存在" || echo "❌ 电商数据库不存在"
    
    # 检查表是否存在
    TABLES=(users categories products orders order_items)
    for table in "${TABLES[@]}"; do
        if sudo -u postgres psql -d ecommerce_db -c "SELECT 1 FROM $table LIMIT 1;" >/dev/null 2>&1; then
            echo "✅ 表 $table 存在"
        else
            echo "❌ 表 $table 不存在"
        fi
    done
}

# 主执行流程
main() {
    echo "开始设置电商数据库..."
    
    # install_python
    # run_database_setup
    # verify_installation
    
    echo ""
    echo "=============================================="
    echo "电商数据库设置完成"
    echo "=============================================="
    echo "数据库连接信息:"
    echo "  Host: localhost"
    echo "  Port: 5432"
    echo "  Database: ecommerce_db"
    echo "  User: postgres"
    echo "  Password: postgres"
    echo ""
    echo "连接数据库命令:"
    echo "  sudo -u postgres psql -d ecommerce_db"
    echo ""
    echo "查看数据表示例:"
    echo "  sudo -u postgres psql -U postgres -d ecommerce_db -c 'SELECT * FROM products;'"
    # psql -h localhost -p 5432 -d ecommerce_db -U postgres -W postgres -c 'SELECT * FROM products;'
    # psql -h localhost -p 5432 -d toolbox_db -U toolbox_user -W my-password -c 'SELECT * FROM hotels;'
}

# 执行主函数
main


#!/bin/bash

# 删除已存在的用户和数据库（如果存在）
sudo -u postgres psql -c "DROP DATABASE IF EXISTS toolbox_db;"
sudo -u postgres psql -c "DROP USER IF EXISTS toolbox_user;"

# 创建用户和数据库
sudo -u postgres psql -c "CREATE USER toolbox_user WITH PASSWORD 'my-password';"
sudo -u postgres psql -c "CREATE DATABASE toolbox_db;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE toolbox_db TO toolbox_user;"
sudo -u postgres psql -c "ALTER DATABASE toolbox_db OWNER TO toolbox_user;"

# 连接到新创建的数据库并创建表及插入数据
sudo -u postgres psql -d toolbox_db -c "
CREATE TABLE IF NOT EXISTS hotels(
  id            INTEGER NOT NULL PRIMARY KEY,
  name          VARCHAR NOT NULL,
  location      VARCHAR NOT NULL,
  price_tier    VARCHAR NOT NULL,
  checkin_date  DATE    NOT NULL,
  checkout_date DATE    NOT NULL,
  booked        BIT     NOT NULL
);"

sudo -u postgres psql -d toolbox_db -c "ALTER TABLE hotels OWNER TO toolbox_user;"

sudo -u postgres psql -d toolbox_db -c "
INSERT INTO hotels(id, name, location, price_tier, checkin_date, checkout_date, booked)
VALUES
  (1, 'Hilton Basel', 'Basel', 'Luxury', '2024-04-22', '2024-04-20', B'0'),
  (2, 'Marriott Zurich', 'Zurich', 'Upscale', '2024-04-14', '2024-04-21', B'0'),
  (3, 'Hyatt Regency Basel', 'Basel', 'Upper Upscale', '2024-04-02', '2024-04-20', B'0'),
  (4, 'Radisson Blu Lucerne', 'Lucerne', 'Midscale', '2024-04-24', '2024-04-05', B'0'),
  (5, 'Best Western Bern', 'Bern', 'Upper Midscale', '2024-04-23', '2024-04-01', B'0'),
  (6, 'InterContinental Geneva', 'Geneva', 'Luxury', '2024-04-23', '2024-04-28', B'0'),
  (7, 'Sheraton Zurich', 'Zurich', 'Upper Upscale', '2024-04-27', '2024-04-02', B'0'),
  (8, 'Holiday Inn Basel', 'Basel', 'Upper Midscale', '2024-04-24', '2024-04-09', B'0'),
  (9, 'Courtyard Zurich', 'Zurich', 'Upscale', '2024-04-03', '2024-04-13', B'0'),
  (10, 'Comfort Inn Bern', 'Bern', 'Midscale', '2024-04-04', '2024-04-16', B'0')
ON CONFLICT (id) DO NOTHING;"