# Swifty_Companion

## Evaluacion con Docker

Necesitas tener Docker instalado y en ejecucion. No hace falta instalar Flutter,
Dart, Chrome ni tener permisos sudo.

```bash
make docker-up
```

El comando pedira interactivamente el `CLIENT_ID` y el `CLIENT_SECRET` de tu
aplicacion OAuth de 42 y creara el archivo `.env` local. El secret no se
mostrara mientras lo escribes. Si necesitas regenerarlo, ejecuta
`make setup-env`.

Abre <http://localhost:8080> en el navegador. Para detenerlo, pulsa `Ctrl+C`.
El primer arranque descarga la imagen de Flutter y puede tardar unos minutos.

El archivo `.env` se crea en la raiz y no se versiona.

Para detener el contenedor:

```bash
make docker-down
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