#!/bin/bash

# 设置包信息
PACKAGE_NAME="my-ros2-package"
VERSION="1.0.0"
ARCH="amd64"
MAINTAINER="Your Name <your.email@example.com>"
DESCRIPTION="My ROS 2 package"
DEPENDENCIES="libpcl-dev, libopencv-dev"

# 创建目录结构
mkdir -p ${PACKAGE_NAME}/DEBIAN
mkdir -p ${PACKAGE_NAME}/usr/deb-test
mkdir -p ${PACKAGE_NAME}/lib/systemd/system

# 创建控制文件
cat <<EOL > ${PACKAGE_NAME}/DEBIAN/control
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: misc
Priority: optional
Architecture: ${ARCH}
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
 This is a ROS 2 package built using colcon.
EOL

# 创建 post-install 脚本
cat <<EOL > ${PACKAGE_NAME}/DEBIAN/postinst
#!/bin/bash
set -e
# Enable and start the service
systemctl enable my_ros2_service
systemctl start my_ros2_service
exit 0
EOL
chmod 755 ${PACKAGE_NAME}/DEBIAN/postinst

# 创建 systemd 服务文件
cat <<EOL > ${PACKAGE_NAME}/lib/systemd/system/my_ros2_service.service
[Unit]
Description=My ROS 2 Service
After=network.target

[Service]
ExecStart=/usr/deb-test/your_script.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOL

# 复制 install 目录内容
cp -r /home/gpu/deb_packages/install/* ${PACKAGE_NAME}/usr/deb-test/

# 设置文件权限
chmod -R 755 ${PACKAGE_NAME}/usr/deb-test/your_script.sh

# 创建 .deb 包
dpkg-deb --build ${PACKAGE_NAME}

# 提示包创建成功
echo "Package ${PACKAGE_NAME}.deb created successfully."
