class Conversion {
  convertSex(String sex) {
    String convertedSex = '';
    if (sex == "M") {
      convertedSex = 'Male';
    } else {
      convertedSex = 'Female';
    }
    return convertedSex;
  }

  convertHair(String hair) {
    String convertedHair = '';
    if (hair == 'BRN') {
      convertedHair = 'Brown';
    } else if (hair == 'BLD') {
      convertedHair = 'Bald';
    } else if (hair == 'BLK') {
      convertedHair = 'Black';
    } else if (hair == 'BLN') {
      convertedHair = 'Blonde';
    } else if (hair == 'BLU') {
      convertedHair = 'Blue';
    } else if (hair == 'GRY') {
      convertedHair = 'Gray';
    } else if (hair == 'GRN') {
      convertedHair = 'Green';
    } else if (hair == 'ONG') {
      convertedHair = 'Orange';
    } else if (hair == 'PNK') {
      convertedHair = 'Pink';
    } else if (hair == 'RED') {
      convertedHair = 'Red';
    } else if (hair == 'WHI') {
      convertedHair = 'White';
    } else if (hair == 'OTH') {
      convertedHair = 'Other';
    }
    return convertedHair;
  }

  convertEye(String eye) {
    String convertedEye = '';
    if (eye == 'BLK') {
      convertedEye = 'Black';
    } else if (eye == 'BLU') {
      convertedEye = 'Blue';
    } else if (eye == 'GRN') {
      convertedEye = 'Green';
    } else if (eye == 'BRO') {
      convertedEye = 'Brown';
    } else if (eye == 'PNK') {
      convertedEye = 'Pink';
    } else if (eye == 'GRY') {
      convertedEye = 'Gray';
    } else if (eye == 'HZL') {
      convertedEye = 'Hazel';
    } else if (eye == 'OTH') {
      convertedEye = 'Other';
    }
    return convertedEye;
  }

  convertRace(String race) {
    String convertedRace = '';
    if (race == 'B') {
      convertedRace = 'Black';
    } else if (race == 'W') {
      convertedRace = 'White';
    } else if (race == 'I') {
      convertedRace = 'Native American';
    } else if (race == 'H') {
      convertedRace = 'Hispanic';
    } else if (race == 'A') {
      convertedRace = 'Asian';
    }
    return convertedRace;
  }

  convertHeight(String feet, String inch) {
    if (feet == 'null') {
      return '';
    } else if (feet == null) {
      return '';
    } else {
      String convertedHeight = '';
      convertedHeight = '$feet\' $inch\'\'';
      return convertedHeight;
    }
  }
}
