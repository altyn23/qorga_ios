const express = require('express');
const router = express.Router();

const PsychResult = require('../models/PsychResult'); // модель результата

// ВОПРОСЫ ХРАНИМ В КОДЕ, НЕ В БАЗЕ
const QUESTION_BANK = [
  { id: 'q1', text: 'Соңғы күндері өзімді жиі шаршаңқы сезінемін.' },
  { id: 'q2', text: 'Күнделікті тапсырмалар маған тым ауыр болып көрінеді.' },
  { id: 'q3', text: 'Түнде ұйықтап кету маған қиын.' },
  { id: 'q4', text: 'Таңертең төсектен тұруға мотивация таба алмаймын.' },
  { id: 'q5', text: 'Көңіл күйім күн ішінде жиі өзгеріп тұрады.' },
  { id: 'q6', text: 'Кейде еш себепсіз уайымдаймын.' },
  { id: 'q7', text: 'Соңғы уақытта мен өзімді жалғыз сезінемін.' },
  { id: 'q8', text: 'Өзіме деген сенімім төмендеп кетті.' },
  { id: 'q9', text: 'Маған бұрын қуаныш сыйлаған істер қазір қызықсыз.' },
  { id: 'q10', text: 'Топта сөйлеген кезде өзімді жайсыз сезінемін.' },
  { id: 'q11', text: 'Сессия немесе емтихандар туралы ойласам қатты мазасызданамын.' },
  { id: 'q12', text: 'Жақын адамдармен жиі ренжісемін.' },
  { id: 'q13', text: 'Маған өз ойымды басқаларға айту қиын.' },
  { id: 'q14', text: 'Жұмысты немесе оқуды кейінге қалдыра беремін.' },
  { id: 'q15', text: 'Менің қателіктерім үшін өзімді ұзақ уақыт кінәлаймын.' },
  { id: 'q16', text: 'Кейде болашақтан қорқамын.' },
  { id: 'q17', text: 'Кейде ештеңе істегім келмейді.' },
  { id: 'q18', text: 'Жақсы демалыстан кейін де шаршауымды сеземін.' },
  { id: 'q19', text: 'Соңғы кезде басымда жағымсыз ойлар көп.' },
  { id: 'q20', text: 'Өзіме қамқорлық жасауға уақыт бөлмеймін.' },
  { id: 'q21', text: 'Басқалардың бағасы мен үшін тым маңызды.' },
  { id: 'q22', text: 'Кішкентай сәтсіздік менің көңіл-күйімді бұзып жібереді.' },
  { id: 'q23', text: 'Жиі ашуланып немесе тітіркеніп қаламын.' },
  { id: 'q24', text: 'Өзімді пайдасыз сезінетін сәттерім көп.' },
  { id: 'q25', text: 'Көмек сұраудан ұяламын немесе қысыламын.' },
  { id: 'q26', text: 'Бір нәрсеге ұзақ уақыт көңіл бөлу маған қиын.' },
  { id: 'q27', text: 'Кейде өзімді ешкім түсінбейтіндей сезінемін.' },
  { id: 'q28', text: 'Жиі бас ауруы, іштің ауырсынуы сияқты белгілерді сеземін.' },
  { id: 'q29', text: 'Көңіл-күйім жақсы кезде де бір нәрсе бұзылатын сияқты сезім болады.' },
  { id: 'q30', text: 'Маған босаңсу және демалу қиын.' },
];

// выбираем рандомные вопросы
function getRandomQuestions(count) {
  const copy = [...QUESTION_BANK];
  copy.sort(() => Math.random() - 0.5);
  return copy.slice(0, count);
}

// GET /psychology/questions?count=10
router.get('/questions', (req, res) => {
  try {
    const count = Number.parseInt(req.query.count, 10) || 10;
    const max = Math.min(count, QUESTION_BANK.length);

    const selected = getRandomQuestions(max).map((q) => ({
      _id: q.id, // чтобы во Flutter было json['_id']
      text: q.text,
    }));

    return res.json(selected);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /psychology/submit
// body: { userId, answers: [{ questionId, value }] }
router.post('/submit', async (req, res) => {
  try {
    const { userId, answers } = req.body;

    // без userId сразу 400
    if (!userId) {
      return res.status(400).json({ message: 'userId is required' });
    }

    if (!Array.isArray(answers) || answers.length === 0) {
      return res.status(400).json({ message: 'answers are required' });
    }

    const score = answers.reduce(
      (sum, a) => sum + (Number(a.value) || 0),
      0
    );
    const maxScore = answers.length * 4;
    const ratio = score / maxScore;

    let stateText;
    if (ratio <= 0.35) {
      stateText =
        'Қазіргі жағдайда сенің эмоционалдық күйің салыстырмалы түрде тұрақты. ' +
        'Шаршау немесе уайым бар болуы мүмкін, бірақ олар сенің өміріңді толық бақылап тұрған жоқ. ' +
        'Өзіңді қолдауды жалғастыр, ұнайтын істермен айналыс және демалысты ұмытпа.';
    } else if (ratio <= 0.7) {
      stateText =
        'Соңғы уақытта сен аздап шамадан тыс жүктемені, уайымды немесе шаршауды сезініп жүрсің. ' +
        'Өзіңе кішігірім демалыс, серуен, спорт және сенетін адамдармен әңгіме пайдалы болады. ' +
        'Қажет болса, психолог не куратордан көмек сұраудан қорықпа.';
    } else {
      stateText =
        'Қазір сенің эмоциялық кернеуің жоғары. ' +
        'Бұл шаршау, үнемі уайым, мотивацияның төмендеуі немесе өзіңе сенімсіздік түрінде көрінуі мүмкін. ' +
        'Сен жалғыз емессің. Маманмен, психологпен немесе сенімді адаммен сөйлесу саған жеңілдік бере алады.';
    }

    const result = await PsychResult.create({
      user: userId, // <-- БЕЗ || null
      score,
      maxScore,
      stateText,
      answers: answers.map((a) => ({
        questionId: a.questionId,
        value: a.value,
      })),
    });

    return res.json({
      score,
      maxScore,
      stateText,
      id: result._id,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
