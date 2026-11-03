# HabitQuest v1 — PWA de hábitos y gamificación

Una aplicación para Windows, Android y otros dispositivos compatibles con PWA. Funciona sin XAMPP, sin Apache y sin servidor propio. Tiene modo local sin conexión y sincronización opcional con Supabase.

## Funciones incluidas

- Dashboard con progreso diario, mensual, XP y nivel.
- Alta y edición de hábitos, calendario mensual con registros por día.
- Racha de días completos y seis logros desbloqueables.
- Almacenamiento local en **IndexedDB** (persiste entre cierres).
- Sincronización mediante **Supabase Auth + Postgres** con políticas RLS.
- Uso offline tras abrir la app una vez con Internet y tenerla instalada.
- Importación y exportación de respaldos JSON.
- PWA instalable: manifest, iconos y service worker.

## 1. Probar localmente (sin XAMPP)

Es necesario servir la PWA mediante HTTP local para habilitar Service Workers. En la carpeta donde está `index.html`, ejecuta:

```bash
python -m http.server 8080
```

Y abre `http://localhost:8080`. Este servidor es **solo para desarrollo y pruebas**. No lo necesitas después de publicar e instalar la aplicación desde una URL HTTPS.

Si Python no está disponible, puedes utilizar la extensión *Live Server* de VS Code durante las pruebas.

## 2. Publicar sin mantener un computador encendido

Opción sencilla: **GitHub Pages**.

1. Crea un repositorio en GitHub para HabitQuest.
2. Sube el **contenido** de esta carpeta (index.html, app.js, styles.css, manifest, sw.js, icons).
3. Activa Settings → Pages → Deploy from branch → main / root.
4. Abre la URL HTTPS que te asigne GitHub Pages desde Windows y Android.
5. En Chrome o Edge, usa **Instalar aplicación** o **Agregar a pantalla de inicio**.

También funciona en un alojamiento estático HTTPS como Netlify o Cloudflare Pages. Ni la aplicación ni la sincronización necesitan XAMPP.

## 3. Activar sincronización entre dispositivos

1. Crea un proyecto en https://supabase.com.
2. Ve a **SQL Editor** y ejecuta el archivo `schema.sql` completo sobre el proyecto nuevo. Las políticas RLS aíslan los registros de cada cuenta.
3. En Supabase → Project Settings / API Keys, copia la **Project URL** (`https://...supabase.co`) y la clave **publishable** (`sb_publishable_...`) o la **anon** antigua.
4. En HabitQuest abre **Configuración y nube** e introduce esos dos valores, luego presiona **Guardar conexión**.
5. Crea tu cuenta con correo y contraseña. Si Supabase exige confirmación de correo, confírmala antes de iniciar sesión. Configura el **Site URL** de Auth en Supabase con el dominio HTTPS de tu app, para enlaces de correo.
6. Inicia sesión y presiona sincronizar. Repite la configuración de URL/clave en tu otro dispositivo y usa **la misma cuenta**.

**Jamás** introduzcas la clave `service_role` ni una secret key en el navegador. La clave pública debe utilizarse junto a las políticas RLS presentes en `schema.sql`.

## 4. Cómo se sincronizan los datos

- La información se guarda al instante en IndexedDB, incluso sin Internet.
- Cuando hay sesión y conectividad, se comparan los registros locales con Supabase por identificador y marca de actualización. Se suben los cambios locales más recientes y se descargan registros remotos más recientes.
- La primera vez que inicias sesión, tus hábitos locales se copian a tu espacio en la nube.
- La sincronización sucede al marcar hábitos, iniciar sesión, pulsar ↻ y recuperar Internet.
- **Limitación v1:** no hay actualizaciones push entre dispositivos abiertos simultáneamente. Pulsa ↻ para obtener cambios del otro dispositivo. Si editas el mismo registro offline en dos dispositivos, se conserva el valor con `updated_at` más reciente (según los relojes de los equipos). No es un sistema de resolución de conflictos robusto.

## 5. Recomendaciones de seguridad

- Configura un dominio HTTPS para publicar. El modo offline y la instalación requieren contextos seguros (HTTPS o localhost).
- La base de datos usa RLS; deja las políticas activadas y nunca uses credenciales administrativas en la app.
- No subas contraseñas, `service_role`, secret keys ni otros secretos al repositorio.
- El almacenamiento local y las sesiones del navegador pueden desaparecer si se borran datos del sitio. Mantén sincronización y respaldos.
- En esta v1 no se han integrado notificaciones push ni recordatorios automáticos.

