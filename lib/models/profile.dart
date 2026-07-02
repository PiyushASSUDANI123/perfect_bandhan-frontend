import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String name;
  final int age;
  final String height;
  final String caste;
  final String profession;
  final String company;
  final String location;
  final String education;
  final String bio;
  final int compatibilityScore;
  final List<Color> gradientColors; // For premium Apple-style abstract background shapes
  final String initials;
  final String fathersOccupation;
  final String weight;
  final String fatherStatus;
  final String motherStatus;
  final String mothersOccupation;
  final String siblingsCount;
  final String siblingsDetails;
  final String incomeBracket;
  final String professionSector;
  final List<String> photos;
  final String phone;
  String interestStatus;
  final String sindhiType;
  final String whatsappNumber;
  final String monthlyIncome;
  final String yearlyIncome;
  final String district;
  final String properAddress;
  final String jobPost;
  final String ownHouse;
  final String housePhoto;
  final String surname;
  final String nukh;
  final String requirements;
  final String whatWeProvide;
  final String physicalDisability;
  final String complexion;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.caste,
    required this.profession,
    required this.company,
    required this.location,
    required this.education,
    required this.bio,
    required this.compatibilityScore,
    required this.gradientColors,
    required this.initials,
    required this.fathersOccupation,
    this.weight = '',
    this.fatherStatus = 'Alive',
    this.motherStatus = 'Alive',
    this.mothersOccupation = '',
    this.siblingsCount = '0',
    this.siblingsDetails = '',
    required this.incomeBracket,
    required this.professionSector,
    required this.photos,
    this.phone = 'LOCKED',
    this.interestStatus = 'none',
    this.sindhiType = 'Sindhi Hindu',
    this.whatsappNumber = '',
    this.monthlyIncome = '',
    this.yearlyIncome = '',
    this.district = '',
    this.properAddress = '',
    this.jobPost = '',
    this.ownHouse = '',
    this.housePhoto = '',
    this.surname = '',
    this.nukh = '',
    this.requirements = '',
    this.whatWeProvide = '',
    this.physicalDisability = '',
    this.complexion = '',
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    List<Color> colors = [const Color(0xFFC5A059), const Color(0xFFDFBA73)]; // default gold gradient
    if (json['gradientColors'] != null && json['gradientColors'] is List) {
      try {
        colors = (json['gradientColors'] as List)
            .where((hexStr) => hexStr != null)
            .map((hexStr) {
          final hex = hexStr.toString().replaceAll('#', '');
          return Color(int.parse('FF$hex', radix: 16));
        }).toList();
        if (colors.isEmpty) colors = [const Color(0xFFC5A059), const Color(0xFFDFBA73)];
      } catch (_) {
        colors = [const Color(0xFFC5A059), const Color(0xFFDFBA73)];
      }
    }
    
    List<String> photoList = [];
    if (json['photos'] != null && json['photos'] is List) {
      photoList = (json['photos'] as List)
          .where((p) => p != null)
          .map((p) => p.toString())
          .toList();
    }

    // Safe string helper — guarantees non-null even for JS-null values from dynamic map
    String s(String key, [String fallback = '']) {
      final v = json[key];
      if (v == null) return fallback;
      final str = v.toString();
      return str;
    }

    return Profile(
      id: s('id'),
      name: s('name'),
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      height: s('height'),
      caste: s('caste'),
      profession: s('profession'),
      company: s('company', 'Self'),
      location: s('location'),
      education: s('education'),
      bio: s('bio'),
      compatibilityScore: json['compatibilityScore'] is int ? json['compatibilityScore'] : int.tryParse(json['compatibilityScore']?.toString() ?? '0') ?? 0,
      gradientColors: colors,
      initials: s('initials'),
      fathersOccupation: s('fathersOccupation'),
      weight: s('weight'),
      fatherStatus: s('fatherStatus', 'Alive'),
      motherStatus: s('motherStatus', 'Alive'),
      mothersOccupation: s('mothersOccupation'),
      siblingsCount: s('siblingsCount', '0'),
      siblingsDetails: s('siblingsDetails'),
      incomeBracket: s('incomeBracket'),
      professionSector: s('professionSector'),
      photos: photoList,
      phone: s('phone', 'LOCKED'),
      interestStatus: s('interestStatus', 'none'),
      sindhiType: s('sindhiType', 'Sindhi Hindu'),
      whatsappNumber: s('whatsappNumber'),
      monthlyIncome: s('monthlyIncome'),
      yearlyIncome: s('yearlyIncome'),
      district: s('district'),
      properAddress: s('properAddress'),
      jobPost: s('jobPost'),
      ownHouse: s('ownHouse'),
      housePhoto: s('housePhoto'),
      surname: s('surname'),
      nukh: s('nukh'),
      requirements: s('requirements'),
      whatWeProvide: s('whatWeProvide'),
      physicalDisability: s('physicalDisability'),
      complexion: s('complexion'),
    );
  }

  static List<Profile> get mockProfiles => [
        Profile(
          id: '1',
          phone: '9876543210',
          name: 'Priyanjali Chawla',
          age: 26,
          height: "5'5\"",
          caste: 'Chawla',
          profession: 'Senior Product Designer',
          company: 'Apple Inc.',
          location: 'Mumbai, Maharashtra',
          education: 'MS in HCI, Georgia Tech',
          bio: 'Design enthusiast who loves minimalism, traveling to Nordic countries, and standard filter coffees. Believes in balancing Sindhi heritage with progressive global views.',
          compatibilityScore: 98,
          gradientColors: [const Color(0xFFE0C3FC), const Color(0xFF8EC5FC)],
          initials: 'PC',
          fathersOccupation: 'Real Estate Developer',
          incomeBracket: '20+ Lakhs',
          professionSector: 'Corporate Job',
          photos: ['https://randomuser.me/api/portraits/women/5.jpg', 'https://randomuser.me/api/portraits/women/9.jpg'],
        ),
        Profile(
          id: '2',
          phone: '9876543211',
          name: 'Ritik Lalwani',
          age: 28,
          height: "5'11\"",
          caste: 'Lalwani',
          profession: 'Co-Founder & CEO',
          company: 'Fintech Unicorn',
          location: 'Bangalore, Karnataka',
          education: 'B.Tech, IIT Bombay',
          bio: 'Building systems to democratize credit in India. Passionate about scaling startups, writing tech blogs, and playing classical piano. Looking for a partner who is driven and empathetic.',
          compatibilityScore: 95,
          gradientColors: [const Color(0xFFFEE140), const Color(0xFFFA709A)],
          initials: 'RL',
          fathersOccupation: 'Retired Textile Merchant',
          incomeBracket: '20+ Lakhs',
          professionSector: 'Business',
          photos: ['https://randomuser.me/api/portraits/men/11.jpg'],
        ),
        Profile(
          id: '3',
          phone: '9876543212',
          name: 'Hiteshi Sadhwani',
          age: 27,
          height: "5'6\"",
          caste: 'Sadhwani',
          profession: 'Investment Banking Associate',
          company: 'Goldman Sachs',
          location: 'Mumbai, Maharashtra',
          education: 'MBA, ISB Hyderabad',
          bio: 'Analyzes markets by day, paints abstract art by night. Love exploring boutique cafes in Dubai and reading philosophy. Looking for a sincere companion to build a beautiful life.',
          compatibilityScore: 92,
          gradientColors: [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
          initials: 'HS',
          fathersOccupation: 'Diamond Merchant',
          incomeBracket: '20+ Lakhs',
          professionSector: 'Corporate Job',
          photos: ['https://randomuser.me/api/portraits/women/16.jpg'],
        ),
        Profile(
          id: '4',
          phone: '9876543213',
          name: 'Karan Gidwani',
          age: 29,
          height: "6'0\"",
          caste: 'Gidwani',
          profession: 'Software Architect',
          company: 'Google LLC',
          location: 'Ahmedabad, Gujarat',
          education: 'MS in CS, Stanford University',
          bio: 'AI researcher and open-source contributor. Weekend runner and trekker. Looking for someone with a scientific temperament, a warm heart, and a love for deep conversations.',
          compatibilityScore: 90,
          gradientColors: [const Color(0xFFFA8BFF), const Color(0xFF2BD2FF), const Color(0xFF2BFF88)],
          initials: 'KG',
          fathersOccupation: 'Senior Cardiologist',
          incomeBracket: '20+ Lakhs',
          professionSector: 'Corporate Job',
          photos: ['https://randomuser.me/api/portraits/men/12.jpg', 'https://randomuser.me/api/portraits/men/15.jpg'],
        ),
        Profile(
          id: '5',
          phone: '9876543214',
          name: 'Mehak Vaswani',
          age: 25,
          height: "5'4\"",
          caste: 'Vaswani',
          profession: 'Pediatric Resident',
          company: 'Lilavati Hospital',
          location: 'Mumbai, Maharashtra',
          education: 'MD, KEM Hospital Mumbai',
          bio: 'Dedicated to children\'s healthcare. Enjoys gardening, baking artisanal sourdoughs, and family gatherings. Looking for a family-oriented, kind-hearted gentleman.',
          compatibilityScore: 88,
          gradientColors: [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
          initials: 'MV',
          fathersOccupation: 'Industrialist (Chemicals)',
          incomeBracket: '10-20 Lakhs',
          professionSector: 'Corporate Job',
          photos: ['https://randomuser.me/api/portraits/women/19.jpg'],
        ),
        Profile(
          id: '6',
          phone: '9876543215',
          name: 'Varun Mulchandani',
          age: 30,
          height: "5'9\"",
          caste: 'Mulchandani',
          profession: 'VP of Real Estate',
          company: 'Mulchandani Group',
          location: 'Ahmedabad, Gujarat',
          education: 'B.Sc in Economics, Wharton School',
          bio: 'Oversees asset portfolios. Passionate about architecture, sailing, and golf. Believes that mutual respect and shared laughter are the pillars of a long-lasting marriage.',
          compatibilityScore: 85,
          gradientColors: [const Color(0xFFF6D365), const Color(0xFFFDA085)],
          initials: 'VM',
          fathersOccupation: 'Chairman, Mulchandani Group',
          incomeBracket: '20+ Lakhs',
          professionSector: 'Business',
          photos: ['https://randomuser.me/api/portraits/men/33.jpg'],
        ),
      ];
}
