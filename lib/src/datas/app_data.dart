import 'package:beanstalk_mobile/src/models/canna_condition_model.dart';
import 'package:beanstalk_mobile/src/models/canna_feel_model.dart';
import 'package:beanstalk_mobile/src/models/canna_measurement_model.dart';
import 'package:beanstalk_mobile/src/models/canna_productType_model.dart';
import 'package:beanstalk_mobile/src/models/canna_symptom_model.dart';
import 'package:beanstalk_mobile/src/models/canna_medication_model.dart';
import 'package:beanstalk_mobile/src/models/canna_strainType_model.dart';
import 'package:beanstalk_mobile/src/models/canna_cannabinoid_model.dart';
import 'package:beanstalk_mobile/src/models/canna_terpene_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_additional_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_education_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_employment_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_ethnicity_model.dart';
import 'package:beanstalk_mobile/src/models/lumir_study/lumir_marital_model.dart';

import '../models/canna_deliveryMethod_model.dart';

class AppData {
  //Condition List
  static List<Condition> dataConditions = [
    Condition(title: "Addiction", icon: "icon_addiction.png"),
    Condition(title: "ADHD", icon: "icon_adhd.png"),
    Condition(title: "AIDS", icon: "icon_aids.png"),
    Condition(title: "Aizheimer's", icon: "icon_aizheimer.png"),
    Condition(title: "Anorexia", icon: "icon_anorexia.png"),
    Condition(title: "Anxiety", icon: "icon_anxiety.png"),
    Condition(title: "Autism", icon: "icon_autism.png"),
    Condition(title: "Cancer", icon: "icon_cancer.png"),
    Condition(title: "Chemotherapy-Induced Nausea And Vomiting", icon: "icon_chemotherapyInducedNauseaAndVomiting.png"),
    Condition(title: "Chronic Infection", icon: "icon_chronicInfection.png"),
    Condition(title: "Chronic Pain", icon: "icon_chronicpain.png"),
    Condition(title: "Chronic Regional Pain Syndrome", icon: "icon_chronicRegionalPainSyndrome.png"),
    Condition(title: "Crohn's Disease", icon: "icon_crohns.png"),
    Condition(title: "Dementia", icon: "icon_dementia.png"),
    Condition(title: "Depression", icon: "icon_depression.png"),
    Condition(title: "Diabetes Type 1", icon: "icon_diabetesType1.png"),
    Condition(title: "Dystonia", icon: "icon_dystonia.png"),
    Condition(title: "Epilepsy", icon: "icon_epilepsy.png"),
    Condition(title: "Fibromyalgia", icon: "icon_fiblomyalgia.png"),
    Condition(title: "Gloucoma", icon: "icon_glaucoma.png"),
    Condition(title: "Hepatitis C", icon: "icon_hepatitis.png"),
    Condition(title: "Hepatitis B", icon: "icon_hepatitisB.png"),
    Condition(title: "HIV", icon: "icon_hiv.png"),
    Condition(title: "Huntington's Disease", icon: "icon_huntingtonsDisease.png"),
    Condition(title: "Inflammatory Bowel Disease: Ulcerative Colitis", icon: "icon_inflammatoryBowelDiseaseUlcerativeColitis.png"),
    Condition(title: "Intractable Nausea and Vomiting", icon: "icon_nausea.png"),
    Condition(title: "Insomnia", icon: "icon_insomnia.png"),
    Condition(title: "Irritable Bowel Syndrome (IBS)", icon: "icon_intractableBowel.png"),
    Condition(title: "Long Covid", icon: "icon_longCovid.png"),
    Condition(title: "Lou Gehrig's Disease (ALS)", icon: "icon_als.png"),
    Condition(title: "Migraines", icon: "icon_migraine.png"),
    Condition(title: "Multiple Sclerosis", icon: "icon_sclerosis.png"),
    Condition(title: "Muscle Spasms", icon: "icon_muscle.png"),
    Condition(title: "Neuropathy", icon: "icon_neuropathy.png"),
    Condition(title: "Osteoarthritis", icon: "icon_osteoarthritis.png"),
    Condition(title: "Panic Attack", icon: "icon_panicAttack.png"),
    Condition(title: "Parkinsons Disease", icon: "icon_parkinsons.png"),
    Condition(title: "PTSD", icon: "icon_ptsd.png"),
    Condition(title: "Period Pain (Primary Dysmenorrhoea)", icon: "icon_periodPain.png"),
    Condition(title: "Polymyalgia Rheumatica", icon: "icon_polymyalgiaRheumatica.png"),
    Condition(title: "Psychosis", icon: "icon_psychosis.png"),
    Condition(title: "Radiculopathies", icon: "icon_radiculopathies.png"),
    Condition(title: "Rheumatoid Arthritis", icon: "icon_rheumatoidArthritis.png"),
    Condition(title: "Schizophrenia", icon: "icon_schizophrenia.png"),
    Condition(title: "Seizures", icon: "icon_seizures.png"),
    Condition(title: "Sleep Apnoea", icon: "icon_sleepApnoea.png"),
    Condition(title: "Spasticity Associated With Ms", icon: "icon_spasticityAssociatedWithMs.png"),
    Condition(title: "Spasticity Associated With Spinal Cord Injury", icon: "icon_spasticityAssociatedWithSpinalCordInjury.png"),
    Condition(title: "Tinnitus", icon: "icon_tinnitus.png"),
    Condition(title: "Tourette Syndrome", icon: "icon_touretteSyndrome.png"),
    Condition(title: "Traumatic Brain Injury", icon: "icon_traumaticBrain.png"),
    Condition(title: "Tremors", icon: "icon_tremors.png"),
    Condition(title: "Other Medical Conditions", icon: "icon_otherMedicalConditions.png"),
    Condition(title: "Recreational Use", icon: "icon_recreationalUse.png"),
  ];

