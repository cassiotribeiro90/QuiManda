import 'package:flutter/material.dart';
import '../widgets/open_street_map_widget.dart';
import '../../domain/entities/location_entity.dart';

class MapPage extends StatefulWidget {
  final LocationEntity initialLocation;
  final bool isSelectable;
  
  const MapPage({
    super.key,
    required this.initialLocation,
    this.isSelectable = false,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LocationEntity? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização'),
        actions: [
          if (widget.isSelectable && _selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          OpenStreetMapWidget(
            latitude: widget.initialLocation.latitude,
            longitude: widget.initialLocation.longitude,
            title: widget.initialLocation.title,
            zoom: 17,
            onTap: widget.isSelectable ? _onMapTap : null,
          ),
          if (widget.isSelectable && _selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Localização selecionada',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                      '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTap(double lat, double lng) {
    setState(() {
      _selectedLocation = LocationEntity(latitude: lat, longitude: lng);
    });
  }
}
