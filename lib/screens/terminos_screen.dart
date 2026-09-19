import 'package:flutter/material.dart';

class TerminosScreen extends StatelessWidget {
  const TerminosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos de Servicio'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TÍTULO =====
            Text(
              '📜 Términos de Servicio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Última actualización: 30 de agosto de 2026',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Divider(height: 30),

            // ===== 1. INFORMACIÓN GENERAL =====
            Text(
              '1. Información General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Responsable: Marlon Inclan\n'
              'País de operación: Costa Rica\n'
              'Moneda: Colón costarricense (₡ CRC)\n'
              'Plataforma: MiMarketplaceCR',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 2. USUARIOS =====
            Text(
              '2. Usuarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '2.1 Requisitos de edad\n'
              'Debes ser mayor de 18 años para registrarte y publicar productos.\n\n'
              '2.2 Responsabilidad de la cuenta\n'
              'Eres el único responsable de mantener la confidencialidad de tu cuenta.\n\n'
              '2.3 Información veraz\n'
              'La información proporcionada debe ser verdadera y actualizada.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 3. PUBLICACIÓN DE PRODUCTOS =====
            Text(
              '3. Publicación de Productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '3.1 Productos permitidos\n'
              'Productos legales que cumplan con las leyes de Costa Rica.\n\n'
              '3.2 Productos PROHIBIDOS\n'
              '❌ Celulares (iPhone, Samsung, Xiaomi, etc.)\n'
              '❌ Consolas de videojuegos (PlayStation, Xbox, Switch)\n'
              '❌ Computadoras y laptops\n'
              '❌ Armas de cualquier tipo\n'
              '❌ Animales vivos\n'
              '❌ Artículos eróticos o sexuales\n'
              '❌ Equipo médico\n'
              '❌ Productos ilegales o falsificados\n\n'
              '3.3 Requisitos de las publicaciones\n'
              '• Imágenes reales y del producto\n'
              '• Descripciones claras y no engañosas\n'
              '• Precio en colones (₡ CRC)\n'
              '• Indicar si es nuevo o usado\n\n'
              '3.4 Proceso de moderación\n'
              'Todos los productos pasan por revisión antes de ser publicados.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 4. VENDEDOR =====
            Text(
              '4. Responsabilidades del Vendedor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Eres responsable de la veracidad de la información.\n'
              '• El envío y entrega es tu responsabilidad.\n'
              '• Debes cumplir con las leyes de protección al consumidor.\n'
              '• Responde a los compradores de manera oportuna.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 5. COMPRADOR =====
            Text(
              '5. Responsabilidades del Comprador',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Verifica la información del producto antes de comprar.\n'
              '• La transacción es entre comprador y vendedor.\n'
              '• Las disputas deben resolverse directamente.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 6. COMPORTAMIENTO =====
            Text(
              '6. Comportamiento del Usuario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Está prohibido:\n'
              '❌ Publicar contenido ilegal u ofensivo.\n'
              '❌ Acosar o amenazar a otros usuarios.\n'
              '❌ Estafar o engañar.\n'
              '❌ Suplantar identidad.\n'
              '❌ Crear múltiples cuentas.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 7. MODERACIÓN =====
            Text(
              '7. Moderación y Suspensión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Nos reservamos el derecho de moderar contenido.\n'
              '• Podemos suspender cuentas que violen estos términos.\n'
              '• Puedes apelar una suspensión contactándonos.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 8. PROPIEDAD INTELECTUAL =====
            Text(
              '8. Propiedad Intelectual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Los productos deben ser originales.\n'
              '• No se permiten falsificaciones.\n'
              '• Las imágenes deben tener derechos de uso.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 9. PRIVACIDAD =====
            Text(
              '9. Privacidad y Protección de Datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Ley 8968 de Protección de Datos de Costa Rica.\n'
              '• Tus datos no se comparten con terceros.\n'
              '• Derechos ARCO: acceso, rectificación, cancelación, oposición.\n'
              '• Contacto: soporte@mimarketplacecr.com',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 10. RESPONSABILIDAD =====
            Text(
              '10. Limitación de Responsabilidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'MiMarketplaceCR actúa como intermediario.\n'
              'No somos responsables por:\n'
              '• Calidad o autenticidad de los productos.\n'
              '• Entrega o envío.\n'
              '• Transacciones económicas.\n'
              '• Daños derivados de las transacciones.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 11. LEY APLICABLE =====
            Text(
              '11. Ley Aplicable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Estos términos se rigen por las leyes de la República de Costa Rica.\n'
              'Cualquier disputa se resolverá en los tribunales de San José, Costa Rica.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // ===== 12. CONTACTO =====
            Text(
              '12. Contacto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Para consultas o reportes:\n'
              '📧 soporte@mimarketplacecr.com\n'
              '👤 Responsable: Marlon Inclan',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 30),

            // ===== ACEPTACIÓN =====
            Text(
              'Al registrarte en MiMarketplaceCR, aceptas cumplir con estos Términos de Servicio.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}