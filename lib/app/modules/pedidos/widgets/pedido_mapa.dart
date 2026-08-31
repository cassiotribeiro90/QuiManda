import 'package:flutter/material.dart';
import '../../../../features/map/presentation/widgets/open_street_map_widget.dart';

class PedidoMapa extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String enderecoResumido;
  final bool isExpanded;

  const PedidoMapa({
    super.key,
    this.latitude,
    this.longitude,
    required this.enderecoResumido,
    this.isExpanded = false,
  });

  @override
  State<PedidoMapa> createState() => _PedidoMapaState();
}

class _PedidoMapaState extends State<PedidoMapa> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = false; // Garante que inicie recolhido
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.latitude == null || widget.longitude == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? 300 : 0, // Altura 0 quando recolhido
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: _isExpanded
                  ? OpenStreetMapWidget(
                      latitude: widget.latitude!,
                      longitude: widget.longitude!,
                      zoom: 18.0,
                      title: widget.enderecoResumido,
                    )
                  : const SizedBox.shrink(), // Lazy loading: só constrói se expandido
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍 Localização aproximada',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.enderecoResumido,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _toggleExpand,
            icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
