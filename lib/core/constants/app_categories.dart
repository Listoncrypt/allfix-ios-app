import 'package:flutter/material.dart';

enum CategoryWorkflowType {
  property,
  car,
  construction,
  general,
}

class ServiceCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final CategoryWorkflowType workflowType;
  final List<String> popularServices;

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.workflowType,
    required this.popularServices,
  });
}

class AppCategories {
  AppCategories._();

  static const List<ServiceCategory> allCategories = [
    ServiceCategory(
      id: 'property_sales_rentals',
      title: 'Property Sales & Rentals',
      description: 'Verified apartments, duplexes, land, and commercial leasing.',
      icon: Icons.apartment_outlined,
      workflowType: CategoryWorkflowType.property,
      popularServices: [
        'Buy Duplex / Bungalow',
        'Rent Luxury Apartment',
        'Commercial Shop / Office Lease',
        'Shortlet Booking',
        'Land Acquisition'
      ],
    ),
    ServiceCategory(
      id: 'beauty_grooming',
      title: 'Beauty & Personal Grooming',
      description: 'Barbers, nail technicians, hair braiding, and frontal installations.',
      icon: Icons.content_cut,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Barber Home Visit',
        'Nail Tech (Acrylic / Gel)',
        'Hair Braiding & Weaving',
        'Wig & Frontal Installation',
        'Bridal Makeup'
      ],
    ),
    ServiceCategory(
      id: 'wellness_fitness',
      title: 'Wellness & Fitness',
      description: 'Home massage, physical therapy, and fitness trainers.',
      icon: Icons.fitness_center,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Swedish / Deep Tissue Massage',
        'Physical Therapy & Rehab',
        'Personal Fitness Coach',
        'Yoga & Posture Specialist'
      ],
    ),
    ServiceCategory(
      id: 'interior_decoration',
      title: 'Interior Decoration & Design',
      description: 'Home & office styling, wallpaper, furniture design, and 3D modeling.',
      icon: Icons.chair_outlined,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        '3D Interior Architectural Plan',
        'Curtain & Blind Installation',
        'Wallpaper & POP Accents',
        'Custom Furniture Fabrication'
      ],
    ),
    ServiceCategory(
      id: 'events_catering',
      title: 'Events & Catering',
      description: 'Event planning, sound/decor, catering, and personal cooks.',
      icon: Icons.celebration_rounded,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Private Chef / Meal Prep',
        'Event Sound & Lighting',
        'Party Decoration & Styling',
        'Outdoor Catering (Buffet / Small Chops)'
      ],
    ),
    ServiceCategory(
      id: 'visa_travel',
      title: 'Visa & Travel Assistance',
      description: 'Visa application guidance, documentation audit, and flight consultation.',
      icon: Icons.flight_outlined,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Visa Document Audit',
        'SOP & Cover Letter Review',
        'Travel Itinerary & Booking Advice',
        'Yellow Card & Travel Insurance'
      ],
    ),
    ServiceCategory(
      id: 'medical_virtual',
      title: 'Medical Virtual Assistance',
      description: 'Clinic administration, patient intake, and telehealth coordination.',
      icon: Icons.local_hospital_outlined,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Virtual Telehealth Concierge',
        'Prescription Medication Pickup',
        'Elderly Check-in Scheduling'
      ],
    ),
    ServiceCategory(
      id: 'home_services',
      title: 'Home Services',
      description: 'Plumbing, electrical wiring, carpentry, painting, and tiling.',
      icon: Icons.plumbing_rounded,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Pipe Leak & Drainage Clearing',
        'Electrical Distribution Box Fix',
        'Furniture Repair / Carpentry',
        'Interior & Exterior Painting'
      ],
    ),
    ServiceCategory(
      id: 'cars_vehicles',
      title: 'Cars & Vehicles',
      description: 'Automobile mechanics, computer diagnostics, EV systems, and auto AC.',
      icon: Icons.directions_car_outlined,
      workflowType: CategoryWorkflowType.car,
      popularServices: [
        'OBD-II Computer Diagnostic Scan',
        'Engine & Transmission Overhaul',
        'Auto AC Gas Refill & Compressor',
        'Brake Pad & Suspension Overhaul',
        'Electric Vehicle (EV) Checkup'
      ],
    ),
    ServiceCategory(
      id: 'construction_land',
      title: 'Construction & Land',
      description: 'Civil construction, architectural CAD, and verified land scouting.',
      icon: Icons.foundation_rounded,
      workflowType: CategoryWorkflowType.construction,
      popularServices: [
        'Architectural Blueprint Drawing',
        'Structural Building from Foundation',
        'Scout Verified Land with C of O',
        'Site Soil Test & Topography Survey'
      ],
    ),
    ServiceCategory(
      id: 'property_maintenance',
      title: 'Property Maintenance',
      description: 'Roofing, borehole drilling, solar inverters, and water treatment.',
      icon: Icons.home_repair_service_rounded,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Solar Inverter & Lithium Battery Setup',
        'Borehole Drilling & Submersible Pump',
        'Roof Leak Sealing',
        'Water Treatment Plant Installation'
      ],
    ),
    ServiceCategory(
      id: 'cleaning_janitorial',
      title: 'Cleaning & Janitorial',
      description: 'Deep residential cleaning, post-construction, and fumigation.',
      icon: Icons.cleaning_services_rounded,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Post-Construction Deep Cleaning',
        'Sofa & Rug Extraction Wash',
        'Fumigation & Pest Extermination',
        'Regular Apartment Clean'
      ],
    ),
    ServiceCategory(
      id: 'appliance_repairs',
      title: 'Appliance Repairs',
      description: 'Air conditioners, generators, refrigerators, and washing machines.',
      icon: Icons.kitchen_rounded,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Generator Servicing (Mikano/Lister/Tiger)',
        'Inverter AC Diagnosis & Gas Refill',
        'Refrigerator & Freezer Repair',
        'Automatic Washing Machine Fix'
      ],
    ),
    ServiceCategory(
      id: 'certified_spare_parts',
      title: 'Products & Certified Spare Parts',
      description: 'Genuine automobile parts, plumbing fixtures, and electrical hardware.',
      icon: Icons.precision_manufacturing_rounded,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'OEM Japanese Car Parts',
        'Original Copper Cables & Breakers',
        'Brass Plumbing Fittings',
        'Solar Panels & Regulators'
      ],
    ),
    ServiceCategory(
      id: 'specialist_services',
      title: 'Other Specialist Services',
      description: 'Custom bespoke technical assignments and unique service requests.',
      icon: Icons.miscellaneous_services_rounded,
      workflowType: CategoryWorkflowType.general,
      popularServices: [
        'Custom Technical Installation',
        'CCTV & Smart Lock Integration',
        'Intercom & Office Networking',
        'General Artisan Dispatch'
      ],
    ),
  ];
}
