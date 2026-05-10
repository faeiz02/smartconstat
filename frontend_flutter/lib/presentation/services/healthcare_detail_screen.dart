import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/api_service_features.dart';
import '../../data/models/avis_model.dart';
import '../../core/storage/secure_storage_service.dart';

class HealthcareDetailScreen extends StatefulWidget {
  final Map<String, dynamic> professional;

  const HealthcareDetailScreen({super.key, required this.professional});

  @override
  State<HealthcareDetailScreen> createState() => _HealthcareDetailScreenState();
}

class _HealthcareDetailScreenState extends State<HealthcareDetailScreen>
    with SingleTickerProviderStateMixin {
  LatLng? _userLocation;
  final LatLng _doctorLocation = const LatLng(36.8065, 10.1815);

  List<Avis> _avisList = [];
  bool _isLoadingReviews = true;
  double _currentRating = 0.0;
  int _currentReviewCount = 0;
  int? _currentUserId;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _currentRating = (widget.professional["rating"] ?? 0.0).toDouble();
    _currentReviewCount = widget.professional["reviewCount"] ?? 0;

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _determinePosition();
    _fetchAvis();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvis() async {
    // Get current user ID from secure storage
    _currentUserId = await SecureStorageService.getUserId();

    final id = widget.professional['id'];
    if (id != null) {
      final rawId = id is int ? id : int.tryParse(id.toString()) ?? 0;
      final reviewsRaw = await ApiServiceFeatures.getAvis(rawId);
      if (mounted) {
        setState(() {
          _avisList = reviewsRaw.map((e) => Avis.fromJson(e)).toList();
          _isLoadingReviews = false;
          _currentReviewCount = _avisList.length;
          if (_avisList.isNotEmpty) {
            double avg =
                _avisList.map((a) => a.rating).reduce((a, b) => a + b) /
                    _avisList.length;
            _currentRating = (avg * 10).round() / 10.0;
          }
          // Sort: user's own review first, then by date
          if (_currentUserId != null) {
            _avisList.sort((a, b) {
              if (a.userId == _currentUserId && b.userId != _currentUserId)
                return -1;
              if (b.userId == _currentUserId && a.userId != _currentUserId)
                return 1;
              // For same ownership status, keep original order (newest first)
              return 0;
            });
          }
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() =>
            _userLocation = LatLng(position.latitude, position.longitude));
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  String _getCategory() => widget.professional["type"] ?? "Spécialité inconnue";
  String _getName() => widget.professional["name"] ?? "Nom inconnu";
  String _getAddress() =>
      widget.professional["address"] ?? "Adresse non spécifiée";
  String _getPhone() => widget.professional["phone"] ?? "";
  String _getDistance() => widget.professional["distanceStr"] ?? "";
  String _getBio() =>
      widget.professional["bio"] ??
      "Aucune information supplémentaire disponible.";

  Future<void> _launchPhone() async {
    final phone = _getPhone().replaceAll(" ", "");
    if (phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(),
                    const SizedBox(height: 20),
                    _buildRatingBar(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildReviewsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launchPhone,
        backgroundColor: AppColors.tealSoins,
        elevation: 6,
        icon: const Icon(Icons.phone, color: Colors.white),
        label: const Text("Appeler",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ─── SLIVER APP BAR WITH MAP ───
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.tealSoins,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
          ),
          onPressed: () => _showFullScreenMap(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _doctorLocation,
                initialZoom: 14.0,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.smartconstat.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _doctorLocation,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.redDanger.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.location_on,
                              color: AppColors.redDanger, size: 40),
                        ),
                      ),
                    ),
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.scaffold,
                      AppColors.scaffold.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER INFO ───
  Widget _buildHeaderInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.tealSoins, Color(0xFF2DD4BF)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: AppColors.tealSoins.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Icon(
              _getCategory().contains("Clinique")
                  ? Icons.local_hospital_rounded
                  : Icons.person_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getName(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGrey)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealSoins.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_getCategory(),
                    style: const TextStyle(
                        color: AppColors.tealSoins,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── RATING BAR ───
  Widget _buildRatingBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Big rating number
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _currentRating.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < _currentRating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$_currentReviewCount avis vérifiés",
                  style: const TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Distance badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.tealSoins.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.near_me_rounded,
                    color: AppColors.tealSoins, size: 14),
                const SizedBox(width: 4),
                Text(_getDistance(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.tealSoins)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── QUICK ACTIONS ───
  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionButton(
            Icons.phone_rounded, "Appeler", AppColors.tealSoins, _launchPhone),
        const SizedBox(width: 10),
        _actionButton(Icons.map_rounded, "Carte", AppColors.secondaryBlue,
            () => _showFullScreenMap(context)),
        const SizedBox(width: 10),
        _actionButton(Icons.rate_review_rounded, "Avis", Colors.amber,
            () => _showAddReviewModal(context)),
      ],
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DESCRIPTION ───
  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tealSoins.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.tealSoins, size: 18),
              ),
              const SizedBox(width: 10),
              const Text("À propos",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_getBio(),
              style: const TextStyle(
                  height: 1.6, color: AppColors.mediumGrey, fontSize: 13.5)),
        ],
      ),
    );
  }

  // ─── LOCATION SECTION ───
  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_outlined,
                    color: AppColors.secondaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              const Text("Localisation & Contact",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          _contactTile(Icons.map_outlined, _getAddress()),
          const Divider(height: 24),
          GestureDetector(
            onTap: _launchPhone,
            child:
                _contactTile(Icons.phone_outlined, _getPhone(), isLink: true),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String text, {bool isLink = false}) {
    return Row(
      children: [
        Icon(icon,
            color: isLink ? AppColors.tealSoins : AppColors.mediumGrey,
            size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: isLink ? AppColors.tealSoins : AppColors.darkGrey,
                  decoration:
                      isLink ? TextDecoration.underline : TextDecoration.none)),
        ),
      ],
    );
  }

  // ─── REVIEWS SECTION ───
  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text("Avis & Évaluations",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            GestureDetector(
              onTap: () => _showAddReviewModal(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.tealSoins, Color(0xFF2DD4BF)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text("Nouvel avis",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingReviews)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: AppColors.tealSoins),
          ))
        else if (_avisList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined,
                    color: AppColors.mediumGrey.withOpacity(0.4), size: 48),
                const SizedBox(height: 12),
                const Text("Aucun avis pour le moment",
                    style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("Soyez le premier à donner votre avis !",
                    style: TextStyle(
                        color: AppColors.mediumGrey.withOpacity(0.7),
                        fontSize: 13)),
              ],
            ),
          )
        else ...[
          ..._avisList.take(3).map((avis) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReviewCard(avis),
              )),
          if (_avisList.length > 3)
            GestureDetector(
              onTap: () => _showAllReviews(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.tealSoins.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    "Voir tous les ${_avisList.length} avis",
                    style: const TextStyle(
                        color: AppColors.tealSoins,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _showAllReviews(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          title: Text("Avis - ${_getName()}"),
          backgroundColor: AppColors.tealSoins,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _avisList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewCard(_avisList[index]),
          ),
        ),
      ),
    ));
  }

  Widget _buildReviewCard(Avis avis) {
    String formattedDate = avis.createdAt;
    try {
      final dt = DateTime.parse(avis.createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) {
        formattedDate = "Aujourd'hui";
      } else if (diff.inDays == 1) {
        formattedDate = "Hier";
      } else if (diff.inDays < 30) {
        formattedDate = "Il y a ${diff.inDays} jours";
      } else {
        formattedDate =
            "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      }
    } catch (_) {}

    final initial =
        avis.userName.isNotEmpty ? avis.userName[0].toUpperCase() : 'U';

    // Pick a color based on the first letter
    final colors = [
      AppColors.tealSoins,
      AppColors.secondaryBlue,
      AppColors.purpleAssistance,
      AppColors.pinkAccent,
      AppColors.orangeWarning,
    ];
    final bgColor = colors[initial.codeUnitAt(0) % colors.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 18,
                  backgroundColor: bgColor.withOpacity(0.15),
                  child: Text(initial,
                      style: TextStyle(
                          color: bgColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(avis.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13.5)),
                    Text(formattedDate,
                        style: TextStyle(
                            color: AppColors.mediumGrey.withOpacity(0.7),
                            fontSize: 11)),
                  ],
                ),
              ),
              // Stars
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(
                        5,
                        (i) => Icon(
                              i < avis.rating.round()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 14,
                            )),
                  ],
                ),
              ),
            ],
          ),
          if (avis.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(avis.comment,
                style: const TextStyle(
                    color: AppColors.mediumGrey, fontSize: 13, height: 1.5)),
          ],
          // Edit/Delete buttons for own review
          if (_currentUserId != null && avis.userId == _currentUserId) ...[
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _showEditReviewModal(context, avis),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded,
                            size: 14, color: AppColors.secondaryBlue),
                        SizedBox(width: 4),
                        Text("Modifier",
                            style: TextStyle(
                                color: AppColors.secondaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDeleteAvis(context, avis),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.redDanger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 14, color: AppColors.redDanger),
                        SizedBox(width: 4),
                        Text("Supprimer",
                            style: TextStyle(
                                color: AppColors.redDanger,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── FULLSCREEN MAP ───
  void _showFullScreenMap(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.tealSoins,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(_getName(),
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        body: FlutterMap(
          options: MapOptions(
            initialCenter: _doctorLocation,
            initialZoom: 15.0,
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smartconstat.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _doctorLocation,
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.location_on,
                      color: AppColors.redDanger, size: 48),
                ),
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  // ─── ADD REVIEW MODAL ───
  void _showAddReviewModal(BuildContext context) {
    // Check if user already has a review
    final existingReview = _avisList
        .where((a) => _currentUserId != null && a.userId == _currentUserId)
        .toList();
    if (existingReview.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Vous avez déjà laissé un avis. Vous pouvez le modifier ou le supprimer."),
            backgroundColor: AppColors.orangeWarning),
      );
      return;
    }

    final profId = widget.professional['id'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddReviewSheet(
        professionalId: profId,
        professionalName: _getName(),
      ),
    ).then((result) {
      if (result == true) {
        setState(() => _isLoadingReviews = true);
        _fetchAvis();
      }
    });
  }

  void _showEditReviewModal(BuildContext context, Avis avis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditReviewSheet(
        avis: avis,
        professionalName: _getName(),
      ),
    ).then((result) {
      if (result == true) {
        setState(() => _isLoadingReviews = true);
        _fetchAvis();
      }
    });
  }

  void _confirmDeleteAvis(BuildContext context, Avis avis) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Supprimer l'avis"),
        content: const Text(
            "Êtes-vous sûr de vouloir supprimer votre avis ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler",
                style: TextStyle(color: AppColors.mediumGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await ApiServiceFeatures.deleteAvis(avis.id);
              if (success) {
                setState(() => _isLoadingReviews = true);
                _fetchAvis();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Avis supprimé."),
                      backgroundColor: AppColors.greenSuccess),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Erreur lors de la suppression."),
                      backgroundColor: AppColors.redDanger),
                );
              }
            },
            child: const Text("Supprimer",
                style: TextStyle(
                    color: AppColors.redDanger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ADD REVIEW BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════
class _AddReviewSheet extends StatefulWidget {
  final dynamic professionalId;
  final String professionalName;

  const _AddReviewSheet(
      {required this.professionalId, required this.professionalName});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _ratingLabels = [
    "",
    "Très mauvais",
    "Mauvais",
    "Moyen",
    "Bon",
    "Excellent"
  ];

  Future<void> _submitReview() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez donner une note."),
            backgroundColor: AppColors.redDanger),
      );
      return;
    }
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez écrire un commentaire."),
            backgroundColor: AppColors.redDanger),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    int? profId = widget.professionalId is int
        ? widget.professionalId
        : int.tryParse(widget.professionalId?.toString() ?? '');

    if (profId == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur: ID du professionnel manquant."),
            backgroundColor: AppColors.redDanger),
      );
      return;
    }

    int statusCode = await ApiServiceFeatures.addAvis(profId, _rating, comment);
    setState(() => _isSubmitting = false);

    if (statusCode == 200) {
      if (mounted) Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("✅ Avis ajouté avec succès !"),
            backgroundColor: AppColors.greenSuccess),
      );
    } else if (statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Vous avez déjà laissé un avis pour ce professionnel."),
            backgroundColor: AppColors.orangeWarning),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de l'ajout. Vérifiez votre connexion."),
            backgroundColor: AppColors.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text("Évaluer ${widget.professionalName}",
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text("Partagez votre expérience avec les autres patients",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 13)),
          const SizedBox(height: 24),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex.toDouble()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    starIndex <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _ratingLabels[_rating.toInt()],
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),

          // Comment field
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Écrivez votre commentaire ici...",
              hintStyle:
                  TextStyle(color: AppColors.mediumGrey.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.scaffold,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.tealSoins, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealSoins,
                disabledBackgroundColor: AppColors.tealSoins.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text("Soumettre mon avis",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// EDIT REVIEW BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════
class _EditReviewSheet extends StatefulWidget {
  final Avis avis;
  final String professionalName;

  const _EditReviewSheet({required this.avis, required this.professionalName});

  @override
  State<_EditReviewSheet> createState() => _EditReviewSheetState();
}

class _EditReviewSheetState extends State<_EditReviewSheet> {
  late double _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  final List<String> _ratingLabels = [
    "",
    "Très mauvais",
    "Mauvais",
    "Moyen",
    "Bon",
    "Excellent"
  ];

  @override
  void initState() {
    super.initState();
    _rating = widget.avis.rating;
    _commentController = TextEditingController(text: widget.avis.comment);
  }

  Future<void> _submitEdit() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez donner une note."),
            backgroundColor: AppColors.redDanger),
      );
      return;
    }
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez écrire un commentaire."),
            backgroundColor: AppColors.redDanger),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool success =
        await ApiServiceFeatures.updateAvis(widget.avis.id, _rating, comment);
    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("✅ Avis modifié avec succès !"),
            backgroundColor: AppColors.greenSuccess),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de la modification."),
            backgroundColor: AppColors.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Modifier votre avis",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(widget.professionalName,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.mediumGrey, fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex.toDouble()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    starIndex <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _ratingLabels[_rating.toInt()],
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Modifiez votre commentaire...",
              hintStyle:
                  TextStyle(color: AppColors.mediumGrey.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.scaffold,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.tealSoins, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryBlue,
                disabledBackgroundColor:
                    AppColors.secondaryBlue.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text("Enregistrer les modifications",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
