Map<String, String> numbersInWords = {
  '10': 'ten',
  '11': 'eleven',
  '12': 'twelve',
  '13': 'thirteen',
  '14': 'fourteen',
  '15': 'fifteen',
  '16': 'sixteen',
  '17': 'seventeen',
  '18': 'eighteen',
  '19': 'nineteen',
  '20': 'twenty',
  '21': 'twenty-one',
  '22': 'twenty-two',
  '23': 'twenty-three',
  '24': 'twenty-four',
  '25': 'twenty-five',
  '26': 'twenty-six',
  '27': 'twenty-seven',
  '28': 'twenty-eight',
  '29': 'twenty-nine',
  '30': 'thirty',
  '31': 'thirty-one',
  '32': 'thirty-two',
  '33': 'thirty-three',
  '34': 'thirty-four',
  '35': 'thirty-five',
  '36': 'thirty-six',
  '37': 'thirty-seven',
  '38': 'thirty-eight',
  '39': 'thirty-nine',
  '40': 'forty',
  '41': 'forty-one',
  '42': 'forty-two',
  '43': 'forty-three',
  '44': 'forty-four',
  '45': 'forty-five',
  '46': 'forty-six',
  '47': 'forty-seven',
  '48': 'forty-eight',
  '49': 'forty-nine',
  '50': 'fifty',

};

String getNumberInWords(String number) {
  String? word = numbersInWords[number];
  return word ?? "Not found";
}

Map<String, String> conditionToSentence = {
    'Clouds': 'cloudy',
    'Mist': 'cloudy',
    'Haze': 'cloudy',
    'Dusty': 'cloudy',
    'Rain': 'rainy',
    'Drizzle': 'drizzles',
    'Shower rain': 'rainy',
    'Thunderstorm': 'thunderstorm',
    'Clear': 'clear',
  };
String getConditionToSentence(String condition) {
  String? wordy = conditionToSentence[condition];
  return wordy ?? "Not found";
}