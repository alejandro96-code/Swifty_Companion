# Swifty_Companion

## Pasos para casa

```bash
cd /ruta/a/Swifty_Companion
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.1-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
rm flutter.tar.xz
./flutterw --version
```

## Como lanzarlo

```bash
cd app
../flutterw pub get
../flutterw run -d chrome
```

## Info

### Que es un widget en Flutter

- Todo es un widget: pantallas, textos, botones, layouts.
- Un widget es una clase que describe como se ve algo.

### StatelessWidget vs StatefulWidget

- `LoginScreen` es `StatelessWidget` porque no cambia con el tiempo.
- Usa `StatefulWidget` cuando necesitas estado (por ejemplo: texto del input, loading, errores).

### El metodo `build`

- Es el render de Flutter. Se ejecuta para dibujar la UI.
- Devuelve un arbol de widgets (layout → contenido).

### Como esta compuesto `LoginScreen`

- `Scaffold` es el contenedor base de una pantalla Material.
- `SafeArea` evita que el contenido choque con el notch o la barra superior.
- `Center` centra el contenido.
- `Text` es el equivalente a un `h1` si le das un `TextStyle` grande y bold.

### Estilos y H1

- Flutter no tiene etiquetas HTML; el tamano y peso se controla con `TextStyle`.
- Un H1 tipico seria `fontSize: 32` y `fontWeight: FontWeight.bold`.

### Ciclo de actualizacion

- En `StatelessWidget` no hay cambios internos.
- En `StatefulWidget`, cuando llamas a `setState()`, Flutter vuelve a ejecutar `build`.