  //Sympthom List
  static List<Symptom> dataSympthoms = [
    Symptom(title: "Anxiety"),
    Symptom(title: "Arthritis"),
    Symptom(title: "Pain"),
    Symptom(title: "Insomnia"),
    Symptom(title: "Migraine"),
    Symptom(title: "Acute Injury"),
    Symptom(title: "Back Pain"),
    Symptom(title: "Carpal Tunnel"),
    Symptom(title: "Detached"),
    Symptom(title: "Distracted"),
    Symptom(title: "Fatigue"),
    Symptom(title: "Headaches"),
    Symptom(title: "Hyper"),
    Symptom(title: "Impulsive"),
    Symptom(title: "Joint Pain"),
    Symptom(title: "Inflammation"),
    Symptom(title: "Joint Swelling"),
    Symptom(title: "Lack of Appettite"),
    Symptom(title: "Loss of Appetite"),
    Symptom(title: "Loss of Focus"),
    Symptom(title: "Muscle Spasms"),
    Symptom(title: "Nausea"),
    Symptom(title: "Sinus Pain"),
    Symptom(title: "Sleep Issues"),
    Symptom(title: "Tendonitis"),
    Symptom(title: "Other"),
    Symptom(title: "None"),
  ];

  //Product Type List
  static List<ProductType> dataProductTypes = [
    ProductType(title: "Flower", description: "Smoke via joint, pipe, bong or vape", icon: "icon_flower.png"),
    ProductType(title: "Vape Cartridges", description: "Smokeless inhaled", icon: "icon_vape.png"),
    ProductType(title: "Oil/Extract", description: "Oils, Tinctures, Liquids for Oral Consumption", icon: "icon_tinctures.png"),
    ProductType(title: "Pill/Capsule", description: "Softgels, Tablets, Pills", icon: "icon_pills.png"),
    ProductType(title: "Wafer", description: "Sublingual wafers dissolved under the tongue", icon: "icon_wafer.png"),
    ProductType(title: "Intranasal Spray", description: "Sprayed up the nose", icon: "icon_spray.png"),
    ProductType(title: "Edibles", description: "Infused Food or Drink", icon: "icon_edibles.png"),
    ProductType(title: "Topicals", description: "Skin Lotions, Balms or Creams", icon: "icon_topical.png"),
    ProductType(title: "Suppositories", description: "Rectal, Vaginal", icon: "icon_suppository.png"),
    ProductType(title: "Resin", description: "Hash Oil, High Concentration Resin for Dabbing", icon: "icon_resin.png"),
  ];

  //Delivery Methods for Product Type
  List<DeliveryMethod> deliveryMethods(String? productType) {
    switch (productType) {
      case "Flower":
        return [
          DeliveryMethod(title: "Vape Device"),
          DeliveryMethod(title: "Joint"),
          DeliveryMethod(title: "Pipe"),
          DeliveryMethod(title: "Bong"),
        ];

      case "Vape Cartridges":
        return [
          DeliveryMethod(title: "N/A"),
        ];

      case "Oil/Extract":
        return [
          DeliveryMethod(title: "Oral"),
          DeliveryMethod(title: "Vape"),
          DeliveryMethod(title: "Dabbing"),
        ];

      case "Pill/Capsule":
        return [
          DeliveryMethod(title: "Softgels"),
          DeliveryMethod(title: "Tablets"),
          DeliveryMethod(title: "Pill/Capsule"),
        ];

      case "Wafer":
        return [
          DeliveryMethod(title: "Oral"),
        ];

      case "Intranasal Spray":
        return [
          DeliveryMethod(title: "Intranasal"),
        ];

      case "Edibles":
        return [
          DeliveryMethod(title: "Gummies"),
          DeliveryMethod(title: "Mints"),
          DeliveryMethod(title: "Drinks"),
          DeliveryMethod(title: "Chocolates"),
          DeliveryMethod(title: "Cookies"),
          DeliveryMethod(title: "Other"),
        ];

      case "Topicals":
        return [
          DeliveryMethod(title: "Skin Lotions"),
          DeliveryMethod(title: "Balms"),
          DeliveryMethod(title: "Creams"),
        ];
      case "Suppositories":
        return [
          DeliveryMethod(title: "Vaginal"),
          DeliveryMethod(title: "Rectal"),
        ];

      case "Resin":
        return [
          DeliveryMethod(title: "Dabbing"),
        ];

      default:
        return [
          DeliveryMethod(title: "N/A"),
        ];
    }
  }

  //Medication List
  static List<Medication> dataMedications = [
    Medication(title: "Flower", description: "Smoke via joint, pipe, bong or vape", icon: "icon_flower.png"),
    Medication(title: "Vape Cartridges", description: "Smokeless inhaled", icon: "icon_vape.png"),
    Medication(title: "Oil/Extract", description: "Oils, Tinctures, Liquids for Oral Consumption", icon: "icon_tinctures.png"),
    Medication(title: "Pill/Capsule", description: "Softgels, Tablets, Pills", icon: "icon_pills.png"),
    Medication(title: "Wafer", description: "Sublingual wafers dissolved under the tongue", icon: "icon_wafer.png"),
    Medication(title: "Intranasal Spray", description: "Sprayed up the nose", icon: "icon_spray.png"),
    Medication(title: "Edibles", description: "Infused Food or Drink", icon: "icon_edibles.png"),
    Medication(title: "Topicals", description: "Skin Lotions, Balms or Creams", icon: "icon_topical.png"),
    Medication(title: "Suppositories", description: "Rectal, Vaginal", icon: "icon_suppository.png"),
    Medication(title: "Resin", description: "Hash Oil, High Concentration Resin for Dabbing", icon: "icon_resin.png"),
  ];

  //Medication Non Cannabis List
  static List<Medication> dataMedicationsNonCannabis = [
    Medication(title: "Flower", description: "Smoke via joint, pipe, bong or vape", icon: "icon_flower.png"),
    Medication(title: "Vape Cartridges", description: "Smokeless inhaled", icon: "icon_vape.png"),
    Medication(title: "Oil/Extract", description: "Oils, Tinctures, Liquids for Oral Consumption", icon: "icon_tinctures.png"),
    Medication(title: "Pill/Capsule", description: "Softgels, Tablets, Pills", icon: "icon_pills.png"),
    Medication(title: "Wafer", description: "Sublingual wafers dissolved under the tongue", icon: "icon_wafer.png"),
    Medication(title: "Intranasal Spray", description: "Sprayed up the nose", icon: "icon_spray.png"),
    Medication(title: "Edibles", description: "Infused Food or Drink", icon: "icon_edibles.png"),
    Medication(title: "Topicals", description: "Skin Lotions, Balms or Creams", icon: "icon_topical.png"),
    Medication(title: "Suppositories", description: "Rectal, Vaginal", icon: "icon_suppository.png"),
    Medication(title: "Resin", description: "Hash Oil, High Concentration Resin for Dabbing", icon: "icon_resin.png"),
  ];

