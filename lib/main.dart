import 'package:flutter/material.dart';

void main() => runApp(const NetlifyMusicApp());

const orange = Color(0xFFFF6A00);
const bg = Color(0xFF101010);
const panel = Color(0xFF181818);
const card = Color(0xFF202020);
const muted = Color(0xFFA7A7A7);

class NetlifyMusicApp extends StatelessWidget {
  const NetlifyMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Netlify Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: Brightness.dark),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const MusicHome(),
    );
  }
}

class Track {
  final String title;
  final String artist;
  final String image;
  final String duration;
  const Track(this.title, this.artist, this.image, this.duration);
}

const tracks = <Track>[
  Track('Midnight City', 'M83', 'https://images.unsplash.com/photo-1519608487953-e999c86e7455?w=600', '4:03'),
  Track('Blinding Lights', 'The Weeknd', 'https://images.unsplash.com/photo-1519608487953-e999c86e7455?w=600', '3:20'),
  Track('After Hours', 'The Weeknd', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600', '6:01'),
  Track('Night Changes', 'One Direction', 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600', '3:46'),
  Track('Ocean Drive', 'Duke Dumont', 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=600', '3:45'),
  Track('Sunset Lover', 'Petit Biscuit', 'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=600', '3:57'),
];

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});
  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  int page = 0;
  int selected = 0;
  bool playing = false;
  String query = '';
  String greeting = 'Good afternoon';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 850;
      return Scaffold(
        body: SafeArea(
          child: Column(children: [
            Expanded(child: Row(children: [
              if (wide) _sidebar(),
              Expanded(child: Column(children: [
                _topBar(wide),
                Expanded(child: _content(wide)),
              ])),
            ])),
            _player(wide),
          ]),
        ),
        bottomNavigationBar: wide ? null : NavigationBar(
          backgroundColor: panel,
          indicatorColor: orange.withValues(alpha: .18),
          selectedIndex: page,
          onDestinationSelected: (v) => setState(() => page = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Library'),
          ],
        ),
      );
    });
  }

  Widget _sidebar() => Container(
    width: 238, color: panel, padding: const EdgeInsets.fromLTRB(18, 22, 14, 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 25)),
        const SizedBox(width: 11),
        const Text('Netlify Music', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.5)),
      ]),
      const SizedBox(height: 38),
      _navItem(Icons.home_rounded, 'Home', 0),
      _navItem(Icons.search_rounded, 'Search', 1),
      _navItem(Icons.library_music_rounded, 'Your Library', 2),
      const SizedBox(height: 30),
      const Text('YOUR COLLECTION', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      const SizedBox(height: 17),
      _plainNav(Icons.favorite_border, 'Liked Songs'),
      _plainNav(Icons.add_box_outlined, 'Create playlist'),
      const SizedBox(height: 22),
      const Divider(color: Color(0xFF303030)),
      const SizedBox(height: 12),
      _playlist('Late Night Drive', orange),
      _playlist('Daily Mix', const Color(0xFF6D5CE8)),
      _playlist('Chill Vibes', const Color(0xFF168C79)),
      const Spacer(),
      Row(children: const [Icon(Icons.cloud_done_outlined, size: 16, color: muted), SizedBox(width: 8), Text('Your music, all in one place', style: TextStyle(color: muted, fontSize: 11))]),
    ]),
  );

  Widget _navItem(IconData icon, String label, int index) {
    final active = page == index;
    return InkWell(onTap: () => setState(() => page = index), borderRadius: BorderRadius.circular(9),
      child: Container(margin: const EdgeInsets.only(bottom: 5), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(color: active ? const Color(0xFF2A211B) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
        child: Row(children: [Icon(icon, size: 21, color: active ? orange : muted), const SizedBox(width: 13),
          Text(label, style: TextStyle(color: active ? Colors.white : muted, fontWeight: active ? FontWeight.w700 : FontWeight.w500))])));
  }

  Widget _plainNav(IconData icon, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
    child: Row(children: [Icon(icon, color: muted, size: 19), const SizedBox(width: 13), Text(label, style: const TextStyle(color: muted, fontSize: 13))]),
  );

  Widget _playlist(String name, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(children: [Container(width: 27, height: 27, decoration: BoxDecoration(color: color.withValues(alpha: .22), borderRadius: BorderRadius.circular(5)),
      child: Icon(Icons.music_note, color: color, size: 17)), const SizedBox(width: 10), Text(name, style: const TextStyle(color: muted, fontSize: 13))]),
  );

  Widget _topBar(bool wide) => Container(
    height: 70, padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 18),
    child: Row(children: [
      if (!wide) ...[
        Container(width: 34, height: 34, decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.graphic_eq, color: Colors.white, size: 22)),
        const SizedBox(width: 10),
        const Text('Netlify Music', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const Spacer(),
      ] else ...[
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left, color: muted)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right, color: muted)),
        const Spacer(),
      ],
      if (wide) ...[
        Container(width: 220, height: 40, decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(30)),
          child: TextField(onChanged: (v) => setState(() { query = v; page = 1; }),
            decoration: const InputDecoration(hintText: 'Search music...', prefixIcon: Icon(Icons.search, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.only(top: 9)))),
        const SizedBox(width: 18),
      ],
      CircleAvatar(radius: 17, backgroundColor: const Color(0xFF35302C), child: const Icon(Icons.person, size: 19, color: Colors.white)),
    ]),
  );

  Widget _content(bool wide) {
    final filtered = tracks.where((t) => ('${t.title} ${t.artist}').toLowerCase().contains(query.toLowerCase())).toList();
    if (page == 1 && !wide) {
      return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(onChanged: (v) => setState(() => query = v), decoration: InputDecoration(hintText: 'What do you want to play?', prefixIcon: const Icon(Icons.search), filled: true, fillColor: card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
        const SizedBox(height: 20), Expanded(child: _trackList(filtered)),
      ]));
    }
    if (page == 2) return _library(wide);
    return SingleChildScrollView(padding: EdgeInsets.fromLTRB(wide ? 28 : 18, 12, wide ? 28 : 18, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(greeting, style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Your soundtrack starts here.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -1.1)),
        const SizedBox(height: 23),
        _hero(wide),
        const SizedBox(height: 30),
        _sectionTitle(query.isEmpty ? 'Made for your mood' : 'Search results', 'See all'),
        const SizedBox(height: 15),
        if (query.isNotEmpty) _trackList(filtered) else _musicGrid(wide),
        const SizedBox(height: 30),
        _sectionTitle('Recently played', 'View history'),
        const SizedBox(height: 14),
        _trackList(tracks.take(4).toList()),
      ]),
    );
  }

  Widget _hero(bool wide) => Container(
    width: double.infinity, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF783500), Color(0xFF321B0D), Color(0xFF20150F)]),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(20)),
          child: const Text('NETLIFY PICK', style: TextStyle(fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w800))),
        const SizedBox(height: 13),
        const Text('Find your\nnext favourite.', style: TextStyle(fontSize: 28, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        const SizedBox(height: 10),
        const Text('A world of music, one place.', style: TextStyle(color: Color(0xFFE5C9B5), fontSize: 12)),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: () => setState(() { selected = 0; playing = true; }), style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.white),
          icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start listening')),
      ])),
      if (wide) ...[
        const SizedBox(width: 18),
        Container(width: 142, height: 142, decoration: BoxDecoration(color: orange.withValues(alpha: .18), shape: BoxShape.circle),
          child: const Icon(Icons.graphic_eq_rounded, size: 88, color: Color(0xFFFFB27A))),
      ],
    ]),
  );

  Widget _sectionTitle(String title, String action) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -.4))),
    Text(action, style: const TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w700)),
  ]);

  Widget _musicGrid(bool wide) {
    final count = wide ? 3 : 2;
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, crossAxisSpacing: 13, mainAxisSpacing: 13, childAspectRatio: wide ? 1.45 : .95),
      itemBuilder: (context, i) {
        final t = tracks[i];
        return InkWell(onTap: () => setState(() { selected = i; playing = true; }),
          borderRadius: BorderRadius.circular(12),
          child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Stack(fit: StackFit.expand, children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(t.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _art(i))),
                Positioned(right: 7, bottom: 7, child: Container(width: 35, height: 35, decoration: const BoxDecoration(color: orange, shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.white))),
              ])),
              const SizedBox(height: 9),
              Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 3),
              Text(t.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 11)),
            ]),
          ),
        );
      });
  }

  Widget _art(int i) {
    final colors = [const Color(0xFF6D3519), const Color(0xFF263A54), const Color(0xFF47305B), const Color(0xFF235247)];
    return Container(color: colors[i % colors.length], child: const Center(child: Icon(Icons.graphic_eq, color: Colors.white70, size: 48)));
  }

  Widget _trackList(List<Track> list) => Column(children: [
    for (final t in list)
      InkWell(onTap: () => setState(() { selected = tracks.indexOf(t).clamp(0, tracks.length - 1); playing = true; }),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: 43, height: 43, child: Image.network(t.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _art(tracks.indexOf(t))))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 3), Text(t.artist, style: const TextStyle(color: muted, fontSize: 11)),
          ])),
          Text(t.duration, style: const TextStyle(color: muted, fontSize: 11)),
          const SizedBox(width: 10),
          IconButton(onPressed: () => setState(() { selected = tracks.indexOf(t).clamp(0, tracks.length - 1); playing = !playing; }), icon: const Icon(Icons.play_circle_outline, color: muted)),
        ]))),
  ]);

  Widget _library(bool wide) => Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Your Library', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 16),
    Wrap(spacing: 8, children: ['Playlists', 'Artists', 'Albums'].map((s) => Chip(label: Text(s), backgroundColor: card, side: BorderSide.none)).toList()),
    const SizedBox(height: 12),
    Expanded(child: _trackList(tracks)),
  ]));

  Widget _player(bool wide) {
    final t = tracks[selected];
    return Container(height: 78, padding: EdgeInsets.symmetric(horizontal: wide ? 22 : 12), decoration: const BoxDecoration(color: Color(0xFF191919), border: Border(top: BorderSide(color: Color(0xFF303030)))),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: 46, height: 46, child: Image.network(t.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _art(selected)))),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 4), Text(t.artist, style: const TextStyle(color: muted, fontSize: 10)),
        ])),
        IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous_rounded, color: muted, size: 22)),
        Container(width: 38, height: 38, decoration: const BoxDecoration(color: orange, shape: BoxShape.circle),
          child: IconButton(padding: EdgeInsets.zero, onPressed: () => setState(() => playing = !playing), icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 23))),
        IconButton(onPressed: () => setState(() { selected = (selected + 1) % tracks.length; playing = true; }), icon: const Icon(Icons.skip_next_rounded, color: muted, size: 22)),
        if (wide) ...[
          const SizedBox(width: 14),
          const Icon(Icons.volume_up_outlined, color: muted, size: 18),
          SizedBox(width: 70, child: Slider(value: .7, onChanged: (_) {}, activeColor: orange, inactiveColor: const Color(0xFF555555))),
        ],
      ]),
    );
  }
}
