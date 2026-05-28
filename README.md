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

### Estrategia offline-first (ContactoProvider)

1. **Al cargar contactos**: intenta `GET /Contactos` → si falla, lee desde SQLite.
2. **Al crear/editar/eliminar**: intenta operación en API → si falla, opera solo en SQLite.
3. **La UI siempre consume la lista en memoria** (`UnmodifiableListView`), que se mantiene sincronizada.

---

## 🔐 Autenticación

- El `LoginProvider` envía email y contraseña a `POST /Auth/login`.
- La API responde con un **token JWT** que se persiste en `SharedPreferences`.
- `ContactoApiService` recupera el token y lo inyecta automáticamente en cada petición.
- Al hacer logout se elimina el token y la bandera de sesión de `SharedPreferences`.

---

## 🧩 Arquitectura del proyecto

