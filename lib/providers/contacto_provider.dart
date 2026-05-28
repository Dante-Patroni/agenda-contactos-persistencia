import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:agenda_contactos/models/contacto.dart';
import 'package:agenda_contactos/database/contacto_db_helper.dart';
import 'package:agenda_contactos/services/contacto_api_service.dart';

/// Administrador de estado para la colección de contactos.
///
/// Responsabilidades:
/// - Sincronizar la lista en memoria con SQLite a través de `ContactoDBHelper`.
/// - Exponer operaciones CRUD a la UI y notificar cambios.
/// - Gestionar estados de carga y errores no fatales (con `debugPrint`).
class ContactoProvider extends ChangeNotifier {
  final List<Contacto> _contactos = [];
  UnmodifiableListView<Contacto> get contactos => UnmodifiableListView(_contactos);

  final ContactoDBHelper _dbHelper = ContactoDBHelper.instance;
  final ContactoApiService _apiService = ContactoApiService();
  bool isLoading = true;

  // 🚀 Se llama automáticamente al crear el provider
  ///Crea la base de datos si no está creada 0 carga los contactos si esta
  ContactoProvider() {
    _loadContactos();
  }

 /// Carga y sincroniza la lista de contactos implementando una estrategia de caché local.
  /// 
  /// El flujo operativo prioritario intenta consumir los datos más recientes desde el 
  /// servicio web remoto (API). Si la respuesta es exitosa, se purga el estado de la memoria
  /// reactiva y el almacenamiento persistente local (SQLite) para insertar los nuevos registros.
  /// 
  /// Si ocurre un fallo crítico de red o indisponibilidad del servidor, se captura la excepción
  /// para ejecutar un mecanismo de contingencia (*fallback*) que recupera los datos históricos
  /// guardados de manera local en SQLite.
  /// 
  /// Controla de forma segura el ciclo de vida del indicador de carga [isLoading] y notifica
  /// a los suscriptores ([notifyListeners]) al inicio y al final del procesamiento.
  Future<void> _loadContactos() async {
    // Establece el estado de inicialización del proceso asíncrono y notifica a la UI
    isLoading = true;
    notifyListeners();

    try {
      // 🔥 Intentar API: Petición HTTP al servidor remoto para obtener datos en tiempo real
      final data = await _apiService.obtenerContactos();

      // 🔥 Limpiar memoria: Remueve los contactos antiguos de la lista reactiva
      _contactos.clear();

      // 🔥 Cargar memoria: Inserta la colección actualizada de contactos en el estado actual
      _contactos.addAll(data);

      // 🔥 Refrescar SQLite caché: Vacía la tabla local para sincronizar de manera limpia
      await _dbHelper.deleteAllContactos();

      // Itera recursivamente sobre cada contacto remoto para construir el respaldo local offline
      for (var contacto in data) {
        await _dbHelper.insertContacto(contacto);
      }

      debugPrint("✅ Contactos cargados desde API");

    } catch (e) {
      // Flujo alternativo en caso de pérdida de conexión o error del lado del servidor
      debugPrint("⚠ API no disponible, usando SQLite local: $e");

      // 🔥 Fallback local: Consulta el almacén de datos SQLite interno del dispositivo
      final data = await _dbHelper.getContactos();

      // Asegura que la UI muestre exclusivamente los registros locales recuperados
      _contactos.clear();
      _contactos.addAll(data);
    }

    // Finalización del estado asíncrono y actualización definitiva del árbol de componentes
    isLoading = false;
    notifyListeners();
  }

  // --- CRUD conectados con SQLite ---

  /// Registra un nuevo contacto aplicando una estrategia de persistencia dual con tolerancia a fallos.
  /// 
  /// Intenta de forma síncrona subir el [contacto] al servidor remoto mediante la API. 
  /// Si la operación es exitosa, guarda inmediatamente una copia en el almacenamiento 
  /// local (SQLite) para mantener consistencia y sincroniza la UI llamando a [_loadContactos].
  /// 
  /// En caso de que ocurra una excepción (como la pérdida de conectividad a internet), 
  /// el método intercepta el error y activa un *fallback offline*: el contacto se almacena 
  /// localmente en SQLite para asegurar que el usuario no pierda su información, permitiendo 
  /// que esté disponible en el entorno local de inmediato.
  Future<void> addContacto(Contacto contacto) async {
    try {
      // 🔥 Crear en API: Envío síncrono del nuevo recurso al servidor remoto
      await _apiService.crearContacto(contacto);

      // 🔥 Guardar también en SQLite: Respaldo local inmediato tras confirmación del servidor
      await _dbHelper.insertContacto(contacto);

      // 🔥 Refrescar lista desde API: Re-sincroniza el estado global de la aplicación
      await _loadContactos();

      debugPrint("✅ Contacto creado correctamente");

    } catch (e) {
      debugPrint("❌ Error creando contacto de forma remota: $e");

      // 🔥 Fallback offline: Si el servidor falla o no hay red, se prioriza la experiencia de usuario
      // persistiendo el registro localmente para una futura sincronización.
      await _dbHelper.insertContacto(contacto);

      // Refresca la lista local en memoria para que el usuario visualice el contacto recién creado
      await _loadContactos();
    }
  }