  //Strain Type List
  static List<StrainType> dataStrainTypes = [
    StrainType(title: "Indica", icon: "I"),
    StrainType(title: "Sativa", icon: "S"),
    StrainType(title: "Hybrid", icon: "H"),
    StrainType(title: "Unknown", icon: "-"),
  ];

  //Cannabinoids List
  static List<Cannabinoid> dataCannabinoids = [
    Cannabinoid(title: "CBN"),
    Cannabinoid(title: "CBG"),
    Cannabinoid(title: "CBC"),
    Cannabinoid(title: "THCa"),
    Cannabinoid(title: "THCv"),
    Cannabinoid(title: "THCva"),
    Cannabinoid(title: "CBDa"),
    Cannabinoid(title: "CBGa"),
  ];

  //Terpenes List
  static List<Terpene> dataTerpenes = [
    Terpene(title: "Pinene"),
    Terpene(title: "Myrcene"),
    Terpene(title: "Linalool"),
    Terpene(title: "Limonene"),
    Terpene(title: "Humulene"),
    Terpene(title: "Guaiol"),
    Terpene(title: "Caryophyllene"),
    Terpene(title: "Borneol"),
    Terpene(title: "Bisabolol"),
    Terpene(title: "Ocimene"),
    Terpene(title: "Terpineolene"),
  ];

  static List<Measurement> dataMeasurements = [
    Measurement(title: "%"),
    Measurement(title: "mg/ml"),
  ];
  //Measurement List
  static List<Measurement> dataMeasurementsGroup1 = [Measurement(title: "%"), Measurement(title: "mg")];
  static List<Measurement> dataMeasurementsGroup2 = [Measurement(title: "%"), Measurement(title: "mg"), Measurement(title: "mg/ml")];
  static List<Measurement> dataMeasurementsGroup3 = [Measurement(title: "mg/serving"), Measurement(title: "mg/ml")];

  static List<Measurement> dataDoseMeasurementsSmoke = [
    Measurement(title: "inhalations", increment: 1, minScale: 0, maxScale: 10, isDecimal: false),
    Measurement(title: "grams", increment: 0.1, minScale: 0.0, maxScale: 1, isDecimal: true)
  ];
  static List<Measurement> dataDoseMeasurementsVape = [
    Measurement(title: "inhalations", increment: 1, minScale: 0, maxScale: 15, isDecimal: false),
    Measurement(title: "grams", increment: 0.1, minScale: 0.0, maxScale: 1.0, isDecimal: true)
  ];
  static List<Measurement> dataDoseMeasurementsTopical = [
    Measurement(title: "fingertip units", increment: 1, minScale: 0, maxScale: 10, isDecimal: false)
  ];
  static List<Measurement> dataDoseMeasurementsEdibles = [
    Measurement(title: "mg", increment: 0.5, minScale: 0.0, maxScale: 50, isDecimal: true),
    Measurement(title: "servings", increment: 0.5, minScale: 0, maxScale: 10, isDecimal: true)
  ];
  static List<Measurement> dataDoseMeasurementsTinctures = [
    Measurement(title: "drops", increment: 1, minScale: 0, maxScale: 20, isDecimal: false),
    Measurement(
      title: "ml",
      increment: 0.05,
      minScale: 0,
      maxScale: 5,
      isDecimal: true,
    )
  ];
  static List<Measurement> dataDoseMeasurementsDabbing = [
    Measurement(title: "inhalations", increment: 1, minScale: 0, maxScale: 10, isDecimal: false)
  ];

  //Terpenes List
  static List<Feel> dataFeels = [
    Feel(title: "Anxious"),
    Feel(title: "Clear"),
    Feel(title: "Comfy"),
    Feel(title: "Couchlocked"),
    Feel(title: "Creative"),
    Feel(title: "Dizzy"),
    Feel(title: "Dreamy"),
    Feel(title: "Dry mouth"),
    Feel(title: "Energetic"),
    Feel(title: "Focused"),
    Feel(title: "Foggy"),
    Feel(title: "Forgetful"),
    Feel(title: "Frisky"),
    Feel(title: "Great"),
    Feel(title: "Hungry"),
    Feel(title: "Light"),
    Feel(title: "Peaceful"),
    Feel(title: "Reflective"),
    Feel(title: "Relaxed"),
    Feel(title: "Restless"),
    Feel(title: "Sleepy"),
    Feel(title: "Talkative"),
    Feel(title: "Thirsty"),
    Feel(title: "Tuned"),
  ];

  List<Measurement> doseMeasurements(String? productType) {
    switch (productType) {
      case "Flower":
      case "Vape Cartridges":
      case "Intranasal Spray":
      case "Resin":
        return [
          Measurement(title: "Inhalations", increment: 1, minScale: 1, maxScale: 20, isDecimal: false),
        ];

      case "Oil/Extract":
        return [
          Measurement(title: "ml", increment: 1, minScale: 1, maxScale: 50, isDecimal: false),
        ];

      case "Pill/Capsule":
      case "Wafer":
      case "Edibles":
      case "Topicals":
      case "Suppositories":
        return [
          Measurement(title: "Total", increment: 1, minScale: 1, maxScale: 5, isDecimal: false),
        ];

      default:
        return [
          Measurement(title: "mg", increment: 1, minScale: 1, maxScale: 50, isDecimal: false),
        ];
    }
  }

  Measurement lumirDoseMeasurement(String? units) {
    switch (units) {
      case "mg/ml":
        return Measurement(title: "mg/ml", increment: 0.5, minScale: 0.0, maxScale: 15, isDecimal: true);

      case "mg":
        return Measurement(title: "mg", increment: 0.5, minScale: 0.0, maxScale: 15, isDecimal: true);

      case "ml":
        return Measurement(
          title: "ml",
          increment: 0.05,
          minScale: 0,
          maxScale: 5,
          isDecimal: true,
        );
      case "g":
        return Measurement(title: "grams", increment: 0.1, minScale: 0.0, maxScale: 1.0, isDecimal: true);
      default:
        return Measurement();
    }
  }

