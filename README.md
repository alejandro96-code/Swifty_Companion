# Swifty_Companion

## Ejecucion para evaluacion (sin sudo)

La forma recomendada para el evaluador es Docker. Solo necesita tener Docker
Desktop o Docker Engine ya instalado y permiso para ejecutar Docker; no necesita
instalar Flutter, Dart, Chrome, Android Studio ni usar `sudo`.

```bash
git clone https://github.com/alejandro96-code/Swifty_Companion.git
cd Swifty_Companion
make docker-up
```

El comando pedira interactivamente el `CLIENT_ID` y el `CLIENT_SECRET` de tu
aplicacion OAuth de 42 y creara el archivo `.env` local. El secret no se
mostrara mientras lo escribes. Despues construira la imagen con Flutter,
instalara las dependencias Dart, levantara Flutter Web y abrira
<http://localhost:8080> en el navegador si el sistema lo permite.

Si necesitas regenerar las credenciales, ejecuta `make setup-env`.

Si el navegador no se abre automaticamente, visita <http://localhost:8080>.
Para detener el contenedor:

```bash
make docker-down
```

El primer arranque descarga la imagen de Flutter y puede tardar unos minutos.

El archivo `.env` se crea en la raiz y no se versiona.

`make docker-up` ejecuta Flutter Web en modo debug dentro del contenedor.
Flutter y sus dependencias se instalan dentro de la imagen Docker, no en el
sistema anfitrion.

## Ejecucion en Android Studio

Android Studio y el SDK de Android son necesarios únicamente para ejecutar la
aplicacion en un emulador o telefono Android. El proyecto se abre seleccionando
la carpeta `app/`, no la raiz del repositorio. Antes de pulsar Run, crea las
credenciales para Flutter:

```bash
cp app/.env.example app/.env
```

Después sustituye los valores de `app/.env` por tus credenciales de 42 y pulsa
`Pub get` en Android Studio. La aplicación incluye el permiso de Internet para
Android.

### Flutter local sin sudo

Si Flutter no esta instalado y no tienes permisos `sudo`, desde la raiz del
repositorio ejecuta:

```bash
cd Swifty_Companion
cd app
bash ../scripts/setup_flutter.sh
```

Desde la raiz del repositorio también puedes usar `make setup-flutter`.

El instalador descarga Flutter `3.22.1` en
`~/.local/share/flutter` y ejecuta `flutter pub get`. No modifica archivos del
sistema ni necesita permisos de administrador. Para que `flutter` quede
disponible en la terminal actual:

```bash
export PATH="$HOME/.local/share/flutter/bin:$PATH"
cd app
flutter devices
flutter run
```

También puedes ejecutar directamente sin modificar el `PATH`:

```bash
~/.local/share/flutter/bin/flutter run
```

En Android Studio, abre la carpeta `app/`, selecciona el emulador Android y
pulsa **Run**. Android Studio debe tener configurada la ruta de Flutter local
`~/.local/share/flutter`.

Si Android Studio ya está instalado, también puedes abrir el proyecto con:

```bash
make android-studio
```