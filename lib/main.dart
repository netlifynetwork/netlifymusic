import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player/youtube_player.dart';

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

class YouTubeVideo {
  final String videoId;
  final String title;
  final String channelTitle;
  final String description;
  final String thumbnail;

  const YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.description,
    required this.thumbnail,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final thumbnails = json['thumbnails'] as Map<String, dynamic>? ?? {};
    final image = (thumbnails['high'] ?? thumbnails['medium'] ?? thumbnails['default']) as Map<String, dynamic>? ?? {};
    return YouTubeVideo(
      videoId: json['videoId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled video',
      channelTitle: json['channelTitle']?.toString() ?? 'YouTube channel',
      description: json['description']?.toString() ?? '',
      thumbnail: image['url']?.toString() ?? '',
    );
  }
}

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});
  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  int page = 0;
  String query = '';
  final TextEditingController _mobileSearchController = TextEditingController();
  bool _searchLoading = false;
  bool _searchHasRun = false;
  int _searchRequestId = 0;
  bool _checkingUpdates = false;
  String? _latestVersion;
  String? _releaseUrl;
  bool _updateAvailable = false;
  String? _updateError;
  String? _searchError;
  List<YouTubeVideo> _youtubeResults = [];
  final List<YouTubeVideo> _recentVideos = [];
  YoutubePlayerController? _youtubeController;
  YouTubeVideo? _currentVideo;
  static const String _searchEndpoint =
      'https://nraxrduredxbswmvoijy.supabase.co/functions/v1/youtube-search';
  static const String _releaseEndpoint =
      'https://api.github.com/repos/netlifynetwork/netlifymusic/releases/latest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates(showDialogIfAvailable: true);
    });
  }

  int _compareVersions(String current, String latest) {
    List<int> parts(String value) => value
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+').first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final a = parts(current);
    final b = parts(latest);
    for (var i = 0; i < (a.length > b.length ? a.length : b.length); i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }

  Future<void> _checkForUpdates({bool showDialogIfAvailable = false}) async {
    if (_checkingUpdates) return;
    setState(() {
      _checkingUpdates = true;
      _updateError = null;
    });
    try {
      final response = await http.get(
        Uri.parse(_releaseEndpoint),
        headers: const {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception(response.statusCode == 404
            ? 'No published update is available yet.'
            : 'Could not check for updates.');
      }
      final release = jsonDecode(response.body) as Map<String, dynamic>;
      final latest = (release['tag_name'] ?? '').toString();
      final url = (release['html_url'] ?? '').toString();
      final package = await PackageInfo.fromPlatform();
      final available = latest.isNotEmpty &&
          url.isNotEmpty && _compareVersions(package.version, latest) < 0;
      if (!mounted) return;
      setState(() {
        _latestVersion = latest;
        _releaseUrl = url;
        _updateAvailable = available;
        _checkingUpdates = false;
      });
      if (available && showDialogIfAvailable) _showUpdateDialog();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingUpdates = false;
        _updateError = 'Update check is temporarily unavailable.';
      });
    }
  }

  Future<void> _showUpdateDialog() async {
    final package = await PackageInfo.fromPlatform();
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: Row(children: const [
          Icon(Icons.system_update_alt, color: orange),
          SizedBox(width: 10),
          Expanded(child: Text('Netlify Music update')),
        ]),
        content: Text(_updateAvailable
            ? defaultTargetPlatform == TargetPlatform.android
                ? 'Version ${_latestVersion ?? ''} is ready. You have ${package.version}. Android in-place updates need a permanent app-signing key. The signed Android release is not enabled yet, so this app will not offer an unsafe installer.'
                : defaultTargetPlatform == TargetPlatform.windows
                    ? 'Version ${_latestVersion ?? ''} is ready. You have ${package.version}. Download the Windows package from the official release. Close Netlify Music, extract the new package over the existing app folder, then reopen it.'
                    : 'Version ${_latestVersion ?? ''} is ready. You have ${package.version}. Open the official release page to see the available packages for your platform.'
            : _updateError ?? 'You are using the latest available version.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
          if (_updateAvailable && _releaseUrl != null && defaultTargetPlatform != TargetPlatform.android)
            FilledButton(
              onPressed: () async {
                final uri = Uri.tryParse(_releaseUrl!);
                if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Open release downloads'),
            )
          else if (!_checkingUpdates)
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _checkForUpdates();
              },
              child: const Text('Check again'),
            ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      query = value;
      _searchError = null;
      _youtubeResults = [];
      _searchLoading = false;
      _searchHasRun = false;
    });
  }

  void _submitSearch() {
    final value = query.trim();
    if (value.length < 2) {
      setState(() => _searchError = 'Enter at least 2 characters to search.');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => page = 1);
    _searchYoutube(value);
  }

  Future<List<YouTubeVideo>> _fetchYoutubeVideos(String value) async {
    final uri = Uri.parse(_searchEndpoint).replace(queryParameters: {'q': value});
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error']?.toString() ?? 'Search failed.');
    }
    return (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(YouTubeVideo.fromJson)
        .where((video) => video.videoId.isNotEmpty)
        .toList();
  }

  Future<void> _searchYoutube(String value) async {
    final requestId = ++_searchRequestId;
    setState(() {
      _searchLoading = true;
      _searchHasRun = true;
      _searchError = null;
      _youtubeResults = [];
    });
    try {
      final results = await _fetchYoutubeVideos(value);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _youtubeResults = results;
        _searchLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchLoading = false;
        _searchError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _playYoutube(YouTubeVideo video) {
    _youtubeController?.close();
    final controller = YoutubePlayerController.fromVideoId(
      videoId: video.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(mute: false),
    );
    setState(() {
      _youtubeController = controller;
      _currentVideo = video;
      _recentVideos.removeWhere((item) => item.videoId == video.videoId);
      _recentVideos.insert(0, video);
      if (_recentVideos.length > 12) _recentVideos.removeLast();
    });
  }



  @override
  void dispose() {
    _mobileSearchController.dispose();
    _youtubeController?.close();
    super.dispose();
  }

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
      IconButton(
        tooltip: 'Check for updates',
        onPressed: _checkingUpdates ? null : () => _checkForUpdates().then((_) => _showUpdateDialog()),
        icon: _checkingUpdates
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: orange))
            : Icon(_updateAvailable ? Icons.system_update_alt : Icons.system_update, color: _updateAvailable ? orange : muted),
      ),
      CircleAvatar(radius: 17, backgroundColor: const Color(0xFF35302C), child: const Icon(Icons.person, size: 19, color: Colors.white)),
    ]),
  );

  Widget _content(bool wide) {
    if (page == 2) return _library(wide);

    if (page == 1) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _searchField(),
            const SizedBox(height: 18),
            Expanded(child: _youtubeSearchResults()),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('NETLIFY MUSIC', style: TextStyle(color: orange, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
              const SizedBox(height: 12),
              const Text('Find the music\nyou love.', style: TextStyle(fontSize: 42, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
              const SizedBox(height: 12),
              const Text('Search for any song, artist or album.', style: TextStyle(color: muted, fontSize: 15)),
              const SizedBox(height: 26),
              _searchField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField() => TextField(
    controller: _mobileSearchController,
    onChanged: _onSearchChanged,
    onSubmitted: (_) => _submitSearch(),
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Search songs, artists or albums...',
      prefixIcon: const Icon(Icons.search, color: orange),
      suffixIcon: IconButton(
        tooltip: 'Search',
        onPressed: _submitSearch,
        icon: const Icon(Icons.arrow_forward_rounded, color: orange),
      ),
      filled: true,
      fillColor: card,
      contentPadding: const EdgeInsets.symmetric(vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _videoGrid(List<YouTubeVideo> videos, bool wide) {
    final count = wide ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: wide ? 1.22 : .88,
      ),
      itemBuilder: (context, index) {
        final video = videos[index];
        return InkWell(
          onTap: () => _playYoutube(video),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Stack(fit: StackFit.expand, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: video.thumbnail.isEmpty
                        ? _art(index)
                        : Image.network(video.thumbnail, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _art(index)),
                  ),
                  Positioned(right: 7, bottom: 7, child: Container(
                    width: 34, height: 34,
                    decoration: const BoxDecoration(color: orange, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  )),
                ]),
              ),
              const SizedBox(height: 8),
              Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(height: 3),
              Text(video.channelTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 10)),
            ]),
          ),
        );
      },
    );
  }

  Widget _videoList(List<YouTubeVideo> videos) => Column(
    children: [
      for (var i = 0; i < videos.length; i++)
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 3),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 52, height: 48,
              child: videos[i].thumbnail.isEmpty
                  ? _art(i)
                  : Image.network(videos[i].thumbnail, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _art(i)),
            ),
          ),
          title: Text(videos[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          subtitle: Text(videos[i].channelTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 10)),
          trailing: const Icon(Icons.play_circle_outline, color: orange),
          onTap: () => _playYoutube(videos[i]),
        ),
    ],
  );

  Widget _youtubeSearchResults() {
    if (query.trim().length < 2) {
      return const Center(
        child: Text(
          'Search for a song, artist or album',
          style: TextStyle(color: muted, fontSize: 14),
        ),
      );
    }
    if (_searchLoading) {
      return const Center(child: CircularProgressIndicator(color: orange));
    }
    if (!_searchHasRun) {
      return const Center(child: Text('Press Enter or tap the search arrow to find music.', style: TextStyle(color: muted, fontSize: 14)));
    }
    if (_searchError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_searchError!, style: const TextStyle(color: muted)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _searchYoutube(query.trim()),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (_youtubeResults.isEmpty) {
      return const Center(
        child: Text('No results found.', style: TextStyle(color: muted)),
      );
    }
    return Column(
      children: [
        if (_currentVideo != null && _youtubeController != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: _youtubeController!,
              aspectRatio: 16 / 9,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentVideo!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    Text(
                      _currentVideo!.channelTitle,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Text(
                'YouTube',
                style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF303030)),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 6, top: 5),
              child: Text('More results', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
        Expanded(
          child: ListView.separated(
      itemCount: _youtubeResults.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFF303030), height: 1),
      itemBuilder: (context, index) {
        final video = _youtubeResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 104,
              height: 58,
              child: video.thumbnail.isEmpty
                  ? _art(index)
                  : Image.network(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _art(index),
                    ),
            ),
          ),
          title: Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          subtitle: Text(
            video.channelTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 11),
          ),
          trailing: IconButton(
            tooltip: 'Play in Netlify Music',
            onPressed: () => _playYoutube(video),
            icon: const Icon(Icons.play_circle_outline, color: orange, size: 27),
          ),
          onTap: () => _playYoutube(video),
        );
      },
    ),
        ),
      ],
    );
  }

  Widget _art(int i) {
    final colors = [const Color(0xFF6D3519), const Color(0xFF263A54), const Color(0xFF47305B), const Color(0xFF235247)];
    return Container(color: colors[i % colors.length], child: const Center(child: Icon(Icons.graphic_eq, color: Colors.white70, size: 48)));
  }

  Widget _library(bool wide) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Your Library', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Songs you have played recently appear here.', style: TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 16),
      Expanded(
        child: _recentVideos.isEmpty
            ? const Center(child: Text('Your listening history is empty.', style: TextStyle(color: muted)))
            : SingleChildScrollView(child: _videoList(_recentVideos)),
      ),
    ]),
  );

  Widget _player(bool wide) {
    final video = _currentVideo;
    final title = video?.title ?? 'Choose something to play';
    final subtitle = video?.channelTitle ?? 'Search millions of music videos';
    final imageUrl = video?.thumbnail ?? '';

    return Container(
      height: 78,
      padding: EdgeInsets.symmetric(horizontal: wide ? 22 : 12),
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        border: Border(top: BorderSide(color: Color(0xFF303030))),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 46,
              height: 46,
              child: imageUrl.isEmpty
                  ? Container(color: card, child: const Icon(Icons.graphic_eq, color: orange, size: 25))
                  : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: card, child: const Icon(Icons.graphic_eq, color: orange)),),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          if (_youtubeController != null)
            YoutubeValueBuilder(
              controller: _youtubeController!,
              builder: (context, value) {
                final isPlaying = value.playerState == PlayerState.playing;
                return IconButton(
                  tooltip: isPlaying ? 'Pause video' : 'Play video',
                  onPressed: value.isReady
                      ? () {
                          if (isPlaying) {
                            _youtubeController!.pauseVideo();
                          } else {
                            _youtubeController!.playVideo();
                          }
                        }
                      : null,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                );
              },
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Choose a song', style: TextStyle(color: muted, fontSize: 10)),
            ),
          if (wide)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text('YouTube player', style: TextStyle(color: muted, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
