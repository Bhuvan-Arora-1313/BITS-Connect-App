import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxMembersController = TextEditingController();

  List<String> _selectedCourses = [];
  List<String> _selectedTags = [];
  bool _isPublic = true;
  bool _isToday = true;
  bool _isPermanent = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Duration? _selectedDuration;

  final List<String> _courses = [
    "ADV COMPUTER ARCHITECTUR – CS G524",
    "ADV CONCRETE STRUCTURES – CE G613",
    "ADV INORGANIC CHEMISTRY – CHEM G552",
    "ADV QUANTUM MECHANICS – PHY F421",
    "ADV RECOMBINANT DNA TECH – BIO G561",
    "ADV SPREAD & MAC PROG FO.. – MPBA G516",
    "ADVANCED CHEMICAL ENGG THERMO – CHE G622",
    "ADVANCED CONCRETE TECHNOLOGY – CE G562",
    "ADVANCED DIGITAL COMMUNI – EEE G622",
    "ADVANCED FINITE ELEM MODEL & .. – ME G613",
    "ADVANCED MECHANICS OF SO.. – ME F218",
    "ADVANCED MEDICINAL CHEM – PHA G621",
    "ADVANCED PHARMACOLOGY – PHA G611",
    "ADVANCED PHYSICS LAB – PHY F344",
    "ADVANCED PROJECT – BITS G511",
    "ADVANCED STEEL STRUCTURE – CE G612",
    "ANALOG & DIGIT VLSI DES – EEE F313",
    "ANALOG ELECTRONICS – ECE F341",
    "ANALOG ELECTRONICS – EEE F341",
    "ANALOG ELECTRONICS – INSTR F341",
    "ANALOG IC DESIGN – MEL G632",
    "ANALYSIS OF STRUCTURES – CE F241",
    "ANALYTICS FOR SUPPLY CHAIN – BITS F455",
    "ANATOMY PHYSIO & HYGIENE – PHA F214",
    "ANTENNA THEO AND DESIGN – EEE F474",
    "APPLIED ECONOMETRICS – ECON F342",
    "APPLIED NUTRITION & NUTR.. – BIO F315",
    "APPLIED PHILOSOPHY – GS F312",
    "APPLIED STOCHASTIC PROCE – MATH F424",
    "APPLIED THERMODYNAMICS – ME F214",
    "APPR OF INDIAN MUSIC – HSS F223",
    "ARTIFICIAL INTELLIGENCE – CS F407",
    "ATMOSPHERIC CHEMISTRY – CHEM F430",
    "ATOMIC & MOLECULAR PHY – PHY F342",
    "AUTOMOTIVE VEHICLES – ME F441",
    "BIO & CHEMICAL SENSORS – CHEM F414",
    "BIOLOGY LABORATORY – BIO F110",
    "BIOLOGY PROJECT LAB – BIO F231",
    "BIOPHARMACEUTIC & PHARMA.. – PHA F418",
    "BIOPHYSICS – BIO F215",
    "BUSS ANAL & VALUATION – ECON F355",
    "CAD FOR IC DESIGN – MEL G641",
    "CASE STUDIES II – BITS E584",
    "CASTING FORMING AND WELD.. – MF F222",
    "CHEM OF MACROMOLECULES – PHA G522",
    "CHEM OF SYNTHETIC DRUGS – PHA F416",
    "CHEMICAL ENGG LAB II – CHE F341",
    "CHEMICAL EXPER I – CHEM F242",
    "CHEMICAL EXPER II – CHEM F341",
    "CHEMICAL PROCESS TECH – CHE F419",
    "CLINICAL PHARMA & THERAP – PHA G614",
    "COMMUNICATION NETWORKS – ECE F343",
    "COMP AIDED ANAL & DESIGN – ME G611",
    "COMPILER CONSTRUCTION – CS F363",
    "COMPUTER ARCHITECTURE – CS F342",
    "COMPUTER GRAPHICS – IS F311",
    "COMPUTER MEDIATED COMM – GS F342",
    "COMPUTER NETWORKS – CS F303",
    "COMPUTER PROGRAMMING – CS F111",
    "COMPUTER-AIDED DESIGN – ME F318",
    "COMPUTER-AIDED DESIGN AN.. – MF F317",
    "COMPUTATIONAL METHODS FO.. – ECON F215",
    "CONSERVATION BIOLOGY – BIO F314",
    "CONSTRUCTION PLAN & TECH – CE F242",
    "CONTEMPORARY INDIA – GS F332",
    "CONTROL SYSTEMS – ECE F242",
    "CONTROL SYSTEMS – EEE F242",
    "CONTROL SYSTEMS – INSTR F242",
    "COPYWRITING – GS F344",
    "CORPORATE FINANCE – MPBA G509",
    "CREAT & LEAD ENTREP ORGN – BITS F482",
    "CREAT & LEAD ENTREP ORGN – ECON F414",
    "CREATIVE WRITING – GS F241",
    "CRYPTOGRAPHY – BITS F463",
    "CURRENT AFFAIRS – GS F243",
    "DATA COMMUNIC & NETWORKS – EEE F346",
    "DATA MINING – CS F415",
    "DATA STRUCTURES & ALGO – CS F211",
    "DATA VISUAL ETHIC & DAT.. – MPBA G511",
    "DATA WAREHOUSING – SS G515",
    "DATABASE SYSTEMS – CS F212",
    "DEEP LEARNING – CS F425",
    "DERIVATIVES & RISK MGMT – ECON F354",
    "DERIVATIVES & RISK MGMT – FIN F311",
    "DES OF PREST CONC STRUCT – CE F415",
    "DES OF STEEL STRUCTURES – CE F343",
    "DESIGN & ANAL OF ALGO – CS F364",
    "DESIGN OF MULTI-STOR STR – CE G618",
    "DESIGN PROJECT – BIO F376",
    "DESIGN PROJECT – BIO F377",
    "DESIGN PROJECT – CE F376",
    "DESIGN PROJECT – CE F377",
    "DESIGN PROJECT – CHE F376",
    "DESIGN PROJECT – CHE F377",
    "DESIGN PROJECT – CHEM F376",
    "DESIGN PROJECT – CHEM F377",
    "DESIGN PROJECT – CS F376",
    "DESIGN PROJECT – CS F377",
    "DESIGN PROJECT – ECE F376",
    "DESIGN PROJECT – ECE F377",
    "DESIGN PROJECT – ECON F376",
    "DESIGN PROJECT – ECON F377",
    "DESIGN PROJECT – EEE F376",
    "DESIGN PROJECT – EEE F377",
    "DESIGN PROJECT – GS F376",
    "DESIGN PROJECT – GS F377",
    "DESIGN PROJECT – INSTR F376",
    "DESIGN PROJECT – INSTR F377",
    "DESIGN PROJECT – MATH F376",
    "DESIGN PROJECT – MATH F377",
    "DESIGN PROJECT – ME F376",
    "DESIGN PROJECT – ME F377",
    "DESIGN PROJECT – MF F376",
    "DESIGN PROJECT – MF F377",
    "DESIGN PROJECT – PHA F376",
    "DESIGN PROJECT – PHA F377",
    "DESIGN PROJECT – PHY F376",
    "DESIGN PROJECT – PHY F377",
    "DESIGN PROJECTS – DE G522",
    "DESIGN THINKING FOR INNO.. – BITS F326",
    "DEVELOPMENTAL BIOLOGY – BIO F341",
    "DEVELOPMENT ECONOMICS – GS F234",
    "DIFFERENTIAL GEOMETRY – MATH F342",
    "DIGITAL FUNDAMENTALS – BITS F235",
    "DIGITAL MARKETING – BITS F427",
    "DIGITAL SIGNAL PROCESS – EEE F434",
    "DIGITAL TWINS IN MECH ENGG – ME F434",
    "DISSERTATION – BITS G562T",
    "DISSERTATION – BITS G563T",
    "DOSAGE FORM DESIGN – PHA G632",
    "DYN OF SOCIAL CHANGE – GS F231",
    "E & E CIRCUIT LABORATORY – EEE F246",
    "EARTHQUAKE ENGINEERING – CE G615",
    "EARTHQUAKE RES DES & CON – CE F428",
    "ECOLOGY & ENVIRON SCI – BIO F241",
    "ECONOMIC ANAL OF PUB POL – ECON F343",
    "ECONOMIC OF GROWTH & DEV – ECON F244",
    "ECONOMETRIC METHODS – ECON F241",
    "EFFECTIVE PUBLIC SPEAK – GS F245",
    "ELE COREL IN ATOM & MOLEC – CHEM F413",
    "ELECTRICAL SCIENCES – EEE F111",
    "ELECTRONIC DEV SIMULATIO.. – EEE F216",
    "ELECTRONIC DEV SIMULATIO.. – INSTR F216",
    "ELECTROMAGNETIC THEO II – PHY F241",
    "ENERGY ECONOMIC & POLICY – ECON F353",
    "ENERGY MANAGEMENT – ME F424",
    "ENGINEERING GRAPHICS – BITS F110",
    "ENGINEERING HYDROLOGY – CE F321",
    "ENGINEERING OPTIMIZATION – ME F320",
    "ENGINEERING OPTIMIZATION – MF F320",
    "ENVIRONMENTAL STUDIES – BITS F225",
    "ESSENTIALS OF FINANCIAL .. – MGTS F314",
    "EXPERIMENTAL TECHNIQUES – BIO G642",
    "FINANCIAL ENGINEERING – ECON F413",
    "FINANCIAL MANAGEMENT – ECON F315",
    "FINANCIAL MANAGEMENT – FIN F315",
    "FINANCIAL RISK ANAL AND .. – FIN F414",
    "FLEXIBLE AND STRETCHABLE.. – EEE F419",
    "FORENSIC PHARMACY – PHA F343",
    "FOUNDATIONS OF DATA SCIE.. – CS F320",
    "FRACTURE MECHANICS – DE G514",
    "FRONTIERS IN ORGANIC SYN – CHEM F415",
    "FUNDA OF FIN AND ACCOUNT – ECON F212",
    "FUNDA OF FIN AND ACCOUNT – FIN F212",
    "GEN THEO OF REL & COSMO – PHY F415",
    "GENERAL BIOLOGY – BIO F111",
    "GENERAL CHEMISTRY – CHEM F111",
    "GENERAL MATHEMATICS II – BITS F114",
    "GENERATIVE AI – CS F437",
    "GENETIC ENGINEERING TECH – BIO F418",
    "GENETICS – BIO F243",
    "GLOBAL BUSINESS TEC & KS – GS F334",
    "GRAPHS AND NETWORKS – MATH F243",
    "GREEN COMMUNICATIONS & N.. – EEE F430",
    "HEAT TRANSFER – CHE F241",
    "HEAT TRANSFER – ME F220",
    "HIGHWAY CONSTRUCTION TECH – CE G570",
    "HIGHWAY ENGINEERING – CE F244",
    "HUMAN COMP INTERACTION – BITS F364",
    "IMAGE PROCESSING – BITS F311",
    "IMMUNOLOGY – BIO F342",
    "INDIA CLASS MUSIC(INS) I – MUSIC N113T",
    "INDIA CLASS MUSIC(INS)II – MUSIC N114T",
    "INDUS INSTRUMENT & CONT – INSTR F343",
    "INFRASTRUC PLAN & MANAG – CE G520",
    "INFO THEORY & CODING – ECE F344",
    "INFORMATION RETRIEVAL – CS F469",
    "INORGANIC CHEMISTRY II – CHEM F241",
    "INORGANIC CHEMISTRY III – CHEM F343",
    "INSTRU METHODS OF ANAL – BIO F244",
    "INTRO TO BIOINFORMATICS – BIO F242",
    "INTRO TO BIOMEDICAL ENGG – BITS F418",
    "INTRO TO ENVIRN ENGG – CE F323",
    "INTRO TO GENDER STUDIES – BITS F385",
    "INTRO TO NANO SCIENCE – BITS F416",
    "INTRO TO PHARMA BIOTECH – BIOT F416",
    "INTRO TO SOCIAL .. – HSS F372",
    "INTRODUCTORY PSYCHOLOGY – GS F232",
    "INTR TO MOL BIO & IMMUNO – PHA F215",
    "IPR AND PHARMACEUTICALS – PHA G545",
    "LABORATORY PROJECT – BIO F366",
    "LABORATORY PROJECT – CE F366",
    "LABORATORY PROJECT – CE F367",
    "LABORATORY PROJECT – CHE F366",
    "LABORATORY PROJECT – CHE F367",
    "LABORATORY PROJECT – CHEM F366",
    "LABORATORY PROJECT – CHEM F367",
    "LABORATORY PROJECT – CS F366",
    "LABORATORY PROJECT – CS F367",
    "LABORATORY PROJECT – ECE F366",
    "LABORATORY PROJECT – ECE F367",
    "LABORATORY PROJECT – ECON F366",
    "LABORATORY PROJECT – ECON F367",
    "LABORATORY PROJECT – EEE F366",
    "LABORATORY PROJECT – EEE F367",
    "LABORATORY PROJECT – GS F366",
    "LABORATORY PROJECT – GS F367",
    "LABORATORY PROJECT – INSTR F366",
    "LABORATORY PROJECT – INSTR F367",
    "LABORATORY PROJECT – MATH F366",
    "LABORATORY PROJECT – ME F366",
    "LABORATORY PROJECT – ME F367",
    "LABORATORY PROJECT – MF F366",
    "LABORATORY PROJECT – MF F367",
    "LABORATORY PROJECT – PHA F366",
    "LABORATORY PROJECT – PHA F367",
    "LABORATORY PROJECT – PHY F366",
    "LABORATORY PROJECT – PHY F367",
    "LABORATORY PROJECT – PHA G642",
    "MACHINE LEARNING – BITS F464",
    "MACHINE LEARNING FOR CHE.. – CHE F315",
    "MACROECONOMICS – ECON F243",
    "MANUFACTURING MANAGEMENT – ME F316",
    "MANUFACTURING PROCESSES – ME F219",
    "MARKETING RESEARCH – ECON F435",
    "MARXIAN THOUGHTS – GS F313",
    "MATERIAL SCIENCE & ENGG – CHE F243",
    "MATHEMATICAL FLUID DYNAM.. – MATH F445",
    "MATHEMATICAL MODELLING – MATH F420",
    "MATHEMATICAL METHODS – MATH F241",
    "MATHEMATICS II – MATH F112",
    "MATH METHODS OF PHYSICS – PHY F243",
    "MEASURE & INTEGRATION – MATH F244",
    "MECHANISMS AND MACHINES – ME F221",
    "MECHANISMS AND MACHINES – MF F221",
    "MECH OSCILLATIONS & WAVE – PHY F111",
    "MECHATRONICS – MSE G511",
    "MEDICAL INSTRUMENTATION – EEE F432",
    "MEDICAL INSTRUMENTATION – INSTR F432",
    "MEDICINAL CHEMISTRY II – PHA F342",
    "MEMBRANE SCIENCE & ENGIN.. – CHE F423",
    "METROLOGY AND QUALITY AS.. – MF F220",
    "MICROBIAL FERMENT TECHNO – BIO G513",
    "MICROECONOMICS – ECON F242",
    "MICROELECTRONIC CIRCUITS – ECE F244",
    "MICROELECTRONIC CIRCUITS – EEE F244",
    "MICROELECTRONIC CIRCUITS – INSTR F244",
    "MICROPROC & INTERFACING – CS F241",
    "MICROPROC & INTERFACING – ECE F241",
    "MICROPROC & INTERFACING – EEE F241",
    "MICROPROC & INTERFACING – INSTR F241",
    "MIDSEM DATE & SESSION – COMPRE DATE & SESSION",
    "MOBILE PERSONAL COMMUNIC – EEE G592",
    "MOBILE TELECOM NETWORKS – EEE F431",
    "MODEL & SIMU IN CHE ENGG – CHE F418",
    "MODELING OF FIELD-EFFECT.. – EEE F477",
    "MODREN PHYSICS LAB – PHY F244",
    "MULTICRI DE MAK IN E & M – BITS F313",
    "MULTICRITER ANAL IN ENGG – CE G516",
    "MUSICOLOGY-AN INTRODUCTN – HSS F329",
    "NANOCHEMISTRY – CHEM F336",
    "NATURAL DRUGS – PHA F344",
    "NATURAL LANG PROCES FOR .. – MPBA G519",
    "NETWORK EMBEDDED APPLI – EEE G627",
    "NETWORK SECURITY – CS G513",
    "NON TRADITIONAL MANU PRO.. – MF F318",
    "NONLINEAR DYNA & CHAOS – BITS F316",
    "NONLINEAR OPTIMIZATION – MATH F471",
    "NUCLEAR & PARTICLE PHY – PHY F343",
    "NUM FL FLOW & HEAT TRANS – ME F485",
    "NUM METHOD FOR CHEM ENGG – CHE F242",
    "NUM MTHD FOR PARTIAL DIF.. – MATH F422",
    "NUMERICAL LINEAR ALGEBRA – MATH F425",
    "OBJECT ORIENTED PROG – CS F213",
    "OPERATING SYSTEMS – CS F372",
    "OPERATIONS & SUPPLY CHAI.. – MPBA G510",
    "OPERATIONS MANAGEMENT – MF F219",
    "OPERATIONS RESEARCH – MATH F242",
    "ORGANIC CHEMISTRY II – CHEM F243",
    "ORGANIC CHEMISTRY IV – CHEM F342",
    "ORGANIZATIONAL PSYCHOLOGY – HSS F323",
    "PH D SEMINAR – BITS C797T",
    "PARALLEL COMPUTING – CS F422",
    "PARTIAL DIFF EQUATIONS – MATH F343",
    "PAVEMENT ANALYSIS & DES – CE G518",
    "PERFORMANCE STUDIES – HSS F380",
    "PHARMACEUTICAL CHEMISTRY – PHA F241",
    "PHARMACEUTICAL FORMULATI.. – PHA F216",
    "PHARMACEUTICAL MICROBIOL.. – PHA F217",
    "PHARMACEUTICAL REGULATOR.. – PHA F316",
    "PHARMACOLOGY II – PHA F341",
    "PHARMACOECONOMICS – PHA F417",
    "PHYSICAL CHEMISTRY III – CHEM F244",
    "PHYSICAL PHARMACY – PHA F244",
    "PHY METHODS IN CHEMISTRY – CHEM G554",
    "PLANT BIOTECHNOLOGY – BIO G643",
    "POLYMER CHEMISTRY – CHEM F325",
    "POWER ELECTRONICS – EEE F342",
    "POWER ELECTRONICS – INSTR F342",
    "POWER SYSTEMS – EEE F312",
    "PRACTICE SCHOOL – BITS G560",
    "PRACTICE SCHOOL II – BITS F412",
    "PRACTICE SCHOOL II – BITS F413",
    "PRECISION ENGINEERING – ME F472",
    "PREDICTIVE ANALYTICS – MPBA G513",
    "PRIN OF GEO INFO SYST – CE F427",
    "PRINCIPLES OF ECONOMICS – ECON F211",
    "PRINCIPLES OF MANAGEMENT – MGTS F211",
    "PRIMEMOVERS & FLUID MACH – ME F341",
    "PROBABILITY & STATISTICS – MATH F113",
    "PROCESS DES PRINCIPLE II – CHE F343",
    "PROCESS DYN & CONTROL – CHE F342",
    "PROCESS PLANT SAFETY – CHE F413",
    "PROFESSIONAL ETHICS – HSS F343",
    "PROJECT MANAGEMENT – BITS F490",
    "PUBLIC ADMINISTRATION – GS F333",
    "PUBLIC FIN THEO & POLICY – ECON F341",
    "PUBLIC POLICY – GS F233",
    "PUBLIC TRANSPORTATION – CE G566",
    "QUANTUM INFO & COMPUTING – BITS F386",
    "QUANTUM MECHANICS I – PHY F242",
    "RF MICROELECTRONICS – EEE G510",
    "READING COURSE – BITS F382",
    "READINGS FROM DRAMA – HSS F221",
    "REACTION ENGINEERING – CHE G641",
    "REPORT & WRITE FOR MEDIA – GS F244",
    "RESEARCH METHODOLOGY I – BITS G661",
    "RESEARCH PRACTICE – BITS G540",
    "ROAD SAFETY AND ACCIDENT.. – CE G573",
    "ROBOTICS – BITS F441",
    "SANITATION FING & PRJ MGMT – SAN G514",
    "SCIENCE TECH & MODERNITY – BITS F214",
    "SECUR ANAL & PORTFOL MGT – ECON F412",
    "SEMICONDUCTOR FAB TECH – EEE F437",
    "SEPARATION PROCESSES I – CHE F244",
    "SHORT FILM & VIDEO PROD – GS F343",
    "SIGNALS & SYSTEMS – ECE F243",
    "SIGNALS & SYSTEMS – EEE F243",
    "SIGNALS & SYSTEMS – INSTR F243",
    "SMART GRID FOR SUSTAIN E.. – EEE F424",
    "SMART GRID FOR SUSTAIN E.. – INSTR F424",
    "SOCIAL INFORMATICS – HSS F247",
    "SOFT SKILLS FOR PROFESSIONALS – BITS F226",
    "SOFTWARE ARCHITECHTURES – SS G653",
    "SOFTWARE FOR EMBEDDE SYS – CS G523",
    "SOIL MECHANICS – CE F243",
    "SOLID STATE PHYSICS – PHY F341",
    "SPECIAL PROJECT – BIO F491",
    "SPECIAL PROJECT – CE F491",
    "SPECIAL PROJECT – CS F491",
    "SPECIAL PROJECT – ECON F491",
    "SPECIAL PROJECT – EEE F491",
    "SPECIAL PROJECT – GS F491",
    "SPECIAL PROJECT – INSTR F491",
    "SPECIAL PROJECT – MATH F491",
    "SPECIAL PROJECT – ME F491",
    "SPECIAL PROJECT – MF F491",
    "SPECIAL PROJECT – PHA F491",
    "SPECIAL PROJECTS – CHE F491",
    "SRIMAD BHAGAVAD GITA – HSS F334",
    "STATISTICAL INFER & APP – MATH F353",
    "STEM CELL & REGENER BIO – BIO G515",
    "STRATEGIC MANAGEMENT – MPBA G508",
    "STRUCTURAL DYNAMICS – CE F432",
    "STUDY IN ADVANCED TOPICS – BITS G513",
    "STUDY PROJECT – BIO F266",
    "STUDY PROJECT – CE F266",
    "STUDY PROJECT – CHE F266",
    "STUDY PROJECT – CHEM F266",
    "STUDY PROJECT – CS F266",
    "STUDY PROJECT – ECE F266",
    "STUDY PROJECT – ECON F266",
    "STUDY PROJECT – EEE F266",
    "STUDY PROJECT – FIN F266",
    "STUDY PROJECT – GS F266",
    "STUDY PROJECT – HSS F266",
    "STUDY PROJECT – INSTR F266",
    "STUDY PROJECT – MATH F266",
    "STUDY PROJECT – ME F266",
    "STUDY PROJECT – MF F266",
    "STUDY PROJECT – PHA F266",
    "STUDY PROJECT – PHY F266",
    "SUPPLY CHAIN MANAGEMENT – ITEB G621",
    "SUPPLY CHAIN MANAGEMENT – MF F319",
    "SYMBOLIC LOGIC – HSS F236",
  ];
  final List<String> _tags = [
    'question practice', 'class discussion', 'silent study','Jr.-Sr. Interaction','Event',
  ];
  final List<Duration> _durations = [
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 1, minutes: 30),
    Duration(hours: 2),
  ];

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate() || _selectedTime == null || _selectedDuration == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final date = _isToday ? DateTime.now() : _selectedDate;
    if (date == null) return;

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final endDateTime = startDateTime.add(_selectedDuration!);

    final creatorData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    try {
      await FirebaseFirestore.instance.collection('study_groups').add({
        'groupName': _groupNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'courses': _selectedCourses,
        'tags': _selectedTags,
        'location': _locationController.text.trim(),
        'createdBy': user.uid,
        'creatorName': creatorData.data()?['username'] ?? 'Unknown',
        'createdAt': Timestamp.now(),
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'isPublic': _isPublic,
        'isPermanent': _isPermanent,
        'expired': false,
        'maxMembers': int.tryParse(_maxMembersController.text.trim()),
        'members': [user.uid],
        'pendingRequests': [],
      });
      Navigator.pop(context);
    } catch (e) {
      print("\u274C Firestore error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Study Group")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset("lib/assets/images/abstract_bg.png", fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField("Group Name", _groupNameController, required: true),
                  _buildTextField("Description", _descriptionController, maxLines: 3),
                  _buildCourseSelector(),
                  _buildTagSelector(),
                  _buildTextField("Meeting Location", _locationController),
                  _buildTextField("Max Members", _maxMembersController, inputType: TextInputType.number),

                  const SizedBox(height: 12),
                  Text("Meeting Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ChoiceChip(
                        label: Text("Today"),
                        selected: _isToday,
                        onSelected: (val) => setState(() => _isToday = true),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: Text("Other Day"),
                        selected: !_isToday,
                        onSelected: (val) => setState(() => _isToday = false),
                      ),
                    ],
                  ),
                  if (!_isToday) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: Text(_selectedDate == null ? "Pick a date" : DateFormat.yMMMMd().format(_selectedDate!)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: Text(_selectedTime == null ? "Pick Start Time" : _selectedTime!.format(context)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Duration>(
                    decoration: InputDecoration(labelText: "Select Duration"),
                    items: _durations.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text("${d.inHours > 0 ? '${d.inHours}h ' : ''}${d.inMinutes % 60}m"),
                      );
                    }).toList(),
                    onChanged: (d) => setState(() => _selectedDuration = d),
                    validator: (val) => val == null ? "Please select a duration" : null,
                  ),

                  SwitchListTile(
                    title: Text("Public Group"),
                    value: _isPublic,
                    onChanged: (val) => setState(() => _isPublic = val),
                  ),
                  SwitchListTile(
                    title: Text("Make this a permanent group"),
                    value: _isPermanent,
                    onChanged: (val) => setState(() => _isPermanent = val),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _createGroup,
                    icon: Icon(Icons.group_add),
                    label: Text("Create Group"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = false, int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: required ? (val) => val!.isEmpty ? "Required" : null : null,
      ),
    );
  }

  Widget _buildCourseSelector() {
    return MultiSelectDialogField(
      items: _courses.map((c) => MultiSelectItem<String>(c, c)).toList(),
      title: Text("Select Courses"),
      searchable: true,
      searchHint: "Search by course...",
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      buttonIcon: Icon(Icons.school),
      buttonText: Text("Select Courses"),
      onConfirm: (results) {
        setState(() {
          _selectedCourses = results.cast<String>();
        });
      },
      chipDisplay: MultiSelectChipDisplay(
        onTap: (val) {
          setState(() {
            _selectedCourses.remove(val);
          });
        },
      ),
    );
  }

  Widget _buildTagSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 10,
        children: _tags.map((tag) {
          final isSelected = _selectedTags.contains(tag);
          return FilterChip(
            label: Text(tag),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedTags.add(tag);
                } else {
                  _selectedTags.remove(tag);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
