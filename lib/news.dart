import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  List<Map<String, dynamic>> get articles => [
        {
          'title': 'Мектептегі буллинг үшін жауапкершілік күшейтілді',
          'subtitle':
              'Орта білім беру ұйымдарында оқушыларды психологиялық қысымнан қорғау нормалары енгізілді.',
          'description':
              'Енді мектеп әкімшілігі буллинг фактісін жасырса, ата-аналарға да, білім мекемесіне де ескерту және айыппұл салынуы мүмкін.',
          'image':
              'https://images.pexels.com/photos/8989986/pexels-photo-8989986.jpeg?auto=compress&cs=tinysrgb&w=1200',
          'source': 'Оқу-ағарту министрлігі',
          'date': '2025-11-02',
          'category': 'Заң',
          'content':
              'Қазақстанда балаларды буллингтен және кибербуллингтен қорғау бойынша жаңа нормалар күшіне енді. Бұл нормаларға сәйкес әрбір білім беру ұйымы буллингтің алдын алу жоспарын жасап, ата-аналармен және оқушылармен түсіндіру жұмыстарын өткізуге міндетті. \n\nСонымен қатар, мектептерде сенім жәшіктері мен онлайн шағым беру арнасы болуы керек. Буллинг туралы хабарлама жасырылса немесе дер кезінде тіркелмесе, мектеп әкімшілігіне тәртіптік жаза қолданылуы мүмкін. \n\nБұл өзгерістер балалардың қауіпсіз ортада білім алуына жағдай жасауға бағытталған.',
        },
        {
          'title': 'Кибербуллингтен қалай қорғануға болады?',
          'subtitle':
              'Әлеуметтік желідегі қысым да психологиялық жарақат қалдырады.',
          'description':
              'Маманның айтуынша, бірінші қадам — агрессормен диалогқа бармау және дәлел жинау.',
          'image':
              'https://images.pexels.com/photos/3974408/pexels-photo-3974408.jpeg?auto=compress&cs=tinysrgb&w=1200',
          'source': 'Balalyq Online',
          'date': '2025-11-01',
          'category': 'Психология',
          'content':
              'Кибербуллинг — бұл әлеуметтік желілерде, мессенджерлерде немесе ойын платформаларында басқа адамға жүйелі түрде зиян келтіру, қорқыту немесе масқаралау. \n\nЕгер сіз немесе балаңыз кибербуллингке ұшыраса:\n1) Қарсы жауап жазбаңыз — бұл агрессорға күш береді;\n2) Скриншоттар мен сілтемелерді сақтаңыз — қажет болғанда дәлел ретінде көрсетесіз;\n3) Платформа әкімшілігіне немесе модераторға шағымданыңыз;\n4) Егер қорқытулар өмірге қауіп төндірсе — дереу құқық қорғау органдарына жүгініңіз;\n5) Психологпен сөйлесіп, өзіңізді кінәламаңыз.',
        },
        {
          'title': 'Психолог: “Баланы ұялту емес, тыңдау керек”',
          'subtitle': 'Буллинг құрбандары көбіне үнсіз қалады.',
          'description':
              'Мектепте қорланған бала көп жағдайда “дәрменсіз” рөлінде қалып қояды. Оған сенетін ересек адам керек.',
          'image':
              'https://images.pexels.com/photos/4100423/pexels-photo-4100423.jpeg?auto=compress&cs=tinysrgb&w=1200',
          'source': 'Psiholog.kz',
          'date': '2025-10-30',
          'category': 'Психология',
          'content':
              'Баладан “неге жауап бермедің?”, “неге айтпадың?” деп сұраудың орнына “сенің басыңнан не өтті?” деп сұрау дұрыс. Баланың эмоциясын жоққа шығармай, оны тыңдаған маңызды. \n\nПсихологтың айтуынша, буллинг көрген балаларда өзіне сенім төмендейді, ұйқы және тәбет бұзылады, оқуға қызығушылық жоғалады. Сондықтан ата-ана да, мұғалім де баланың мінез-құлқындағы өзгерісті ерте байқауы керек.',
        },
        {
          'title': 'Qorga платформасы арқылы аноним көмек алуға болады',
          'subtitle':
              'Жасөспірімдер үшін тәулік бойы онлайн қолдау іске қосылды.',
          'description':
              'Пайдаланушы аты-жөнін көрсетпей, тек жазбаша немесе аудио хабарлама қалдыра алады.',
          'image':
              'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=1200',
          'source': 'Qorga Team',
          'date': '2025-10-29',
          'category': 'Жоба',
          'content':
              'Qorga — буллингке, зорлық-зомбылыққа, отбасындағы кикілжіңдерге тап болған жастарға арналған цифрлық қолдау жобасы. Платформада бірнеше бөлім бар: жедел байланыс, психологиялық мақалалар, заң көмегі, пайдалы контактілер. \n\nАнонимдік — басты принцип. Бұл жасөспірімдердің ашық жазуына көмектеседі.',
        },
        {
          'title': 'Ата-аналарға арналған 5 кеңес',
          'subtitle': 'Балаңыз буллингке ұшырауы мүмкін белгілер.',
          'description':
              'Балаңыз сабақты себепсіз жіберіп алса немесе телефонын жасырса — назар аударыңыз.',
          'image':
              'https://images.pexels.com/photos/4473998/pexels-photo-4473998.jpeg?auto=compress&cs=tinysrgb&w=1200',
          'source': 'Otбасы және мектеп',
          'date': '2025-10-25',
          'category': 'Ата-ана',
          'content':
              '1. Баланың көңіл-күйі күрт өзгерсе;\n2. Мектепке барғысы келмесе;\n3. Киімі, заттары жоғалып жүрсе;\n4. Телефон/желі туралы айтқысы келмесе;\n5. Ұйқысы бұзылса — бұл мектептегі қысымның белгісі болуы мүмкін. \n\nМұндайда баланы ұрыспай, “бірге шешеміз” деген форматта сөйлесу қажет.',
        },
        {
          'title': 'Мектеп психологына қашан жүгіну керек?',
          'subtitle': 'Әр мектепте маман бар, бірақ бәрі білмейді.',
          'description':
              'Психологқа тек “ауыр” жағдайларда емес, алдын алу үшін де баруға болады.',
          'image':
              'https://images.pexels.com/photos/3958461/pexels-photo-3958461.jpeg?auto=compress&cs=tinysrgb&w=1200',
          'source': 'Bilim Medya',
          'date': '2025-10-20',
          'category': 'Мектеп',
          'content':
              'Психолог – балаға жан дүниесін қауіпсіз ортада ашуға мүмкіндік беретін маман. Егер балаңыз мектеп туралы сөйлескісі келмесе, құрбы-құрдастарымен жиі ұрысып жүрсе, өзіне сенімсіз болса – мектеп психологына жолыққан дұрыс.',
        },
        {
          'title': 'Заңгер түсіндіреді: балаңызға желіде қорқыту жазса...',
          'subtitle': 'Скриншот жинау – ең бірінші қадам.',
          'description':
              'Кибербуллинг те заңмен қорғалады. Әсіресе жүйелі түрде қайталанса.',
          'image':
              'https://images.pexels.com/photos/60621/pexels-photo-60621.jpeg?auto=compress&cs=tinysrgb&w=1200',
          'source': 'Law QZ',
          'date': '2025-10-15',
          'category': 'Заң',
          'content':
              'Егер интернетте балаңызды қорқытатын, масқаралайтын, жеке суретін тарататын хабарламалар келсе – бұл кибербуллинг. ҚР заңнамасы бойынша, мұндай әрекеттер үшін әкімшілік жауапкершілікке тартуға болады. Дәлел ретінде: скриншоттар, хат алмасу, профиль сілтемесі, уақыт пен дата қажет болады. \n\nЕгер қорқытуда “зиян келтіремін” деген нақты элементтер болса – полицияға жүгінуге болады.',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: AppBar(
        title: const Text(
          'Жаңалықтар',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFAEC9E3),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _NewsHeader(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = articles[index];
                return _NewsCard(
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailScreen(article: article),
                      ),
                    );
                  },
                );
              },
              childCount: articles.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _NewsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFAEC9E3),
            Color(0xFF8AAED1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Балалар қауіпсіздігі',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text(
                  'Буллингке қарсы материалдар',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Заң, психологиялық кеңес, ата-аналарға арналған нұсқаулықтар.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 34),
          )
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final VoidCallback onTap;
  const _NewsCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = article['image'] as String?;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                width: 120,
                child: img != null && img.isNotEmpty
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _newsImagePlaceholder();
                        },
                      )
                    : _newsImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          article['category'],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F5B77),
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      article['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202533),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (article['description'] != null)
                      Text(
                        article['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      '${article['source']} • ${article['date']}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _newsImagePlaceholder() {
    return Container(
      color: Colors.blueGrey[100],
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white70,
          size: 32,
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final img = article['image'] as String?;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: AppBar(
        title: Text(article['title']),
        backgroundColor: const Color(0xFFAEC9E3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (img != null && img.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    );
                  },
                ),
              ),
            const SizedBox(height: 14),
            Text(
              '${article['source']} • ${article['date']}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (article['subtitle'] != null) ...[
              const SizedBox(height: 12),
              Text(
                article['subtitle'],
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A3142)),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              article['content'],
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
