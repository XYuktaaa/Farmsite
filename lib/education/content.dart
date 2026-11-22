class Lesson {
  const Lesson(this.id, this.title, this.body);
  final String id;
  final String title;
  final String body;
}

class QuizQuestion {
  const QuizQuestion(
      this.id, this.question, this.options, this.answer, this.explanation);
  final String id;
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
}

/// Learning cards. Each one is shown the first time its action is performed.
const Map<String, Lesson> lessons = {
  'soil': Lesson(
    'soil',
    'Why we prepare the soil',
    'Tilling loosens compacted soil so roots can spread, lets air and water '
        'move in, buries weeds and old crop residue, and gives seeds an even '
        'bed. Farmers often add compost or manure at this stage to improve '
        'soil structure and nutrients.',
  ),
  'seeds': Lesson(
    'seeds',
    'Choosing crops by season',
    'India has three main cropping seasons. Kharif crops (rice, maize, '
        'cotton) are sown with the monsoon around June-July. Rabi crops '
        '(wheat, mustard, gram) are sown in the cool months around '
        'October-November. Zaid crops (watermelon, cucumber, fodder) are '
        'grown in the dry summer and usually need irrigation. Some crops, '
        'like maize, can be grown in more than one season.',
  ),
  'water': Lesson(
    'water',
    'Irrigation and soil moisture',
    'Water needs depend on the crop, its growth stage, the soil and the '
        'weather. Rice does well in saturated fields, while wheat suffers if '
        'waterlogged. Sandy soil drains fast; clay holds water longer. Too '
        'little water causes wilting, too much starves roots of oxygen. '
        'Check soil moisture before irrigating. Watch the blue bar on each '
        'plot.',
  ),
  'fertilizer': Lesson(
    'fertilizer',
    'Fertilizers and NPK',
    'Plants need three major nutrients. Nitrogen (N) drives leafy green '
        'growth. Phosphorus (P) supports roots and flowering. Potassium (K) '
        'helps overall strength and resistance to stress. Soil tests show '
        'what is missing; over-applying wastes money and can pollute water. '
        'In this game, fertilizer speeds up growth by about 30 percent.',
  ),
  'health': Lesson(
    'health',
    'Reading crop health',
    'Drooping or curling leaves often signal water stress. Yellowing older '
        'leaves can point to low nitrogen. Spots, holes or webbing may mean '
        'disease or pests. Many problems look alike, so real farmers confirm '
        'in the field or ask an agricultural officer. This game teaches the '
        'ideas and does not diagnose real crops.',
  ),
  'harvest': Lesson(
    'harvest',
    'Harvesting at the right time',
    'Crops are harvested when mature. Wheat is ready when the grain is hard '
        'and the straw is golden. Rice is ready when most grains in the '
        'panicle turn straw-coloured. Maize is ready when husks dry and '
        'kernels are hard. Harvesting too early gives low yield and poor '
        'storage; too late causes grain loss. In the game, healthier crops '
        'give bigger yields.',
  ),
};

const List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    'q1',
    'Why do farmers till the soil before sowing?',
    [
      'To make the soil heavier',
      'To loosen soil for roots, air and water',
      'To remove all nutrients',
      'Only to make the field look neat',
    ],
    1,
    'Tilling loosens compacted soil, helps roots and water move, and buries weeds.',
  ),
  QuizQuestion(
    'q2',
    'Wheat is mainly grown in which Indian season?',
    ['Kharif', 'Rabi', 'Zaid', 'Monsoon only'],
    1,
    'Wheat is a Rabi crop, sown in the cool months and harvested in spring.',
  ),
  QuizQuestion(
    'q3',
    'Which nutrient mainly promotes leafy green growth?',
    ['Nitrogen', 'Phosphorus', 'Potassium', 'Sodium'],
    0,
    'Nitrogen is a key part of chlorophyll and protein, driving leaf growth.',
  ),
  QuizQuestion(
    'q4',
    'A crop looks water-stressed. What is the best first step?',
    [
      'Add more fertilizer',
      'Ignore it',
      'Check soil moisture, then irrigate as needed',
      'Harvest immediately',
    ],
    2,
    'Checking first confirms the cause and avoids over- or under-watering.',
  ),
  QuizQuestion(
    'q5',
    'Which crop tolerates standing water best?',
    ['Wheat', 'Maize', 'Rice', 'Gram'],
    2,
    'Paddy rice is adapted to saturated, flooded fields.',
  ),
  QuizQuestion(
    'q6',
    'Why not harvest a crop too early?',
    [
      'Yield and storage quality are poor',
      'The soil gets tired',
      'It rains more',
      'Prices always fall',
    ],
    0,
    'Immature grain is lighter, lower quality and stores badly.',
  ),
];

const List<String> scenarioOptions = [
  'Water the crop immediately',
  'Check soil moisture before irrigating',
  'Apply extra fertilizer',
  'Wait without taking action',
];
