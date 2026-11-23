import 'package:flutter_test/flutter_test.dart';
import 'package:netlify_music/main.dart';

void main() {
  testWidgets('Netlify Music opens its home screen', (tester) async {
    await tester.pumpWidget(const NetlifyMusicApp());

    expect(find.text('Netlify Music'), findsOneWidget);
    expect(find.text('Your soundtrack starts here.'), findsOneWidget);
  });
}
