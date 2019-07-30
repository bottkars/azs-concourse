echo "exporting az cli image"
mkdir /tmp/export-directory && cd /tmp/export-directory
cp ../ubuntu-image-to-package/metadata.json .
mkdir rootfs
tar -xvf ../ubuntu-image-to-package/rootfs.tar -C ./rootfs/ --exclude="dev/*"
cd rootfs
cd ../..
echo "Packaging ubuntu image"
tmp_version="17.04"
tar -czf "ubuntu/ubuntu-${tmp_version}.tgz" -C export-directory .
ls -la ubuntu