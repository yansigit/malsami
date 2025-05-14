import 'package:flutter_test/flutter_test.dart';
import 'dart:developer' as developer;
import 'package:malsami/malsami.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('initializes EnglishG2P', () async {
    final g2p = EnglishG2P();
    // Just testing that initialization doesn't throw an error
    // Full tests will be added once dictionary files are created
    expect(g2p, isNotNull);
  });

  test('converts text to phonemes with markdown links', () async {
    final g2p = EnglishG2P();
    await g2p.initialize();
    final text =
        '[Malsami](/misˈɑki/) is a G2P engine designed for [Kokoro](/kˈOkəɹO/) models.';
    final (phonemes, tokens) = await g2p.convert(text);
    developer.log('Phonemes: $phonemes', name: 'malsami_dart_test');
    developer.log(
      'Tokens: ${tokens.map((t) => t.text).join(', ')}',
      name: 'malsami_dart_test',
    );
    // Optionally, check that the output contains the expected phonemes for the marked words
    expect(phonemes, contains('misˈɑki'));
    expect(phonemes, contains('kˈOkəɹO'));
  });

  test('complex sentence with multiple special cases', () async {
    final g2p = EnglishG2P();
    await g2p.initialize();
    final text =
        'I am an engineer by day and a musician by night. The match is Team A vs. Team B. Give it to Anna in Paris. [Malsami](/misˈɑki/) loves the unique engine.';
    final (phonemes, tokens) = await g2p.convert(text);
    // Check for various special-case outputs
    expect(
      phonemes,
      anyOf(contains('æm'), contains('ɐm'), contains('ˈɛm')),
    ); // am
    expect(phonemes, contains('ɐn')); // an
    expect(phonemes, anyOf(contains('bˈI'), contains('bI'))); // by
    expect(phonemes, contains('v')); // vs (at least v, ideally 'vɜrsəs')
    expect(phonemes, contains('tʊ')); // to before vowel (Anna)
    expect(phonemes, contains('ɪn')); // in
    expect(phonemes, contains('misˈɑki')); // markdown phoneme link
    expect(phonemes, anyOf(contains('ðə'), contains('ði'))); // the
    expect(
      phonemes,
      anyOf(contains('juˈnik'), contains('jˌunˈik')),
    ); // unique (should be tokenized and pronounced correctly)
  });

  test('complex sentence with punctuation and capitalization', () async {
    final g2p = EnglishG2P();
    await g2p.initialize();
    final text =
        'THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. I AM HERE! Give it to Bob.';
    final (phonemes, tokens) = await g2p.convert(text);
    // Check that all-caps words are handled, and special-case words still work
    expect(phonemes, anyOf(contains('ðə'), contains('ði'))); // the
    expect(
      phonemes,
      anyOf(contains('æm'), contains('ɐm'), contains('ˈɛm')),
    ); // am
    expect(phonemes, contains('tə')); // to before consonant (Bob)
    expect(phonemes, contains('I'));
  });

  test('sentence with multiple markdown phoneme links', () async {
    final g2p = EnglishG2P();
    await g2p.initialize();
    final text = '[Alpha](/ˈælfə/) and [Omega](/oʊˈmeɪɡə/) are Greek letters.';
    final (phonemes, tokens) = await g2p.convert(text);
    expect(phonemes, contains('ˈælfə'));
    expect(phonemes, contains('oʊˈmeɪɡə'));
  });

  test('Simple sentence with Malsami and Kokoro', () async {
    final g2p = EnglishG2P();
    await g2p.initialize();
    // Inject custom lexicon entries to mimic Tokenizer behavior
    g2p.lexicon.golds['malsami'] = 'misˈɑki';
    g2p.lexicon.golds['Malsami'] = 'misˈɑki'; // Handle capitalization
    g2p.lexicon.golds['kokoro'] = 'kˈOkəɹO';
    g2p.lexicon.golds['Kokoro'] = 'kˈOkəɹO'; // Handle capitalization

    final text = 'Malsami is a G2P engine designed for Kokoro models.';
    final (phonemes, tokens) = await g2p.convert(text);
    expect(phonemes, contains('misˈɑki'));
    expect(phonemes, anyOf(contains('ɪz'), contains('ɪs')));
    expect(phonemes, contains('ɛnʤɪn'));
    expect(phonemes, contains('kˈOkəɹO'));
  });
}
