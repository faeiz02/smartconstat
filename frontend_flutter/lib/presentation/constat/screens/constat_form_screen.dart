import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/constat_model.dart';
import '../../../data/services/accident_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/smart_canvas_widget.dart';
import 'fullscreen_canvas_screen.dart';

class ConstatFormScreen extends StatefulWidget {
  const ConstatFormScreen({super.key});

  @override
  State<ConstatFormScreen> createState() => _ConstatFormScreenState();
}

class _ConstatFormScreenState extends State<ConstatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers Véhicule A
  final _assureurAController = TextEditingController();
  final _contratAController = TextEditingController();
  final _nomAController = TextEditingController();
  final _prenomAController = TextEditingController();
  final _adresseAController = TextEditingController();
  final _marqueAController = TextEditingController();
  final _modeleAController = TextEditingController();
  final _immatriculationAController = TextEditingController();
  final _paysAController = TextEditingController(text: "TN");

  // Controllers Véhicule B
  final _assureurBController = TextEditingController();
  final _contratBController = TextEditingController();
  final _nomBController = TextEditingController();
  final _prenomBController = TextEditingController();
  final _adresseBController = TextEditingController();
  final _marqueBController = TextEditingController();
  final _modeleBController = TextEditingController();
  final _immatriculationBController = TextEditingController();
  final _paysBController = TextEditingController(text: "TN");

  // Général
  final _dateController = TextEditingController();
  final _heureController = TextEditingController();
  final _lieuController = TextEditingController();
  final _temoinsController = TextEditingController();
  final _degatsAcontroller = TextEditingController();
  final _degatsBcontroller = TextEditingController();
  final _observationsController = TextEditingController();

  // Photos & choc
  final List<File> _photos = [];
  int? _selectedChocPosition;
  bool _degatsMateriels = false;
  bool _blesses = false;
  bool _interventionPolice = false;

  // Croquis - Smart Canvas
  final SmartCanvasController _croquisCanvasController = SmartCanvasController();
  
  final SignatureController _signatureControllerA = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.blue,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _signatureControllerB = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.blue,
    exportBackgroundColor: Colors.white,
  );

  // Circonstances
  Map<String, bool> circonstancesA = {
    "Stationnaire": false, "Démarrait": false, "S'arrêtait": false,
    "Reculait": false, "Changeait de direction": false, "Dépassait": false,
    "Stationnement en créneau": false, "Sortait de stationnement": false,
    "Circulait sur voie de bus": false, "Forçait un passage à niveau": false,
    "Brûlait un feu rouge": false, "Brûlait un stop": false, "Cédait le passage": false,
  };
  Map<String, bool> circonstancesB = {
    "Stationnaire": false, "Démarrait": false, "S'arrêtait": false,
    "Reculait": false, "Changeait de direction": false, "Dépassait": false,
    "Stationnement en créneau": false, "Sortait de stationnement": false,
    "Circulait sur voie de bus": false, "Forçait un passage à niveau": false,
    "Brûlait un feu rouge": false, "Brûlait un stop": false, "Cédait le passage": false,
  };

  bool _isFetchingLocation = false;

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
        final response = await http.get(url, headers: {'User-Agent': 'SmartConstatApp'});
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['display_name'] != null) {
            _lieuController.text = data['display_name'];
          } else {
            _lieuController.text = "${position.latitude}, ${position.longitude}";
          }
        } else {
          _lieuController.text = "${position.latitude}, ${position.longitude}";
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission GPS refusée"), backgroundColor: AppColors.redDanger),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la récupération GPS"), backgroundColor: AppColors.redDanger),
      );
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) setState(() => _photos.add(File(photo.path)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Constat Amiable"),
        backgroundColor: AppColors.primaryBlue,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        actions: [
          IconButton(icon: const Icon(Icons.save_outlined), onPressed: _saveConstat, tooltip: "Enregistrer"),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.vertical,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 5)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Suivant"),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveConstat,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text("GÉNÉRER LE CONSTAT"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenSuccess,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.lightGrey),
                      ),
                      child: const Text("Retour"),
                    ),
                  ],
                ],
              ),
            );
          },
          onStepContinue: () {
            if (_currentStep < 7) setState(() => _currentStep++);
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: [
            _buildStep(0, "Informations", Icons.info_outline, _buildInfoSection()),
            _buildStep(1, "Véhicule A", Icons.directions_car_outlined, _buildVehicleSection(true)),
            _buildStep(2, "Véhicule B", Icons.directions_car_filled_outlined, _buildVehicleSection(false)),
            _buildStep(3, "Point de choc", Icons.gps_fixed_outlined, _buildChocSection()),
            _buildStep(4, "Dégâts & Photos", Icons.camera_alt_outlined, _buildDegatsSection()),
            _buildStep(5, "Observations", Icons.note_alt_outlined, _buildObservationsSection()),
            _buildStep(6, "Croquis", Icons.draw_outlined, _buildCroquisSection()),
            _buildStep(7, "Signatures", Icons.edit_document, _buildSignaturesSection()),
          ],
        ),
      ),
    );
  }

  Step _buildStep(int index, String title, IconData icon, Widget content) {
    return Step(
      title: Row(
        children: [
          Icon(icon, size: 18, color: _currentStep >= index ? AppColors.secondaryBlue : AppColors.mediumGrey),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _currentStep >= index ? AppColors.darkGrey : AppColors.mediumGrey,
          )),
        ],
      ),
      content: content,
      isActive: _currentStep >= index,
      state: _currentStep > index ? StepState.complete : _currentStep == index ? StepState.editing : StepState.indexed,
    );
  }

  // ─── STEP 1 : Informations ───
  Widget _buildInfoSection() {
    return _buildSectionCard(
      children: [
        Row(
          children: [
            Expanded(child: _buildField(_dateController, "Date", "JJ/MM/AAAA", Icons.calendar_today_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(_heureController, "Heure", "HH:MM", Icons.schedule_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        _buildField(
          _lieuController, 
          "Lieu de l'accident", 
          null, 
          Icons.location_on_outlined, 
          isRequired: true,
          suffixIcon: IconButton(
            icon: _isFetchingLocation 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryBlue))
              : const Icon(Icons.my_location, color: AppColors.secondaryBlue),
            onPressed: _isFetchingLocation ? null : _fetchLocation,
          ),
        ),
        const SizedBox(height: 12),
        _buildField(_temoinsController, "Témoins", "Nom, adresse, téléphone", Icons.people_outline, maxLines: 2),
      ],
    );
  }

  // ─── STEP 2/3 : Véhicules ───
  Widget _buildVehicleSection(bool isA) {
    final Color color = isA ? AppColors.secondaryBlue : AppColors.orangeWarning;
    return _buildSectionCard(
      children: [
        _buildField(isA ? _assureurAController : _assureurBController, "Société d'assurances", null, Icons.business_outlined, isRequired: true),
        const SizedBox(height: 10),
        _buildField(isA ? _contratAController : _contratBController, "N° contrat", null, Icons.description_outlined, isRequired: true),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _buildField(isA ? _nomAController : _nomBController, "Nom", null, null, isRequired: true)),
          const SizedBox(width: 10),
          Expanded(child: _buildField(isA ? _prenomAController : _prenomBController, "Prénom", null, null, isRequired: true)),
        ]),
        const SizedBox(height: 10),
        _buildField(isA ? _adresseAController : _adresseBController, "Adresse", null, null, maxLines: 2),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _buildField(isA ? _marqueAController : _marqueBController, "Marque", null, null, isRequired: true)),
          const SizedBox(width: 10),
          Expanded(child: _buildField(isA ? _modeleAController : _modeleBController, "Modèle", null, null, isRequired: true)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(flex: 2, child: _buildField(isA ? _immatriculationAController : _immatriculationBController, "Immatriculation", null, Icons.pin_outlined, isRequired: true)),
          const SizedBox(width: 10),
          Expanded(child: _buildField(isA ? _paysAController : _paysBController, "Pays", null, null)),
        ]),
        const SizedBox(height: 14),
        // Circonstances
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: color.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Circonstances", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: (isA ? circonstancesA : circonstancesB).keys.map((key) {
                  final selected = (isA ? circonstancesA : circonstancesB)[key]!;
                  return FilterChip(
                    label: Text(key, style: TextStyle(fontSize: 11, color: selected ? Colors.white : AppColors.darkGrey)),
                    selected: selected,
                    onSelected: (s) => setState(() => isA ? circonstancesA[key] = s : circonstancesB[key] = s),
                    backgroundColor: Colors.white,
                    selectedColor: color,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: selected ? color : AppColors.lightGrey),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STEP 4 : Point de choc ───
  Widget _buildChocSection() {
    return _buildSectionCard(
      children: [
        const Text("Cliquez sur le point de choc initial", style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
        const SizedBox(height: 12),
        _buildVehicleChocDiagram(),
        const SizedBox(height: 10),
        if (_selectedChocPosition != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.greenSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle, color: AppColors.greenSuccess, size: 18),
              const SizedBox(width: 8),
              Text("Point sélectionné : $_selectedChocPosition",
                style: const TextStyle(color: AppColors.greenSuccess, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
      ],
    );
  }

  Widget _buildVehicleChocDiagram() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.directions_car, size: 90, color: AppColors.lightGrey)),
          Positioned(top: 20, left: 20, child: _buildChocPoint(1, "Avant G")),
          Positioned(top: 20, right: 20, child: _buildChocPoint(2, "Avant D")),
          Positioned(bottom: 20, left: 20, child: _buildChocPoint(3, "Arrière G")),
          Positioned(bottom: 20, right: 20, child: _buildChocPoint(4, "Arrière D")),
          Positioned(left: 20, top: 80, child: _buildChocPoint(5, "Côté G")),
          Positioned(right: 20, top: 80, child: _buildChocPoint(6, "Côté D")),
        ],
      ),
    );
  }

  Widget _buildChocPoint(int position, String label) {
    final isSelected = _selectedChocPosition == position;
    return GestureDetector(
      onTap: () => setState(() => _selectedChocPosition = position),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.redDanger : AppColors.secondaryBlue.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? AppColors.redDanger : AppColors.secondaryBlue, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.redDanger.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Center(
          child: Text(
            "$position",
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.secondaryBlue,
              fontWeight: FontWeight.w700, fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ─── STEP 5 : Dégâts & Photos ───
  Widget _buildDegatsSection() {
    return _buildSectionCard(
      children: [
        _buildField(_degatsAcontroller, "Dégâts véhicule A", "Décrivez les dégâts", null, maxLines: 2),
        const SizedBox(height: 10),
        _buildField(_degatsBcontroller, "Dégâts véhicule B", "Décrivez les dégâts", null, maxLines: 2),
        const SizedBox(height: 16),
        const Row(children: [
          Icon(Icons.camera_alt_outlined, color: AppColors.secondaryBlue, size: 20),
          SizedBox(width: 8),
          Text("Photos de l'accident", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1,
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                return GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 100, height: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.3), width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.secondaryBlue.withOpacity(0.04),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.secondaryBlue),
                        SizedBox(height: 4),
                        Text("Ajouter", style: TextStyle(fontSize: 11, color: AppColors.secondaryBlue, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    width: 100, height: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(image: FileImage(_photos[index]), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4, right: 14,
                    child: GestureDetector(
                      onTap: () => setState(() => _photos.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: AppColors.redDanger, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── STEP 6 : Observations ───
  Widget _buildObservationsSection() {
    return _buildSectionCard(
      children: [
        CheckboxListTile(
          title: const Text("Dégâts matériels autres qu'aux véhicules", style: TextStyle(fontSize: 13)),
          value: _degatsMateriels,
          onChanged: (v) => setState(() => _degatsMateriels = v!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          activeColor: AppColors.secondaryBlue,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text("Blessés", style: TextStyle(fontSize: 13)),
          value: _blesses,
          onChanged: (v) => setState(() => _blesses = v!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          activeColor: AppColors.redDanger,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text("Intervention des autorités (Police, Garde N.)", style: TextStyle(fontSize: 13)),
          value: _interventionPolice,
          onChanged: (v) => setState(() => _interventionPolice = v!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          activeColor: AppColors.secondaryBlue,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 10),
        _buildField(_observationsController, "Observations complémentaires", "Témoins, circonstances...", null, maxLines: 3),
      ],
    );
  }

  // ─── STEP 7 : Croquis ───
  Widget _buildCroquisSection() {
    return _buildSectionCard(
      children: [
        const Row(
          children: [
            Icon(Icons.draw_outlined, color: AppColors.secondaryBlue, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text("Dessinez le croquis de l'accident", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "Cliquez ci-dessous pour ouvrir l'éditeur de croquis en plein écran pour plus de précision.",
          style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenCanvasScreen(controller: _croquisCanvasController),
              ),
            );
            setState(() {}); // Refresh to show thumbnail updates
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.3), width: 2),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.secondaryBlue.withOpacity(0.02),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Render the canvas as thumbnail but disable touch
                IgnorePointer(
                  child: SmartCanvasWidget(controller: _croquisCanvasController, height: 250),
                ),
                // Overlay an edit icon
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fullscreen, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text("Éditer en plein écran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── STEP 8 : Signatures ───
  Widget _buildSignaturesSection() {
    return _buildSectionCard(
      children: [
        const Text("Signature Conducteur A", style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.secondaryBlue), borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(controller: _signatureControllerA, height: 120, backgroundColor: Colors.grey.shade50),
          ),
        ),
        TextButton(onPressed: () => _signatureControllerA.clear(), child: const Text("Effacer A")),
        const SizedBox(height: 16),
        const Text("Signature Conducteur B", style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.orangeWarning), borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(controller: _signatureControllerB, height: 120, backgroundColor: Colors.grey.shade50),
          ),
        ),
        TextButton(onPressed: () => _signatureControllerB.clear(), child: const Text("Effacer B")),
      ],
    );
  }

  // ─── HELPERS ───
  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildField(TextEditingController c, String label, String? hint, IconData? icon, {int maxLines = 1, bool isRequired = false, Widget? suffixIcon}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        suffixIcon: suffixIcon,
      ),
      validator: isRequired ? (value) {
        if (value == null || value.trim().isEmpty) return 'Requis';
        return null;
      } : null,
    );
  }

  // ─── SAVE ───
  Future<File?> _exportCanvasImage() async {
    if (_croquisCanvasController.isEmpty) return null;
    final Uint8List? data = await _croquisCanvasController.toPngBytes();
    if (data == null) return null;
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/croquis_${DateTime.now().millisecondsSinceEpoch}.png').create();
    file.writeAsBytesSync(data);
    return file;
  }

  Future<File?> _exportSignature(SignatureController controller, String prefix) async {
    if (controller.isEmpty) return null;
    final Uint8List? data = await controller.toPngBytes();
    if (data == null) return null;
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.png').create();
    file.writeAsBytesSync(data);
    return file;
  }

  void _saveConstat() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires (en rouge)."), backgroundColor: AppColors.redDanger),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      List<String> circA = circonstancesA.entries.where((e) => e.value).map((e) => e.key).toList();
      List<String> circB = circonstancesB.entries.where((e) => e.value).map((e) => e.key).toList();

      ConstatModel constat = ConstatModel(
        dateTime: DateTime.now(),
        lieu: _lieuController.text,
        assureurA: _assureurAController.text,
        contratA: _contratAController.text,
        nomA: _nomAController.text,
        prenomA: _prenomAController.text,
        adresseA: _adresseAController.text,
        vehiculeMarqueA: _marqueAController.text,
        vehiculeModeleA: _modeleAController.text,
        immatriculationA: _immatriculationAController.text,
        paysA: _paysAController.text,
        sensSuiviA: "Non renseigné",
        assureurB: _assureurBController.text,
        contratB: _contratBController.text,
        nomB: _nomBController.text,
        prenomB: _prenomBController.text,
        adresseB: _adresseBController.text,
        vehiculeMarqueB: _marqueBController.text,
        vehiculeModeleB: _modeleBController.text,
        immatriculationB: _immatriculationBController.text,
        paysB: _paysBController.text,
        sensSuiviB: "Non renseigné",
        pointChocInitial: _selectedChocPosition?.toString(),
        degatsApparentsA: _degatsAcontroller.text,
        degatsApparentsB: _degatsBcontroller.text,
        circonstances: [...circA, ...circB],
        observations: _observationsController.text,
        temoins: _temoinsController.text.isNotEmpty ? _temoinsController.text : null,
        blesses: _blesses,
        degatsMaterielsAutres: _degatsMateriels,
        interventionPolice: _interventionPolice,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.secondaryBlue),
                SizedBox(height: 16),
                Text("Envoi des données...", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

      final authUser = context.read<AuthProvider>().user;
      final providerUser = context.read<UserProvider>().user;
      final currentUser = authUser ?? providerUser;

      if (currentUser == null || currentUser.assuranceId.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session invalide. Reconnectez-vous avant d'envoyer un constat."),
              backgroundColor: AppColors.redDanger,
            ),
          );
        }
        return;
      }

      final assuranceId = currentUser.assuranceId;

      final result = await AccidentService.saveConstat(assuranceId, constat);
      
      if (result["success"]) {
        String accidentId = result["data"]["accidentId"] ?? result["data"]["id"] ?? "";
        
        if (accidentId.isNotEmpty) {
          // Exporter les signatures et croquis
          File? croquisFile = await _exportCanvasImage();
          File? sigAFile = await _exportSignature(_signatureControllerA, "sigA");
          File? sigBFile = await _exportSignature(_signatureControllerB, "sigB");

          List<String> photosPaths = _photos.map((f) => f.path).toList();

          await AccidentService.uploadConstatFiles(
            accidentId,
            croquisFile?.path,
            sigAFile?.path,
            sigBFile?.path,
            photosPaths
          );
        }
        
        if (mounted) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text("Constat et fichiers envoyés avec succès!")),
                ]),
                backgroundColor: AppColors.greenSuccess,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
        }
      } else {
        if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Échec de l'envoi : ${result["message"]}"),
                backgroundColor: AppColors.redDanger,
              ),
            );
        }
      }
    }
  }
}