  static List<int> dataNotificationTimes = [15, 30, 45, 60];

  //Icons Gender
  String iconGender(String gender) {
    switch (gender.toLowerCase()) {
      case "male":
        return "icon_profile_male.png";
      case "female":
        return "icon_profile_female.png";
      case "fluid":
        return "icon_profile_fluid.png";
      default:
        return "icon_profile_self.png";
    }
  }

  //Icons Conditions
  String iconCondition(String title) {
    switch (title.toLowerCase()) {
      case "addiction":
        return "icon_addiction.png";
      case "adhd":
        return "icon_adhd.png";
      case "aids":
        return "icon_aids.png";
      case "aizheimer's":
        return "icon_aizheimer.png";
      case "anorexia":
        return "icon_anorexia.png";
      case "anxiety":
        return "icon_anxiety.png";
      case "autism":
        return "icon_autism.png";
      case "cancer":
        return "icon_cancer.png";
      case "chemotherapy-induced nausea and vomiting":
        return "icon_chemotherapyInducedNauseaAndVomiting.png";
      case "chronic infection":
        return "icon_chronicInfection.png";
      case "chronic pain":
        return "icon_chronicpain.png";
      case "chronic regional pain syndrome":
        return "icon_chronicRegionalPainSyndrome.png";
      case "crohn's disease":
        return "icon_crohns.png";
      case "dementia":
        return "icon_dementia.png";
      case "depression":
        return "icon_depression.png";
      case "diabetes type 1":
        return "icon_diabetesType1.png";
      case "dystonia":
        return "icon_dystonia.png";
      case "epilepsy":
        return "icon_epilepsy.png";
      case "fibromyalgia":
        return "icon_fiblomyalgia.png";
      case "gloucoma":
        return "icon_glaucoma.png";
      case "hepatitis c":
        return "icon_hepatitis.png";
      case "hepatitis b":
        return "icon_hepatitisB.png";
      case "hiv":
        return "icon_hiv.png";
      case "huntington's disease":
        return "icon_huntingtonsDisease.png";
      case "inflammatory bowel disease: ulcerative colitis":
        return "icon_inflammatoryBowelDiseaseUlcerativeColitis.png";
      case "intractable nausea and vomiting":
        return "icon_nausea.png";
      case "insomnia":
        return "icon_insomnia.png";
      case "irritable bowel syndrome (ibs)":
        return "icon_intractableBowel.png";
      case "long covid":
        return "icon_longCovid.png";
      case "lou gehrig's disease (als)":
        return "icon_als.png";
      case "migraines":
        return "icon_migraine.png";
      case "multiple sclerosis":
        return "icon_sclerosis.png";
      case "muscle spasms":
        return "icon_muscle.png";
      case "neuropathy":
        return "icon_neuropathy.png";
      case "osteoarthritis":
        return "icon_osteoarthritis.png";
      case "panic attack":
        return "icon_panicAttack.png";
      case "parkinsons disease":
        return "icon_parkinsons.png";
      case "ptsd":
        return "icon_ptsd.png";
      case "period pain (primary dysmenorrhoea)":
        return "icon_periodPain.png";
      case "polymyalgia rheumatica":
        return "icon_polymyalgiaRheumatica.png";
      case "psychosis":
        return "icon_psychosis.png";
      case "radiculopathies":
        return "icon_radiculopathies.png";
      case "rheumatoid arthritis":
        return "icon_rheumatoidArthritis.png";
      case "schizophrenia":
        return "icon_schizophrenia.png";
      case "seizures":
        return "icon_seizures.png";
      case "sleep apnoea":
        return "icon_sleepApnoea.png";
      case "spasticity associated with ms":
        return "icon_spasticityAssociatedWithMs.png";
      case "spasticity associated with spinal cord injury":
        return "icon_spasticityAssociatedWithSpinalCordInjury.png";
      case "tinnitus":
        return "icon_tinnitus.png";
      case "tourette syndrome":
        return "icon_touretteSyndrome.png";
      case "traumatic brain injury":
        return "icon_traumaticBrain.png";
      case "tremors":
        return "icon_tremors.png";
      case "other medical conditions":
        return "icon_otherMedicalConditions.png";
      case "recreational use":
        return "icon_recreationalUse.png";
      default:
        return "icon_condition.png";
    }
  }

  //Icons productType
  String iconProductType(String title) {
    switch (title.toLowerCase()) {
      case "flower":
        return "icon_flower.png";
      case "vape cartridges":
        return "icon_vape.png";
      case "oil/extract":
        return "icon_tinctures.png";
      case "pill/capsule":
        return "icon_pills.png";
      case "wafer":
        return "icon_wafer.png";
      case "intranasal spray":
        return "icon_spray.png";
      case "edibles":
        return "icon_edibles.png";
      case "topicals":
        return "icon_topical.png";
      case "topical":
        return "icon_topical.png";
      case "suppositories":
        return "icon_suppository.png";
      case "resin":
        return "icon_resin.png";
      case "tinctures":
        return "icon_tinctures.png";
      default:
        return "icon_cannabis.png";
    }
  }

  //Icons Medication
  String iconMedication(String title) {
    switch (title.toLowerCase()) {
      case "inhale":
        return "icon_inhale.png";
      case "vape":
        return "icon_vape.png";
      case "edibles":
        return "icon_edibles.png";
      case "tinctures":
        return "icon_tinctures.png";
      case "dabbing":
        return "icon_dab.png";
      case "topical":
        return "icon_topical.png";
      case "suppository":
        return "icon_suppository.png";
      case "pill/capsule":
        return "icon_pills.png";
      default:
        return "icon_default.png";
    }
  }

  //Icons Rate
  String iconRate(int rate) {
    switch (rate) {
      case 4:
        return "icon_feel_great.png";

      case 3:
        return "icon_feel_good.png";

      case 2:
        return "icon_feel_ok.png";

      default:
        return "icon_feel_notgood.png";
    }
  }

