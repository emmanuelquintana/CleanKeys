# CleanKeys 🧼⌨️

[![macOS Version](https://img.shields.io/badge/platform-macOS-blue.svg)](https://developer.apple.com/macos/)
[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**CleanKeys** es una utilidad nativa y elegante para macOS escrita en Swift que te permite bloquear temporalmente el teclado y las pulsaciones del ratón/trackpad. De este modo, puedes limpiar tu teclado físico sin preocuparte por pulsar teclas accidentalmente, abrir aplicaciones no deseadas o borrar archivos importantes.

---

## 🚀 Descarga Directa

Puedes descargar la última versión lista para usar haciendo clic en el siguiente botón:

[<img src="https://img.shields.io/badge/Descargar-CleanKeys.dmg-blue?style=for-the-badge&logo=apple&logoColor=white" alt="Descargar CleanKeys" width="220">](https://github.com/emmanuelquintana/CleanKeys/raw/main/CleanKeys.dmg)

*(Si el botón no funciona, usa este [enlace directo de descarga](https://github.com/emmanuelquintana/CleanKeys/raw/main/CleanKeys.dmg))*

---

## ✨ Características

- 🔒 **Bloqueo Completo del Teclado:** Captura e intercepta de forma segura todas las teclas presionadas en el sistema.
- ⏳ **Tiempos de Bloqueo Ajustables:** Bloquea por 30 segundos, 1 minuto, 3 minutos, 5 minutos o 10 minutos directamente desde la interfaz o la barra de menús.
- 🖥️ **Pantalla de Limpieza Overlay (Opcional):** Muestra un fondo elegante con estilo *glassmorphism* que atenúa tu pantalla mientras limpias.
- 🖱️ **Bloqueo de Clics (Opcional):** Permite bloquear también los clics del mouse/trackpad para una limpieza total de laptops.
- 🎵 **Sonido de Confirmación:** Beep de confirmación acústica al bloquear y desbloquear.
- 🍏 **Icono en la Barra de Menús:** Controla el estado del bloqueo y accede rápidamente a los ajustes con un menú extra dinámico.
- ⌨️ **Atajo de Desbloqueo Seguro:** Desbloquea en cualquier momento usando el atajo configurable (por defecto `Control + Option + Command + L`).

---

## 🛠️ Requisitos e Instalación

### Requisitos
- macOS Ventura (13.0) o superior.

### Instrucciones de Instalación
1. **Descarga el DMG:** Haz clic en el botón de [Descarga Directa](https://github.com/emmanuelquintana/CleanKeys/raw/main/CleanKeys.dmg).
2. **Instala la App:** Abre el archivo `CleanKeys.dmg` y arrastra `CleanKeys.app` a tu carpeta de **Aplicaciones**.
3. **Abre la App:** Ejecuta CleanKeys desde tus Aplicaciones o Launchpad.
4. **Configura los Permisos de Accesibilidad (Crucial):**
   - CleanKeys necesita permisos de **Accesibilidad** para poder interceptar las teclas a nivel de sistema.
   - La primera vez que lo ejecutes o al intentar bloquear, macOS te solicitará estos permisos.
   - Ve a **Configuración del Sistema** > **Privacidad y Seguridad** > **Accesibilidad**, y asegúrate de activar la casilla para **CleanKeys**.

> [!NOTE]  
> macOS requiere estos permisos para cualquier app que capture entradas del teclado de manera global. CleanKeys **no almacena ni transmite** ninguna de tus pulsaciones; su único propósito es ignorar los eventos de entrada mientras limpias.

---

## 📖 Cómo Usar

1. Abre **CleanKeys**. Verás una ventana moderna con opciones y un icono de teclado en la barra de menús.
2. Selecciona la duración deseada utilizando los botones rápidos (por ejemplo, `30 s`, `1 min`, `5 min`).
3. Haz clic en el botón **Bloquear teclado** para activar el modo limpieza.
4. Si necesitas desbloquear la Mac antes de que termine el temporizador, presiona el atajo de teclado:
   - **Atajo por defecto:** `⌃⌥⌘L` (`Control + Option + Command + L`)
5. Puedes acceder a las opciones de duración y ajustes rápidos directamente haciendo clic derecho o clic izquierdo sobre el icono de CleanKeys en la **barra de menús**.

---

## ⚙️ Ajustes Rápidos

Desde la interfaz principal puedes activar o desactivar:
- **Mostrar pantalla de limpieza:** Muestra el overlay visual en pantalla completa.
- **Atenuar pantalla durante limpieza:** Reduce el brillo del overlay visual.
- **Bloquear clics del mouse/trackpad:** Deshabilita clicks físicos si deseas limpiar la superficie de tu laptop o mouse de forma segura.

---

## 💻 Desarrollo y Compilación

Si deseas compilar la aplicación tú mismo desde el código fuente:

1. Clona el repositorio:
   ```bash
   git clone https://github.com/emmanuelquintana/CleanKeys.git
   cd CleanKeys/CleanKeys
   ```
2. Abre `CleanKeys.xcodeproj` en Xcode.
3. Compila y ejecuta la aplicación (`Cmd + R`).

---

## 👤 Autor

Desarrollado con ❤️ por **Emmanuel Quintana**.
- GitHub: [@emmanuelquintana](https://github.com/emmanuelquintana)
