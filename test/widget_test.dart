import 'package:flutter_test/flutter_test.dart';
import 'package:netlify_music/main.dart';

void main() {
  testWidgets('Netlify Music opens its search-first home screen', (tester) async {
    await tester.pumpWidget(const NetlifyMusicApp());

    expect(find.text('Netlify Music'), findsOneWidget);
    expect(find.textContaining('Find the music'), findsOneWidget);
    expect(find.text('Search songs, artists or albums...'), findsOneWidget);
  });
}