  //LUMIR STUDY
  //Ethnicity List
  static List<Ethnicity> dataEthnicites = [
    Ethnicity(title: "African American"),
    Ethnicity(title: "Asian"),
    Ethnicity(title: "Australian Aboriginal or Torres Strait Islander"),
    Ethnicity(title: "Caucasian"),
    Ethnicity(title: "Latin American"),
    Ethnicity(title: "Native American"),
    Ethnicity(title: "Other"),
  ];

  //Marital Status List
  static List<Marital> dataMaritals = [
    Marital(title: "Unmarried"),
    Marital(title: "Married"),
    Marital(title: "Divorced"),
    Marital(title: "Living as Married"),
    Marital(title: "Separated"),
    Marital(title: "Windowed"),
  ];

  //Employment Status List
  static List<Employment> dataEmployments = [
    Employment(title: "Full-time employment"),
    Employment(title: "Part-time employment"),
    Employment(title: "Unemployed"),
    Employment(title: "Self-employed"),
    Employment(title: "Home-maker"),
    Employment(title: "Student"),
    Employment(title: "Retired"),
  ];

  //Employment Status List
  static List<Education> dataEducations = [
    Education(title: "None at All"),
    Education(title: "Elementary School (Primary School)"),
    Education(title: "High School (Seconday School)"),
    Education(title: "Tertiary (College or University)"),
  ];

  //Employment Status List
  static List<Additional> dataAdditionals = [
    Additional(title: "Problems with sleep"),
    Additional(title: "Poor mood"),
    Additional(title: "Anxiety"),
    Additional(title: "Pain"),
    Additional(title: "Low Energy"),
  ];

