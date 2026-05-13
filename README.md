# Swifty_Companion


Pasos para casa

cd /ruta/a/Swifty_Companion
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.1-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
rm flutter.tar.xz

./flutterw --version


cd app
../flutterw pub get
../flutterw run -d chrome