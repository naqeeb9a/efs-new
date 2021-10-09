import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:efs_new/Database/models/employee_model.dart';
import 'package:efs_new/Database/operations/employee_operations.dart';
import 'package:efs_new/pages/appScreens/team_list.dart';
import 'package:efs_new/widgets/dialog_widget.dart';
import 'package:efs_new/widgets/globals.dart';
import 'package:efs_new/widgets/text_field.dart';
import 'package:flutter/material.dart';

final employeeId = TextEditingController();
final employeeName = TextEditingController();
final teamId = TextEditingController();
final _formKey = GlobalKey<FormState>();
EmployeeOperations employeeOperations = EmployeeOperations();

dynamic department = "";

class AddEmployee extends StatefulWidget {
  const AddEmployee({Key key}) : super(key: key);

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  List<String> dropdownList = <String>[
  '360 HANOVER SQUARE',
  'AAN TELEPERFORMANCE',
  'ACCENTURE MIDDLE EAST',
  'ADAM VITAL ORTUS HOSPITAL LLC',
  'ADNOC DISTRIBUTION',
  'AIG UAE',
  'AL BADER EXCHANGE (SEC)',
  'AL BATEEN RESIDENCE',
  'AL JALILA CHILDREN SPECIL HOSP',
  'AL JALILA CULTURAL CENTRE',
  'AL MANAL DEVELOPM',
  'AL TAMIMI-DAYTONA HOUSE',
  'AMAZON UAE JLL',
  'AMAZON-UAE-DIRECT',
  'AMITY EDUCATION SERVICES LLC',
  'APPLE CORP HO',
  'APPLE RETAIL UAE',
  'AUH ADTC',
  'AUH ETIHAD TOWERS',
  'AUH HEALTH POINT',
  'AUH-ACCOMODN-SWT',
  'AUH-FINANCE-SWT',
  'AUH-HR SUPT-SWT',
  'AUH-HR-SWT',
  'AUH-HSEQ-SWT',
  'AUH-IT-SWT',
  'AUH-OPERATIONS-SWT',
  'AUH-STORES-SWT',
  'AUH-TRANSPORT-SWT',
  'AUTOREDO FZE',
  'AVANI HOTEL FIR',
  'AVANI PALM VIEW',
  'AW ROSTAMANI',
  'AYEDH HASAIN',
  'BAKER HUGHES - LANDSCAPING',
  'BAKER HUGHES EHO LTD',
  'BAY CENTRAL INVES',
  'BIN THAMIM RE',
  'BIOCLEAN FIR',
  'BNP PARIBAS',
  'BRITISH TELECOM',
  'BUILDING SERVICES',
  'BURJ AL NUJOOM OWNERS ASSOCIAT',
  'CALL CENTER',
  'CANAL RESIDENCE PROPERTIES',
  'CAREEM',
  'CERNER MIDDLE EAST FZL',
  'CITIBANK',
  'CITRIX SYSTEMS INTERNATIONAL GMBH',
  'CLN C0-AAN-MSD',
  'CLN C07-AAN-MSD',
  'CLN C11-AAN-MSD',
  'CLN C13-AUH-MSD',
  'CLN C16-AAN-MSD',
  'CLN C18AUH-MSD',
  'CLN-C08-AAN-MSD',
  'CMS FITNESS CLUB L.L.C',
  'COCE',
  'CONCIERGE SERVICES',
  'CONCORDIA FZE',
  'CONTRACTED CLEANING SERVICES',
  'DANA PROPERTYENBD A',
  'DEEM FINANCE',
  'DEFYING GRAVITY',
  'DELMA AIRPORT',
  'DEPT OF EDUCATION KNOWLEDGE',
  'DHANI HEALTHCARE',
  'DMG WORLD MEDIA',
  'DOVECOTE GREEN PRIMAR',
  'DUBAI - COMMERCIAL & CONTACT - FLC',
  'DUBAI - Training Center',
  'DUBAI WORLD CENTER',
  'DUBAI WORLD TRADE CENTER',
  'DUBAI-BD-FLC',
  'DXB-ACCOMODN-FLC',
  'DXB-CALL CENTRE-FLC',
  'DXB-FINANCE-FLC',
  'DXB-HR SUPT-FLC',
  'DXB-HR-FLC',
  'DXB-HSEQ-FLC',
  'DXB-IT-FLC',
  'DXB-PROCUREMENT-FLC',
  'DXB-STORES-FLC',
  'DXB-TRANSPORT-FLC',
  'EFS FACILITIES MANAGEME',
  'EFS FACILITIES MANAGEMENT',
  'EFS WARE HOUSE',
  'EMERALD RESIDENCE',
  'ETIHAD AIRWAYS',
  'ETIHAD AIRWAYS - LANDSCAPING',
  'EXPO PEO',
  'EXPO STM',
  'EXPO2020 CWM',
  'EXPO2020 SMA',
  'EY CONSULTING LLC',
  'FAIRMONT HOTEL',
  'FIRRESINT-GEN MGMT.-FLC FIR',
  'FIRRESINT-OPERATIONS-FLC FIR',
  'FIVE HOTELS AND RESOR',
  'FM.RES-SH. SUROOR',
  'FMCLN C03-AAN-MSD',
  'GARTNER',
  'GENERAL',
  'GEOMETRY GLOBAL ADVERTISING LL',
  'GLOBAL INNOVATION',
  'GROUP-BD-FLC',
  'GROUP-FINANCE-FLC',
  'GROUP-GEN MGMT-FLC',
  'GROUP-HR-FLC',
  'GROUP-IT-FLC',
  'GROUP-LEGAL-FLC',
  'GROUP-MARKETING-FLC',
  'GROUP-SERVICE ASSURANCE',
  'GSS-OPERATIONS-FLC',
  'GUARDIAN MAINTENANCE',
  'GUARDIAN PROJECTS',
  'HALLIBURTON',
  'HANDYMAN SERVICES',
  'HOME SERVICES',
  'HOUSEKEEPING SERVICES',
  'HSBC BANK',
  'HSE',
  'IFA RESIDENTIAL SERVICES FZE',
  'IFA-SHARED SERVICES',
  'INTEL',
  'INTERIM OWNER ASS',
  'IRTIKAZ OWNERS ASSOCIATION',
  'IWP UAE',
  'JAPAN TOBACCO INTERNATIONAL',
  'JAWAD FZCO',
  "JOEL SAVIO D'SOUZA",
  'JOHNSON CONTROLS INTERNATIONAL',
  'KPMG UAE',
  'LANDSCAPING - BALQIS',
  'LE ROYAL MERIDIEN BEACH RESORT & SPA FIR',
  'LENEVO',
  'MARINA HOME',
  'MARINASCAPE',
  'MASTERCARD UAE',
  'METLIFE UAE',
  'METSO AUTOMATION FZE',
  'MPS-GEN MGMT-TCM',
  'MPS-OPERATIONS-FLC',
  'MT-FITOUT TEAM',
  'MT-LANDSCAPING TEAM',
  'MT-MEP TEAM',
  'MUBADALA-MEP',
  'MUHAMMAD ASIF',
  'MUHAMMAD NOOR',
  'MULTIBANK FX INTERNATIONAL CORPORATION',
  'MUSANADA AWQAF Al AIN',
  'Ministry of Education (M.O.E)',
  'NORTH RESIDENCE',
  'OMNIYAT TSI,'
  'OMNIYAT-OPUS',
  'OPEN EYE UNIVERSITY',
  'OPEN EYE-CHAIRMAN V',
  'OPEN EYE-DAFRA BLDG',
  'OPEN EYE-NAKHEEL & K',
  'OPEN EYE-UNIVERSITY',
  'OPENEYE-ICON-1 TOWER',
  'OPENEYE-ICON-2 TOWER',
  'OPERATIONS/OTIS DUBAI',
  'PHILLIPS UAE',
  'PLACE COMMUNITY',
  'PLAZA RESIDENCE AL WASL',
  'POSITIVE PACKAGING',
  'PREMIUM COMMUNITY',
  'PREMIUM-SILICONSTAR',
  'PREMUUM COMMUNITY',
  'PRICEWATERHOUSE COOPER (IWP)',
  'PRIME TECH FZCO',
  'PROCTER & GAMBLE',
  'RAFFLE DUBAI BRANCH OF WAFE PROPERTY LLC FIR',
  'RASHID HOSPITAL',
  'RECKITT BENCKISER',
  'REFINITIV',
  'RELIEVER EFS ABU DHABI',
  'RELIEVER EFS DUBAI',
  'REUTERS LIMITED',
  'ROPE ACCESS',
  'ROPE ACCESS APPLE',
  'ROTANNA AMWAJ FIR',
  'ROTANNA MEDIA FIR',
  'RSA LOG-COLD CHAIN',
  'RSA LOG-DWC LLC-WA-02',
  'RSA LOG-DWC LLC-WA-05',
  'RSA LOG-JSS PIPE',
  'RSA LOG-TP155& TP-158',
  'RSA NATIONAL DWC-LLC',
  'SABIS FACILITIES MANAGEMENT',
  'SAGA INT’L PARK ONE OWNER ASSOCIATION',
  'SAIF AL SHAMSI & SONS',
  'SAIF HADHER KHAMIS SAIF ALAMEEMI',
  'SCHLUMBERGER',
  'SEC OPERATIONS-FLC',
  'SECURITY SERVICES',
  'SH KHALIFA SPECIALITY HOSPITAL',
  'SHEIKH SAEED VILLA',
  'SHIRE EXPORT SERVICES GMBH',
  'SHRSER-GEN MGMT-FLC',
  'SINYAR MTB',
  'SINYAR PROPERTY MANAGEMENT',
  'SIR BANIYAS ISLAND AIRPORT',
  'SKSH Landscaping',
  'SLB-C1 HQ UAE',
  'SLB-ICAD BASE UAE',
  'SLB-MUSAFFAH BASE UAE',
  'SOUQ EXTRA',
  'SWAROVSKI JAFZA',
  'T M F SERVICES B V (DUBAI BR)',
  'TAHER JHANJHARYA',
  'TECHNIP-ENOC REFINERY',
 ' THE HOTEL/8',
  'TVG DWC-LLC',
  'TWOFOUR54',
  'UNILEVER - LANDSCAPING',
  'UNILEVER GULF FZE',
  'UNITED ARAB SHIPPING',
  'UTC',
  'VAKSON Al QASEER BUILDING',
  'VAKSON BUILDING',
  'VAKSON RE-DISCO-43',
  'VAKSON RE-DISCO-54',
  'VAKSON RE-HEAD OFFIC',
  'VAMM GROUP SFO DMCC',
  'VILLA-TARIQ CHAUHAN',
  'VIRENDRA SINGH',
  'WE-WORK',
 ' WEATHERFORD',
  'WILHELMSEN',
  'WORLD TADE CENTER',
  'XERVON INDUSTRIAL SERVICES L.L.C',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text(
          "Add Employee",
          style: TextStyle(
            color: Colors.black,
            fontSize: width * .054,
          ),
        ),
        iconTheme: IconThemeData(
          color: Color(0xff022b5e),
        ),
        backgroundColor: Color(0xfff2f2f2),
        elevation: 4.0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: width * .9,
          height: height * .8,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .06,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          "Please fill all details",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: width * .05,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: textField(
                              context, employeeId, "Employee Id", false),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: textField(
                              context, employeeName, "Employee Name", false),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            height: MediaQuery.of(context).size.height * .066,
                            color: Colors.white60,
                            child: DropdownSearch(
                              mode: Mode.DIALOG,
                              showSearchBox: true,
                              showClearButton: true,
                              items: dropdownList,
                              label: "Department",
                              hint: "Select Department",
                              onChanged: (value) {
                                setState(() {
                                  department = value;
                                });
                                print(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        saveData(
                          context,
                          Globals.teamName,
                          Globals.teamId,
                          Globals.deviceId,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget saveData(BuildContext context, String teamName, teamId, deviceId) {
  return Material(
    color: Colors.green[400],
    borderRadius: BorderRadius.circular(10.0),
    child: InkWell(
      onTap: () {
        if (employeeId.text == "" ||
            employeeName.text == "" ||
            department == "") {
          errorDialog(context, "Fill all fields!");
        } else {
          final employee = Employee(
            id: 0,
            employeeId: employeeId.text,
            employeeName: employeeName.text,
            department: department,
            designation: "Employee",
            image: "",
            teamId: teamId.toString(),
            status: "A",
            isTeamLead: "",
            username: "",
            password: "",
            teamName: teamName.toString(),
            isSync: "0",
            imageData: "",
          );
          var create = employeeOperations.createEmployee(employee);
          if (create != null) {
            successDialogOnly(context, "Employee Added!!");
            employeeId.clear();
            employeeName.clear();
            Future.delayed(Duration(milliseconds: 1500), () {
              employeeId.clear();
              employeeName.clear();
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 3);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TeamList(),
                ),
              );
            });
          } else {
            errorDialog(context, "Employee Not Added!!");
          }
        }
      },
      splashColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * .5,
        height: MediaQuery.of(context).size.height * .07,
        child: Center(
          child: Text(
            "Save Data",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * .05,
            ),
          ),
        ),
      ),
    ),
  );
}
