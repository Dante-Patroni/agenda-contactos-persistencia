# 📱 Agenda de Contactos (Flutter)

Aplicación móvil desarrollada en **Flutter** que permite gestionar una agenda de contactos con **conexión a API REST** (ASP.NET), **persistencia dual** (API + SQLite offline), **autenticación JWT** y gestión de estado con **Provider**.

---

## 🚀 Características principales

- 🔐 **Autenticación JWT** contra API REST ASP.NET (`POST /Auth/login`).
- 📇 **CRUD completo de contactos** sincronizado con API remota (`/Contactos`).
- 💾 **Estrategia offline-first**: intenta API; si falla, usa SQLite local como respaldo.
- 🗄️ **Persistencia local** con `SQLite` (caché offline y modo sin conexión).
- 🔑 **Token JWT persistente** en `SharedPreferences` para sesiones reutilizables.
- 🎨 **Diseño moderno** con degradados y estilo consistente.
- 🔍 **Búsqueda dinámica** de contactos en tiempo real.
- 📤 **Logout con confirmación** y limpieza de sesión.

---

## 📡 Conexión a API

La aplicación se conecta a una **API REST ASP.NET** corriendo en `http://localhost:5148/api`.

| Endpoint       | Método | Descripción                          |
|----------------|--------|--------------------------------------|
| `/Auth/login`  | POST   | Autenticación de usuario (email+pass)|
| `/Contactos`   | GET    | Obtener listado de contactos         |
| `/Contactos`   | POST   | Crear un nuevo contacto              |
| `/Contactos/{id}` | PUT | Actualizar un contacto existente     |
| `/Contactos/{id}` | DELETE | Eliminar un contacto               |

Todas las peticiones a `/Contactos` incluyen el token JWT en el header `Authorization: Bearer <token>`.

---

## 🧱 Capas del proyecto

```
lib/
├── main.dart                 # Punto de entrada, providers y rutas
├── models/
│   └── contacto.dart         # Entidad Contacto (toJson/fromJson, toMap/fromMap)
├── services/                 # 🌐 Capa de comunicación con la API
│   ├── api_client.dart       # Cliente HTTP centralizado (Dio)
│   ├── auth_api_service.dart # Login contra la API
│   └── contacto_api_service.dart  # CRUD de contactos remotos + JWT
├── providers/                # ⚛️ Capa de estado (ChangeNotifier)
│   ├── login_provider.dart   # Estado de autenticación
│   └── contacto_provider.dart # Estado de contactos (API + SQLite fallback)
├── database/
│   └── contacto_db_helper.dart # SQLite singleton (CRUD local)
├── pages/                    # 🖥️ Pantallas de la UI
│   ├── home_page.dart        # Pantalla de bienvenida
│   ├── login.dart            # Formulario de inicio de sesión
│   ├── listado_contactos.dart # Lista principal con búsqueda
│   ├── nuevo_contacto.dart   # Formulario de crear/editar contacto
│   └── inicio.dart           # Wrapper con logout
├── utils/                    # (disponible para utilidades)
└── widgets/                  # (disponible para widgets reutilizables)
```

---

## 🔄 Flujo de datos

```
UI (Pages)
  │  lee/escribe mediante Provider
  ▼
Providers (ChangeNotifier)
  │  LoginProvider  ───> AuthApiService  ───> ApiClient.dio ───> API ASP.NET
  │  ContactoProvider ───> ContactoApiService ───> ApiClient.dio ───> API ASP.NET
  │                    └──> ContactoDBHelper ───> SQLite (fallback offline)
  ▼
Servicios HTTP (Dio)
  └── ApiClient (instancia única con base URL, timeouts y headers JSON)
```

### Estrategia offline-first y Sincronización Automática (ContactoProvider)

1. **Al cargar contactos**: intenta `GET /Contactos` → si falla, lee desde SQLite.
2. **Al crear/editar/eliminar**: intenta operación en API → si falla, guarda el registro en SQLite marcado como **"Pendiente de Sincronización"** (`is_sync = 0`).
3. **Sincronización Transparente**: Al recuperar la conexión o presionar el botón de "Refrescar", la app detecta automáticamente los contactos pendientes en SQLite y los sube a la API antes de descargar la lista actualizada, asegurando **cero pérdida de datos**.
4. **La UI siempre consume la lista en memoria** (`UnmodifiableListView`), que se mantiene sincronizada en tiempo real.

---

## 🔐 Autenticación

- El `LoginProvider` envía email y contraseña a `POST /Auth/login`.
- La API responde con un **token JWT** que se persiste en `SharedPreferences`.
- `ContactoApiService` recupera el token y lo inyecta automáticamente en cada petición.
- Al hacer logout se elimina el token y la bandera de sesión de `SharedPreferences`.

---

## 🧩 Arquitectura del proyecto

---

## ⚙️ Instrucciones de Ejecución

Para evaluar este proyecto correctamente, se requiere tener ejecutando el backend en ASP.NET y posteriormente inicializar esta aplicación en Flutter.

### Paso 1: Configurar el Backend (ASP.NET)
1. Asegúrese de inicializar la API REST de Contactos en su entorno local.
2. Verifique que la API se esté ejecutando en el puerto esperado. Por defecto, esta app de Flutter apunta a `http://localhost:5148/api`. 
3. *(Si su API usa otro puerto, deberá modificar la URL en el archivo `lib/services/api_client.dart`).*

### Paso 2: Ejecutar la App (Flutter)
1. Abra una terminal apuntando a la raíz de este proyecto (`agenda_contactos`).
2. Instale las dependencias del proyecto ejecutando:
   ```powershell
   flutter pub get
   ```
3. Ejecute la aplicación seleccionando su plataforma de preferencia (Windows o Emulador Android):
   **Notas importantes para la conexión a la API:**
*   Asegúrate de que tu **servidor API de ASP.NET Core** esté en ejecución.
*   En tu `Program.cs` del backend, debes tener `builder.WebHost.UseUrls("http://0.0.0.0:5148");` para permitir conexiones desde otras IPs.
*   Si el firewall de tu PC está activo, puede que tengas que añadir una regla de entrada para permitir conexiones TCP al puerto `5148`.

---

### Para correr como aplicación nativa de escritorio en Windows:

La aplicación Flutter se conectará automáticamente a `http://localhost:5148/api`.
```powershell
flutter run -d windows
```

### Para correr en un emulador o dispositivo físico de Android:

La aplicación Flutter se conectará automáticamente a `http://IP e tu máquina:5148/api`.
**¡IMPORTANTE!** Si la dirección IP de tu máquina de desarrollo cambia, deberás actualizarla en el archivo `lib/services/api_client.dart`.
*   Asegúrate de que tu dispositivo Android (emulador o físico) y tu PC estén en la misma red Wi-Fi.

```powershell

### 💡 Prueba sugerida para la funcionalidad "Offline-First":
1. Inicie sesión en la app y asegúrese de que la lista de contactos carga correctamente.
2. **Apague o detenga el servidor ASP.NET** (o desconecte el internet del emulador).
3. Cree un **nuevo contacto** desde la aplicación. Verá que se guarda localmente gracias a SQLite.
4. **Vuelva a iniciar el servidor ASP.NET**.
5. Presione el botón **Refrescar 🔄** en la esquina superior derecha de la app.
6. La aplicación detectará el contacto pendiente, lo enviará silenciosamente a la base de datos central de SQL Server y refrescará la vista. ¡Cero pérdida de datos!
