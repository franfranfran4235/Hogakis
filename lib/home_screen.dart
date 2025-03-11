import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int productosHoy = 0;
  int productosAyer = 0;

  // Esta función carga las estadísticas desde Firestore en tiempo real
  Stream<DocumentSnapshot> _fetchEstadisticasStream() {
    return FirebaseFirestore.instance
        .collection('estadisticas')
        .doc('resumen')
        .snapshots(); // Usamos snapshots para escuchar cambios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HOGAKIS",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade100, Colors.blue.shade300],
              ),
            ),
          ),
          // Usamos StreamBuilder para escuchar en tiempo real
          Center(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _fetchEstadisticasStream(), // Escuchamos el stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Mostrar una animación mientras se cargan los datos
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  );
                } else if (snapshot.hasError) {
                  // Manejar el caso en que haya un error
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  // En caso de que no haya datos disponibles
                  return Center(child: Text('No hay datos disponibles'));
                }

                // Extraer datos del snapshot
                var data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data != null) {
                  productosHoy = data['productos']['productosHoy'] ?? 0;
                  productosAyer = data['productos']['productosAyer'] ?? 0;
                }

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Productos Vendidos",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildProductStats("Hoy", productosHoy, Colors.green),
                              _buildProductStats("Ayer", productosAyer, Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar el conteo de productos
  Widget _buildProductStats(String label, int count, Color color) {
    return Column(
      children: [
        Icon(
          label == "Hoy" ? Icons.today : Icons.history,
          color: color,
          size: 40,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        Text(
          "$count",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