 /// Elimina un contacto del sistema aplicando una estrategia de sincronización híbrida.
  /// 
  /// Si el [contacto] no posee un identificador válido ([contacto.id] es `null`), la operación
  /// aborta inmediatamente para evitar peticiones inconsistentes.
  /// 
  /// El método intenta en primera instancia eliminar el recurso de forma remota a través de la API.
  /// Tras la confirmación del servidor, remueve de forma idéntica el registro del almacenamiento local (SQLite).
  /// 
  /// Si la API no está accesible (entorno offline o error de red), intercepta la excepción como un mecanismo de 
  /// contingencia para ejecutar el *fallback offline*, eliminando el registro únicamente de SQLite.
  /// 
  /// Al finalizar cualquiera de los flujos de persistencia, actualiza de forma síncrona el estado de la lista 
  /// en memoria (`_contactos`) y emite [notifyListeners] para forzar el re-renderizado inmediato de la interfaz de usuario.
  Future<void> removeContacto(Contacto contacto) async {
    // Validación de seguridad para evitar operaciones sobre registros inexistentes o mal formados
    if (contacto.id == null) return;

    try {
      // 🌐 Intentar borrar en API: Petición HTTP DELETE al servidor remoto
      await _apiService.eliminarContacto(contacto.id!);

      // 💾 Borrar también en SQLite: Consistencia de datos locales tras la baja exitosa en el servidor
      await _dbHelper.deleteContacto(contacto.id!);

      debugPrint("✅ Contacto eliminado desde API y SQLite");

    } catch (e) {
      // Control de excepciones por fallos de conectividad o indisponibilidad del servicio web
      debugPrint("⚠ API no disponible, eliminando solo local: $e");

      // OFFLINE → Borrado preventivo en SQLite para asegurar la fluidez de la experiencia de usuario local
      await _dbHelper.deleteContacto(contacto.id!);
    }

    // Actualización del estado reactivo en memoria filtrando por el identificador del elemento removido
    _contactos.removeWhere((c) => c.id == contacto.id);
    
    // Dispara la reactivación de los widgets escuchando este Provider/ChangeNotifier
    notifyListeners();
  }

  /// Actualiza la información de un contacto aplicando una estrategia de sincronización híbrida con soporte offline.
  /// 
  /// El método intenta enviar en primera instancia las modificaciones del [contacto] al servidor remoto
  /// mediante la API. Si la petición web es exitosa, se replica el mismo cambio de forma persistente
  /// en la base de datos local (SQLite) para mantener la consistencia entre ambos entornos.
  /// 
  /// Si el servicio remoto no está disponible (por ejemplo, por pérdida de conectividad de red),
  /// se captura la excepción para ejecutar el *fallback offline*, aplicando la actualización
  /// únicamente en SQLite para asegurar que los cambios del usuario no se pierdan.
  /// 
  /// Al finalizar la persistencia, se localiza el elemento dentro del listado reactivo en memoria (`_contactos`).
  /// Si se encuentra el índice, se reemplaza el objeto directamente y se emite [notifyListeners]; 
  /// en caso contrario, se fuerza una recarga estructural completa invocando a [_loadContactos].
  Future<void> updateContacto(Contacto contacto) async {
    try {
      // 🌐 Intentar actualizar en API: Envío de las modificaciones al servidor remoto
      await _apiService.actualizarContacto(contacto);

      // 💾 Actualizar SQLite: Espejado de datos local tras confirmación exitosa de la API
      await _dbHelper.updateContacto(contacto);

      debugPrint("✅ Contacto actualizado en API y SQLite");

    } catch (e) {
      // Intercepción de fallos de infraestructura o red para garantizar resiliencia
      debugPrint("⚠ API no disponible, actualizando solo local: $e");

      // OFFLINE → Actualización preventiva en SQLite para mantener la fluidez operativa del usuario en local
      await _dbHelper.updateContacto(contacto);
    }

    // 🔄 Actualizar memoria: Búsqueda del elemento modificado mediante su identificador único
    final index = _contactos.indexWhere((c) => c.id == contacto.id);

    if (index != -1) {
      // Reemplazo eficiente en memoria del elemento modificado en el índice localizado
      _contactos[index] = contacto;

      // Notificación inmediata a los widgets escuchando el ChangeNotifier para redibujar la UI
      notifyListeners();
    } else {
      // Flujo de contingencia en caso de desincronización de índices: recarga forzada del estado global
      await _loadContactos();
    }
  }

  // --- Generar contactos demo (para pruebas) ---
  /// Crea un set de datos dummy para acelerar pruebas manuales.
  Future<void> generarContactosDemo() async {
    final contactosDemo = [
      Contacto(
        nombre: "Juan",
        apellido: "Pérez",
        telefono: "123456",
        email: "juanperez@gmail.com",
        direccion: "Avenida Siempre Viva 123",
        genero: "M",
      ),
      Contacto(
        nombre: "María",
        apellido: "González",
        telefono: "234567",
        email: "mariagonzalez@gmail.com",
        direccion: "Calle Falsa 456",
        genero: "F",
      ),
    ];

    for (var c in contactosDemo) {
      await _dbHelper.insertContacto(c);
    }
    await _loadContactos();
  }
}