## Estructura

- `index.html`: interfaz y componentes.
- `styles.css`: diseño oscuro responsive.
- `app.js`: lógica de hábitos, IndexedDB, estadísticas, autenticación y sincronización.
- `sw.js`: recursos de la PWA cacheados para uso offline.
- `manifest.webmanifest` + `icons/`: instalación.
- `schema.sql`: esquema Postgres y políticas RLS de Supabase.

**Estado:** prototipo funcional local. Sin credenciales reales de un proyecto Supabase, la sincronización en vivo no se ha podido validar end-to-end. Prueba la autenticación y la sincronización en tu proyecto antes de usarla como única copia de tus datos.


## Nuevo en HabitQuest v1.2: Diario emocional
- Abre **Diario emocional** desde el menú. Selecciona una emoción y escribe una nota opcional (máximo 2.000 caracteres).
- Puedes registrar y editar días pasados, consultar el calendario emocional y la bitácora.
- Los datos se guardan localmente en IndexedDB, dentro del mismo perfil que los hábitos. Se incluyen en respaldos JSON e importaciones.
- **IMPORTANTE:** si ya creaste las tablas en Supabase para la versión 1.0, ejecuta el bloque que comienza en `-- HabitQuest v1.2` del archivo `schema.sql` usando SQL Editor. Si es una instalación nueva, ejecuta el archivo entero. Sin esa tabla la sincronización no podrá completarse.
- No des puntos ni penalizaciones por las emociones: todos los estados son válidos. Los registros son información personal; evita usar dispositivos compartidos o deja cerrada tu sesión. La sincronización depende de HTTPS y de las políticas RLS del proyecto Supabase.
- Si ya instalaste la PWA, vuelve a publicarla con estos archivos y recarga la aplicación; el Service Worker tiene una nueva versión de caché.


## Nuevo en 1.2: Mi evolución
- Vista **Mi evolución** con filtros de 14, 30 y 90 días.
- Línea de tiempo que permite abrir cada registro emocional.
- Distribución y frecuencia de los 8 estados emocionales.
- Comparaciones descriptivas entre hábitos marcados y estados elegidos en el mismo día (mínimo 3 registros por grupo).
- Resumen de registros y exportación CSV del diario emocional.
- Navegación inferior adaptada a 5 secciones para móviles.

**Privacidad:** los comentarios emocionales están en IndexedDB local sin cifrado adicional y, con la sincronización habilitada, en Supabase bajo RLS. No es apropiado usar equipos compartidos sin protección. Los archivos exportados tampoco están cifrados. No incluyas una clave `service_role` en la configuración cliente: usa solamente la clave pública `anon` o `publishable`.

## Instalar en Android y Windows (sin XAMPP)
1. Publica *el contenido de esta carpeta* en GitHub Pages, Cloudflare Pages u otro servicio HTTPS estático. No abras `index.html` como archivo local para la instalación.
2. En **Android** abre la URL HTTPS con Chrome, toca `⋮` y elige `Instalar aplicación` o `Agregar a pantalla principal`.
3. En **Windows** abre la misma URL con Edge, ve a `⋯ > Aplicaciones > Instalar este sitio como una aplicación` (o utiliza el icono de instalación en la barra de dirección).
4. Configura **Supabase > SQL Editor** ejecutando `schema.sql` en un proyecto nuevo (o `migracion_v1_a_v1_1.sql` si ya tenías la versión 1). Asegúrate de haber configurado la autenticación por correo.
5. En ambos dispositivos abre `Configuración y nube`, escribe el mismo **Project URL** y la **clave pública**, inicia sesión con el mismo correo y pulsa sincronizar.
6. Los registros se conservan localmente sin conexión y se sincronizan al volver a conectarte, siempre que la cuenta y Supabase estén correctamente configurados. En sincronizaciones simultáneas de varios dispositivos puede haber conflictos; descarga respaldos periódicos.

**Nota:** GitHub Pages aloja la interfaz, no los datos. Para el guardado compartido se usa Supabase. La PWA no constituye un APK nativo ni se distribuye desde Play Store.