  static String dataTermsOfServices =
      "The following terms and conditions (“Terms of Service”) constitute a legally binding agreement made between you, whether personally or on behalf of an entity (“you”) and Beanstalk (collectively, “Beanstalk” or “we” or “us” or “our”), governing your access to and use of the www.beanstalk.app website, as well as any other media form, media channel, mobile application (“Mobile App”) or mobile website related or connected thereto (collectively, the “Site”).  By visiting our Site, you engage in our “Services” and agree to be bound by these Terms of Service.  Supplemental terms and conditions or documents that may be posted on the Site from time to time, are hereby expressly incorporated into these Terms of Service by reference. Please read these Terms of Service carefully before accessing or using our Site.  By accessing, browsing, or otherwise using the Site, you agree to be bound by the following terms and conditions, including those additional terms and conditions and policies referenced or linked herein.  These Terms of Service apply to all users of the Site, including without limitation users who are browsers, vendors, customers, merchants, and/or contributors of content.  If you do not agree to all the terms and conditions contained herein, then you may not access the Site or use any Services.  If these Terms of Service are considered an offer, acceptance is expressly limited to these Terms of Service. Any new features or tools which are added to the current Site shall also be subject to the Terms of Service.  You can review the most current version of the Terms of Service at any time on this page.  We reserve the right to update, change or replace any part of these Terms of Service in our sole discretion by posting updates and/or changes to our Site.  It is your responsibility to check this page periodically for changes.  Your continued use of or access to the Site following the posting of any changes constitutes acceptance of those changes. By agreeing to these Terms of Service, you represent that you are at least 21 years old, and that your use of the Site or Services does not violate any applicable law or regulation, except, as discussed below, federal laws related to cannabis.  Any use of the Site or Services by persons under the age of 21 is strictly prohibited. YOU ACCEPT AND AGREE TO BE BOUND BY THESE TERMS BY CONTINUING TO USE THE SITE.  IF YOU DO NOT AGREE TO ABIDE BY THESE TERMS, OR TO MODIFICATIONS THAT BEANSTALK MAY MAKE TO THESE TERMS IN THE FUTURE, DO NOT USE OR ACCESS OR CONTINUE TO USE OR ACCESS THE SERVICES OR THE SITE" +
          "\nSAFETY ACKNOWLEDGMENT\nOn our Site, we provide information about certain products but do not offer any products for sale.  Our Site may collect information about a user’s experiences and preferences related to the consumption of cannabis or cannabis products.  You acknowledge that, as it pertains to cannabis, Beanstalk is only for residents of states and localities with laws regulating the medical or recreational use of cannabis.  Cannabis is a Schedule I controlled substance under the Controlled Substances Act, and, therefore, the possession, cultivation and distribution thereof, or conspiring with or assisting others to do the same, is federally illegal and can result in significant criminal and civil penalties.  You further acknowledge that medical use is not recognized as a valid defense under federal laws regulating cannabis, and that the interstate transportation of cannabis is a federal offense.  ENGAGING IN ACTIVITIES OR BUSINESS RELATED TO CANNABIS IS AT YOUR OWN RISK. Our Site may also collect information about a user’s experiences and preferences related to the consumption of hemp or hemp products, none of which are intended to diagnose, treat, cure or prevent any disease.  We recommend consulting with a doctor prior to using any such products.  Any statements made about products on the Site have not been evaluated by the FDA. By using the Site, you acknowledge the information contained in these Terms of Service, the information provided on the Site, and all of the documentation and literature included with any product included on the Site, was developed for informational and educational purposes only.  In no way is any of the information contained in these Terms of Service or elsewhere on the Site intended to be a medical or prescriptive guide or a substitute for informed medical advice or care.  If you believe or suspect that you have a medical problem, promptly contact your doctor or health care provider.  You should never delay seeking or disregard advice from a medical professional based on something you have read on the Site.  You and any other user of any product on the Site are solely responsible for the use of such product and the consequences of such use.  Any illegal use or resale of any products listed on the Site could subject you to fines, penalties and/or imprisonment under state and federal law. \nREGISTRATION AND USER INFORMATION\nIn order to register to use certain features of the Site you must complete the registration process to obtain a user account (“User Account”).  In order to obtain a User Account, you must provide your date of birth, gender, your e-mail address, and a username and password.  You will then be given the option to create a profile, in response to which, you may, but are not required to, provide your name, phone number, communication preferences, symptoms or conditions, previous experience with cannabis, and consumption preferences  (“User Information”).  You must provide complete and accurate information during the registration process and you have an ongoing obligation to update this information if and when it changes.  Our information collection and use policies with respect to your User Information, including any personal information, are set forth in our Privacy Policy, which is incorporated into these Terms of Service by reference.  An age verification check will occur when entering the Site and during the registration process in order to confirm that you are 21 years of age or older.  Only persons 21 years of age or older will be granted access to the Site. As stated above, in creating a User Account, you will be asked to provide a username and password.  You are solely responsible for maintaining the confidentiality of your password.  You may not use the User Account, username, or password of someone else at any time.  You are also solely responsible for any and all activities that occur under your registration or your User Information.  You agree to notify us immediately of any unauthorized use of your User Account, username, or password. You agree that you will not create more than one User Account.  By registering and obtaining a User Account you affirm you will follow the Terms of Service and your registration constitutes your consent to enter into agreements with us electronically. We shall not be liable for any loss that you incur as a result of someone else using your User Account, username, or password, either with or without your knowledge.  You may be held liable for any losses incurred by us, our affiliates, officers, directors, employees, consultants, agents, and representatives due to someone else’s use of your User Account, username, or password. We reserve the right to terminate your User Account or to refuse Services to you, without prior notice to you, at any time and for any or no reason.\nCONTENT\nThe content on the Site (“Content”) and the trademarks, and all logos contained therein are owned by or licensed by us and are subject to copyright and other intellectual property rights under applicable laws.  Content includes, without limitation, all source code, databases, functionality, software, mobile applications, website designs, audio, video, text, photographs, and graphics.  All graphics, logos, designs, page headers, button icons, scripts and service names are registered trademarks, common law trademarks or trade dress of ours or our partners.  These trademarks and trade dress may not be used, including as part of trademarks and/or as part of domain names, in connection with any product or service in any manner that is likely to cause confusion and may not be copied, imitated, or used, in whole or in part, without our prior written permission. Content on the Site is provided to you “AS IS” for your information and personal use only and may not be used, copied, reproduced, aggregated, distributed, transmitted, broadcast, displayed, sold, licensed, or otherwise exploited for any other purposes whatsoever without the prior written consent of the respective owners.  Provided that you are eligible to use the Site, you are granted a limited license to access and use the Site and the Content and to download or print a copy of any portion of the Content to which you have properly gained access solely for your personal, non-commercial use.  We reserve all rights not expressly granted to you in and to the Site and Content We are not responsible if Content is not accurate, complete, or current.  The Content is provided for general information only and should not be relied upon or used as the sole basis for making decisions without consulting primary, more accurate, more complete, or more timely sources of information.  Any reliance on Content is at your own risk.  We reserve the right to modify the Content at any time, but we have no obligation to update any information on our Site.\nMOBILE APPLICATION PLATFORMS\nThe availability of our Mobile App is dependent on the third-party mobile application platform (“Mobile App Platform”) from which you received and downloaded the Mobile App.  The agreement set forth in these Terms of Service is between you and Beanstalk and not with the Mobile App Platform.  Beanstalk is solely responsible for the Site and Services, including the Mobile App, including all content, maintenance, support services, and claims relating thereto.  You agree to pay all fees, if any, charged by the Mobile App Platform in connection with your download and/or use of the Mobile App.  You may be required to agree to each Mobile App Platform’s own terms and conditions prior to downloading the Mobile App, and your ability to utilize a Mobile App may be conditioned upon your compliance with such terms and conditions.  Any such Mobile App Platform may be considered a third-party beneficiary of the Terms of Service.\nTHIRD-PARTY LINKS\nCertain Content and Services available via our Site may include materials from third parties.  Third-party links on this site may direct you to third-party websites that are not affiliated with us.  We are not responsible for examining or evaluating the content or accuracy and we do not warrant and will not have any liability or responsibility for any third-party materials or websites, or for any other materials, products, or services of third parties. We are not liable for any harm or damages related to the purchase or use of goods, services, resources, content, or any other transactions made in connection with any third-party websites.  Please review carefully the third party’s policies and practices and make sure you understand them before you engage in any transaction.  Complaints, claims, concerns, or questions regarding third-party products should be directed to the third party.  You are responsible for taking reasonable precautions in all actions and interactions with third parties you interact with through the Site.\nUSER CONTENT\nYou grant us a license to use the materials you post to the Site and/or in connection with the Services.  By reviewing, posting, downloading, displaying, performing, transmitting, or otherwise distributing information or other content, including content in your User Account (“User Content”), to the Site or in connection with the Services, you are granting us, our affiliates, subsidiaries, parents, officers, directors, employees, consultants, agents, and representatives a license to use User Content in connection with the operation of the Site, including without limitation, a right to copy, distribute, transmit, publicly display, publicly perform, reproduce, edit, translate, and reformat User Content; and you agree that we may publish or otherwise disclose your User Content in our sole and absolute discretion.  However, all actions taken in connection with your User Content will be subject to the limitations set forth in our Privacy Policy. You will not be compensated for any User Content.  By posting User Content on the Site, you warrant and represent that you own the rights to the User Content or are otherwise authorized to post, distribute, display, perform, transmit, or otherwise distribute User Content. You agree that your User Content will not contain libelous or otherwise unlawful, abusive, or obscene material, or contain any computer virus or other malware that could in any way affect the operation of the Site.  You may not use a false e-mail address, pretend to be someone other than yourself, or otherwise mislead us or third parties as to the origin of any User Content.  You are solely responsible for any User Content you provide and its accuracy.  We take no responsibility and assume no liability for any User Content posted by you or any third party.  Any content guidelines or similar materials posted to the Site governing User Content or otherwise governing what constitutes appropriate use of the Site or Services (“User Content Guidelines”) are hereby incorporated into these Terms of Service by reference, and you hereby agree and consent to comply with the terms of any such User Content Guidelines. We may, but have no obligation to, monitor, edit or remove User Content that we determine in our sole discretion to be unlawful, offensive, threatening, libelous, defamatory, pornographic, obscene or otherwise objectionable or in violation of any party’s intellectual property or these Terms of Service. User Content includes, but is not limited to, Product Usage Data (as such term is defined in the Privacy Policy), which includes any ratings or reviews of products that users of the Site, including you, post when using the Site.  In order to post such ratings or reviews, you must have a valid User Account, and you may be asked to confirm the validity of the email address associated with your User Account.  By creating a User Account, you agree not to post ratings or reviews on the Site that are not based upon your own personal experience or that serve any purpose other than providing you or other users of the Site with an accurate account of your personal experience with such product or products.  Ratings or reviews not based on personal knowledge may not be posted on the Site. Additionally, Beanstalk’s collection and utilization of such User Content, including Product Usage Data such as ratings or reviews, does not constitute or imply Beanstalk’s endorsement, recommendation, or favoring of any product, whether or not the product is included on the Site." +
          "\nPUSH NOTIFICATIONS, TEXT MESSAGES, AND EMAILS\nWhen you download our Mobile App on your mobile device, you agree and consent to receive push notifications from us on your mobile device.  Push notifications are messages that the Mobile App sends to you on your mobile device (even when the Mobile App may not be open).  You can turn off push notifications by going to your mobile device’s “Settings” menu and disabling the notifications.If you create a User Account and provide us with your cell phone number, you agree and consent to receive certain text messages from Beanstalk regarding the Site and Services.  These text messages may relate to the Site’s operations or include promotional messages.  Standard text messaging rates will be applied by your mobile device carrier to any text messages sent by Beanstalk.  You will have the option to opt out of receiving text messages from Beanstalk by replying “STOP” to any text message sent by Beanstalk.  After requesting to opt out, you may receive text messages from Beanstalk for a brief time while your request is processed. Beanstalk text messages may be generated by automatic telephone dialing systems and you hereby waive your right to pursue any claims (including any claim that arises while your request to opt out is pending) under the Telephone Consumer Protection Act (“TCPA”).  To the extent any claim under the TCPA cannot be waived, by using the Site or Services, you are agreeing that any claim against Beanstalk that cannot be waived, but which arises under the TCPA (including any claim that arises while your request to opt out is pending), will be arbitrated on an individual, and not on a class or representative, basis, in accordance with Sections titled “ARBITRATION” and “CLASS ACTION WAIVER” of these Terms of Service. By providing us with your email address, you agree that we may send you emails concerning our Site and Services, as well information related to third parties.  You will have the option to opt out of such emails by following instructions to unsubscribe, which will be included in each email. \nMODIFICATIONS\nWe reserve the right at any time to modify or discontinue the Site, the Services (or any part or Content thereof) without notice at any time.  We shall not be liable to you or to any third party for any modification, change, suspension or discontinuance of the Site or Service.  Beanstalk does not have any obligation under these Terms of Service, except as otherwise expressly stated, to provide you with any support or maintenance in connection with the Site or Services.\nPERSONAL INFORMATION\nWe care deeply about the privacy of our users and take our duty to protect information about our users seriously.  Please review our Privacy Policy.  Our Privacy Policy is expressly incorporated into these Terms of Service by this reference. \nERRORS, INACCURACIES AND OMISSIONS\nOccasionally there may be information on our Site or in the Services that contains typographical errors, inaccuracies or omissions that may relate to product descriptions, pricing, promotions, offers, and availability.  We reserve the right to correct any errors, inaccuracies or omissions, and to change or update any information in the Site or Service or on any related website if it is inaccurate at any time without prior notice. We undertake no obligation to update, amend or clarify information in the Site or Services or on any related website, except as required by law.  No specified update or refresh date applied in the Site or Services or on any related website, should be taken to indicate that all information in the Site or Services or on any related website has been modified or updated.\nPROHIBITED USES\nIn addition to other prohibitions as set forth in the Terms of Service, and excepting federal laws that relate to cannabis, you are prohibited from using the Site or its Content: (a) for any unlawful purpose; (b) to solicit others to perform or participate in any unlawful acts; (c) to violate any international, federal, provincial or state regulations, rules, laws, or local ordinances; (d) to infringe upon or violate our intellectual property rights or the intellectual property rights of others; (e) to harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate based on gender, sexual orientation, religion, ethnicity, race, age, national origin, or disability; (f) to submit false or misleading information; (g) to upload or transmit viruses or any other type of malicious code that will or may be used in any way that will affect the functionality or operation of the Site or of any related website, other websites, or the Internet; (h) to collect or track the personal information of others; (i) to spam, phish, pharm, pretext, spider, crawl, or scrape; (j) for any obscene or immoral purpose; or (k) to interfere with or circumvent the security features of the Site or any related website, other websites, or the Internet.  We reserve the right to terminate your use of the Site and Services or any related website for violating any of the prohibited uses.\nDISCLAIMER OF WARRANTIES; LIMITATION OF LIABILITY\nYOU AGREE THAT YOUR USE OF THE SITE AND SERVICES WILL BE AT YOUR SOLE RISK.  TO THE FULLEST EXTENT PERMITTED BY LAW.  BEANSTALK, ITS AFFILIATES, ITS OFFICERS, DIRECTORS, EMPLOYEES, AND AGENTS, DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE SITE AND THE SERVICES AND YOUR USE THEREOF, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. BEANSTALK DOES NOT WARRANT THAT YOUR USE OF THIS SITE WILL BE UNINTERRUPTED OR ERROR FREE, OR THAT THIS SITE OR ITS SERVER ARE FREE OF VIRUSES OR OTHER HARMFUL ELEMENTS.  ALTHOUGH BEANSTALK ENDEAVORS TO PROVIDE ACCURATE INFORMATION, IT DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE ACCURACY OR RELIABILITY OF INFORMATION ON THIS SITE.  YOUR USE OF THE SITE IS AT YOUR OWN RISK.  NEITHER BEANSTALK NOR ITS AFFILIATED OR RELATED ENTITIES OR ITS VENDORS OR CONTENT PROVIDERS SHALL BE LIABLE TO ANY PERSON OR ENTITY FOR ANY DIRECT OR INDIRECT LOSS, DAMAGE (WHETHER ACTUAL, CONSEQUENTIAL, PUNITIVE, SPECIAL OR OTHERWISE), INJURY, CLAIM, OR LIABILITY OF ANY KIND OR CHARACTER WHATSOEVER BASED UPON OR RESULTING FROM YOUR USE OR INABILITY TO USE THIS SITE, OR ANY INFORMATION OR MATERIALS PROVIDED ON THE SITE.  BEANSTALK IS NOT LIABLE FOR ANY DEFAMATORY, OFFENSIVE OR ILLEGAL CONDUCT OF ANY USER.  IF YOU ARE DISSATISFIED WITH THE SITE OR ANY MATERIALS ON THE SITE, OR WITH ANY OF THE TERMS OF USE, YOUR SOLE AND EXCLUSIVE REMEDY IS TO DISCONTINUE USING THE SITE. Beanstalk does not warrant, endorse, guarantee, or assume responsibility for any product or service advertised or offered by a third party through the Site or any hyperlinked website or featured in any banner or other advertising, and Beanstalk will not be a party to or in any way be responsible for monitoring any transaction between you and third-party providers of products or services.  As with the purchase of a product or service through any medium or in any environment, you should use your best judgment and exercise caution where appropriate.  Notwithstanding anything to the contrary contained herein, Beanstalk and its affiliates’ liability to you for any cause whatsoever and regardless of the form of the action, will at all times be limited to the greater of (a) the amount paid, if any, by you to Beanstalk for the services during the period of one (1) month prior to any cause of action arising, and (b) five dollars (\$5).  BECAUSE SOME STATES OR JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR THE LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, IN SUCH STATES OR JURISDICTIONS, OUR LIABILITY SHALL BE LIMITED TO THE MAXIMUM EXTENT PERMITTED BY LAW.\nINDEMNIFICATION\nYOU AGREE TO INDEMNIFY, DEFEND AND HOLD HARMLESS BEANSTALK, ITS PARENT, SUBSIDIARIES, AFFILIATES, PARTNERS, SHAREHOLDERS, MEMBERS, OFFICERS, DIRECTORS, EMPLOYEES, INTERNS, AGENTS, DISTRIBUTORS, AND VENDORS FROM AND AGAINST ANY AND ALL CLAIMS, DEMANDS, LIABILITIES, COSTS OR EXPENSES, INCLUDING REASONABLE ATTORNEYS’ FEES AND EXPENSES, RESULTING OR ARISING OUT OF YOUR BREACH OF ANY OF THESE TERMS OF SERVICE OR THE DOCUMENTS THEY INCORPORATE BY REFERENCE, OR YOUR VIOLATION OF ANY LAW OR THE RIGHTS OF A THIRD PARTY.  Notwithstanding the foregoing, Beanstalk reserves the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify Beanstalk, and you agree to cooperate, at your expense, with Beanstalk’s defense of such claims. Beanstalk will use reasonable efforts to notify you of any such claim, action, or proceeding which is subject to this indemnification upon becoming aware of it. \nGOVERNING LAW\nThese Terms of Service and any separate agreements whereby we provide you Services shall be governed by and construed in accordance with the state laws of the state of California, exclusive of conflict or choice of law rules.\nARBITRATION\nIn the event of any dispute with Beanstalk, you agree to first contact Beanstalk to attempt in good faith to resolve the dispute.  All offers, promises, conduct and statements, whether oral or written, made in the course of negotiation to resolve the dispute by any of the parties, their agents, employees, experts and attorneys are confidential, privileged and inadmissible for any purpose, including impeachment, in arbitration or other proceeding involving the parties, provided that evidence that is otherwise admissible or discoverable shall not be rendered inadmissible or non-discoverable as a result of its use in the negotiation. If the dispute has not been resolved after sixty (60) days, we each agree to resolve any claim, dispute, or controversy (except for disputes brought in small claims court) arising out of or in connection with or relating to these Terms of Service, the Site or Services, including the determination of the scope or applicability of this agreement to arbitrate, or the alleged breach thereof, by binding arbitration in Santa Clara County, California before one arbitrator.  The arbitration shall be administered by JAMS pursuant to its Comprehensive Arbitration Rules and Procedures, and in accordance with the Expedited Procedures in those Rules.  Judgment on the award may be entered in any court having jurisdiction.  If this arbitration provision is found unenforceable or to not apply for a given dispute, then the proceeding must be brought exclusively in a court of competent jurisdiction in the County of Santa Clara, California.  You hereby accept the exclusive jurisdiction of such court for this purpose.\nCLASS ACTION WAIVER\nAny dispute resolution proceedings, whether in arbitration or court, will be conducted only on an individual basis and not in a class or representative action or as a named or unnamed member in a class, consolidated, representative or private attorney general legal action.  Your access and continued use of the Site or Services signifies your explicit consent to this waiver.\nSEVERABILITY\nIn the event that any provision or part of a provision of these Terms of Service is determined to be unlawful, void or unenforceable, that provision or part of the provision is deemed severable from these Terms of Service and does not affect the validity and enforceability of any remaining provisions.\nOTHER TERMS\nThese Terms of Service and any policies or operating rules posted by us on this Site or in respect to the Service constitutes the entire agreement and understanding between you and us and govern your use of the Site and Services, superseding any prior or contemporaneous agreements, communications and proposals, whether oral or written, between you and us (including, but not limited to, any prior versions of the Terms of Service).  The failure of us to exercise or enforce any right or provision of these Terms of Service shall not constitute a waiver of such right or provision.  Any ambiguities in the interpretation of these Terms of Service shall not be construed against the drafting party.\nCHANGES TO TERMS OF SERVICE\nYou can review the most current version of the Terms of Service at any time at this page.  We reserve the right, at our sole discretion, to update, change or replace any part of these Terms of Service by posting updates and changes to our Site.  It is your responsibility to check our Site periodically for changes.  Your continued use of or access to our Site or the Service following the posting of any changes to these Terms of Service constitutes acceptance of those changes.\nMISCELLANEOUS\nThe section titles in these Terms of Service are for convenience only and have no legal or contractual effect.  These Terms of Service operate to the fullest extent permissible by law.  These Terms of Service and your User Account may not be assigned by you without our express written consent.  Beanstalk may assign any or all of its rights and obligations to others at any time.  Beanstalk shall not be responsible or liable for any loss, damage, delay or failure to act caused by any cause beyond Beanstalk’s reasonable control.  There is no joint venture, partnership, employment or agency relationship created between you and Beanstalk as a result of these Terms of Service or use of the Site and Services.  Upon Beanstalk’s request, you will furnish Beanstalk any documentation, substantiation or releases necessary to verify your compliance with these Terms of Service.  You hereby waive any and all defenses you may have based on the electronic form of these Terms of Service and the lack of signing by the parties hereto to execute these Terms of Service." +
          "\nCONTACT INFORMATION\nIf you have any questions regarding these Terms of Service or the Privacy Policy, please contact:\nEmail: info@beanstalk.app";
}
