# Swifty_Companion

## Evaluacion con Docker

Necesitas tener Docker instalado y en ejecucion. No hace falta instalar Flutter,
Dart, Chrome ni tener permisos sudo.

```bash
make docker-up
```

Abre <http://localhost:8080> en el navegador. Para detenerlo, pulsa `Ctrl+C`.
El primer arranque descarga la imagen de Flutter y puede tardar unos minutos.

La aplicacion necesita las credenciales de una aplicacion OAuth de 42 para
consultar la API. Puedes exportarlas antes de arrancar:

```bash
export CLIENT_ID="tu_client_id"
export CLIENT_SECRET="tu_client_secret"
make docker-up
```

Tambien puedes crear `.env` en la raiz del proyecto a partir de `.env.example`;
ese archivo no se versiona.

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