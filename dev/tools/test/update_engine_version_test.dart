// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm')
library;

import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:file/local.dart';
<<<<<<< HEAD
import 'package:file_testing/file_testing.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

void main() {
  const FileSystem localFs = LocalFileSystem();
  final _FlutterRootUnderTest flutterRoot = _FlutterRootUnderTest.findWithin();
=======
import 'package:platform/platform.dart';
import 'package:test/test.dart';

//////////////////////////////////////////////////////////////////////
//                                                                  //
//  ✨ THINKING OF MOVING/REFACTORING THIS FILE? READ ME FIRST! ✨  //
//                                                                  //
//  There is a link to this file in //docs/tool/Engine-artfiacts.md //
//  and it would be very kind of you to update the link, if needed. //
//                                                                  //
//////////////////////////////////////////////////////////////////////

void main() {
  // Want to test the powershell (update_engine_version.ps1) file, but running
  // a macOS or Linux machine? You can install powershell and then opt-in to
  // running `pwsh bin/internal/update_engine_version.ps1`.
  //
  // macOS: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos
  // linux: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
  //
  // Then, set this variable to true:
  final bool usePowershellOnPosix = () {
    // Intentionally not a const so that linting doesn't go wild across the test.
    return false;
  }();

  const FileSystem localFs = LocalFileSystem();
  final _FlutterRootUnderTest flutterRoot = _FlutterRootUnderTest.findWithin(
    forcePowershell: usePowershellOnPosix,
  );
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4

  late Directory tmpDir;
  late _FlutterRootUnderTest testRoot;
  late Map<String, String> environment;

  void printIfNotEmpty(String prefix, String string) {
    if (string.isNotEmpty) {
      string.split(io.Platform.lineTerminator).forEach((String s) {
        print('$prefix:>$s<');
      });
    }
  }

  io.ProcessResult run(String executable, List<String> args) {
    print('Running "$executable ${args.join(" ")}"');
    final io.ProcessResult result = io.Process.runSync(
      executable,
      args,
      environment: environment,
      workingDirectory: testRoot.root.absolute.path,
      includeParentEnvironment: false,
    );
    if (result.exitCode != 0) {
<<<<<<< HEAD
      print('exitCode: ${result.exitCode}');
=======
      fail('Failed running "$executable $args" (exit code = ${result.exitCode})');
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
    }
    printIfNotEmpty('stdout', (result.stdout as String).trim());
    printIfNotEmpty('stderr', (result.stderr as String).trim());
    return result;
  }

<<<<<<< HEAD
  setUp(() async {
    tmpDir = localFs.systemTempDirectory.createTempSync('update_engine_version_test.');
    testRoot = _FlutterRootUnderTest.fromPath(tmpDir.childDirectory('flutter').path);

    environment = <String, String>{};
    environment.addAll(io.Platform.environment);
    environment.remove('FLUTTER_PREBUILT_ENGINE_VERSION');
=======
  setUpAll(() async {
    if (usePowershellOnPosix) {
      final io.ProcessResult result = io.Process.runSync('pwsh', <String>['--version']);
      print('Using Powershell (${result.stdout}) on POSIX for local debugging and testing');
    }
  });

  setUp(() async {
    tmpDir = localFs.systemTempDirectory.createTempSync('update_engine_version_test.');
    testRoot = _FlutterRootUnderTest.fromPath(
      tmpDir.childDirectory('flutter').path,
      forcePowershell: usePowershellOnPosix,
    );

    environment = <String, String>{};

    if (const LocalPlatform().isWindows || usePowershellOnPosix) {
      // Copy a minimal set of environment variables needed to run the update_engine_version script in PowerShell.
      const List<String> powerShellVariables = <String>['SystemRoot', 'Path', 'PATHEXT'];
      for (final String key in powerShellVariables) {
        final String? value = io.Platform.environment[key];
        if (value != null) {
          environment[key] = value;
        }
      }
    }
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4

    // Copy the update_engine_version script and create a rough directory structure.
    flutterRoot.binInternalUpdateEngineVersion.copySyncRecursive(
      testRoot.binInternalUpdateEngineVersion.path,
    );
<<<<<<< HEAD
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  io.ProcessResult runUpdateEngineVersion() {
    final (String executable, List<String> args) =
        const LocalPlatform().isWindows
            ? ('powershell', <String>[testRoot.binInternalUpdateEngineVersion.path])
            : (testRoot.binInternalUpdateEngineVersion.path, <String>[]);
    return run(executable, args);
  }

  void setupRepo({required String branch}) {
    for (final File f in <File>[testRoot.deps, testRoot.engineSrcGn]) {
      f.createSync(recursive: true);
    }

    run('git', <String>['init', '--initial-branch', 'master']);
    run('git', <String>['add', '.']);
    run('git', <String>['commit', '-m', 'Initial commit']);
    if (branch != 'master') {
      run('git', <String>['checkout', '-b', branch]);
    }
  }

  const String engineVersionTrackedContents = 'already existing contents';
  void setupTrackedEngineVersion() {
    testRoot.binInternalEngineVersion.writeAsStringSync(engineVersionTrackedContents);
    run('git', <String>['add', '-f', 'bin/internal/engine.version']);
    run('git', <String>['commit', '-m', 'tracking engine.version']);
  }

=======

    // Regression test for https://github.com/flutter/flutter/pull/164396;
    // on a fresh checkout bin/cache does not exist, so avoid trying to create
    // this folder.
    if (testRoot.root.childDirectory('cache').existsSync()) {
      fail('Do not initially create a bin/cache directory, it should be created by the script.');
    }
  });

  tearDown(() {
    // Git adds a lot of files, we don't want to test for them.
    final Directory gitDir = testRoot.root.childDirectory('.git');
    if (gitDir.existsSync()) {
      gitDir.deleteSync(recursive: true);
    }

    // Take a snapshot of files we expect to be created or otherwise exist.
    //
    // This gives a "dirty" check that we did not change the output characteristics
    // of the tool without adding new tests for the new files.
    final Set<String> expectedFiles = <String>{
      localFs.path.join('bin', 'cache', 'engine.realm'),
      localFs.path.join('bin', 'cache', 'engine.stamp'),
      localFs.path.join(
        'bin',
        'internal',
        localFs.path.basename(testRoot.binInternalUpdateEngineVersion.path),
      ),
      localFs.path.join('bin', 'internal', 'engine.version'),
      localFs.path.join('engine', 'src', '.gn'),
      'DEPS',
    };
    final Set<String> currentFiles =
        tmpDir
            .listSync(recursive: true)
            .whereType<File>()
            .map((File e) => localFs.path.relative(e.path, from: testRoot.root.path))
            .toSet();

    // If this test failed, print out the current directory structure.
    printOnFailure(
      'Files in virtual "flutter" directory when test failed:\n\n${(currentFiles.toList()..sort()).join('\n')}',
    );

    // Now do cleanup so even if the next step fails, we still deleted tmp.
    tmpDir.deleteSync(recursive: true);

    final Set<String> unexpectedFiles = currentFiles.difference(expectedFiles);
    if (unexpectedFiles.isNotEmpty) {
      final StringBuffer message = StringBuffer(
        '\nOne or more files were generated by ${localFs.path.basename(testRoot.binInternalUpdateEngineVersion.path)} that were not expected:\n\n',
      );
      message.writeAll(unexpectedFiles, '\n');
      message.writeln('\n');
      message.writeln(
        'If this was intentional update "expectedFiles" in dev/tools/test/update_engine_version_test.dart and add *new* tests for the new outputs.',
      );
      fail('$message');
    }
  });

  /// Runs `bin/internal/update_engine_version.{sh|ps1}` and returns the process result.
  ///
  /// If the exit code is 0, it is considered a success, and files should exist as a side-effect.
  ///
  /// - On Windows, `powershell` is used (to run `update_engine_version.ps1`);
  /// - On POSIX, if [usePowershellOnPosix] is set, `pwsh` is used (to run `update_engine_version.ps1`);
  /// - Otherwise, `update_engine_version.sh` is used.
  io.ProcessResult runUpdateEngineVersion() {
    final String executable;
    final List<String> args;
    if (const LocalPlatform().isWindows) {
      executable = 'powershell';
      args = <String>[testRoot.binInternalUpdateEngineVersion.path];
    } else if (usePowershellOnPosix) {
      executable = 'pwsh';
      args = <String>[testRoot.binInternalUpdateEngineVersion.path];
    } else {
      executable = testRoot.binInternalUpdateEngineVersion.path;
      args = <String>[];
    }
    return run(executable, args);
  }

  /// Initializes a blank git repo in [testRoot.root].
  void initGitRepoWithBlankInitialCommit() {
    run('git', <String>['init', '--initial-branch', 'master']);
    run('git', <String>['config', '--local', 'user.email', 'test@example.com']);
    run('git', <String>['config', '--local', 'user.name', 'Test User']);
    run('git', <String>['add', '.']);
    run('git', <String>['commit', '-m', 'Initial commit']);
  }

  /// Creates a `bin/internal/engine.version` file in [testRoot].
  ///
  /// If [gitTrack] is `false`, the files are left untracked by git.
  void pinEngineVersionForReleaseBranch({required String engineHash, bool gitTrack = true}) {
    testRoot.binInternalEngineVersion.writeAsStringSync(engineHash);
    if (gitTrack) {
      run('git', <String>['add', '-f', 'bin/internal/engine.version']);
      run('git', <String>['commit', '-m', 'tracking engine.version']);
    }
  }

  /// Sets up and fetches a [remote] (such as `upstream` or `origin`) for [testRoot.root].
  ///
  /// The remote points at itself (`testRoot.root.path`) for ease of testing.
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
  void setupRemote({required String remote}) {
    run('git', <String>['remote', 'add', remote, testRoot.root.path]);
    run('git', <String>['fetch', remote]);
  }

<<<<<<< HEAD
  group('if FLUTTER_PREBUILT_ENGINE_VERSION is set', () {
    setUp(() {
      environment['FLUTTER_PREBUILT_ENGINE_VERSION'] = '123abc';
      setupRepo(branch: 'master');
    });

    test('writes it to engine.version with no git interaction', () async {
      runUpdateEngineVersion();

      expect(testRoot.binInternalEngineVersion, exists);
      expect(
        testRoot.binInternalEngineVersion.readAsStringSync(),
        equalsIgnoringWhitespace('123abc'),
      );
    });
  });

  test('writes nothing, even if files are set, if we are on "stable"', () async {
    setupRepo(branch: 'stable');
    setupTrackedEngineVersion();
    setupRemote(remote: 'upstream');

    runUpdateEngineVersion();

    expect(testRoot.binInternalEngineVersion, exists);
    expect(
      testRoot.binInternalEngineVersion.readAsStringSync(),
      equalsIgnoringWhitespace(engineVersionTrackedContents),
    );
  });

  test('writes nothing, even if files are set, if we are on "3.29.0"', () async {
    setupRepo(branch: '3.29.0');
    setupTrackedEngineVersion();
    setupRemote(remote: 'upstream');

    runUpdateEngineVersion();

    expect(testRoot.binInternalEngineVersion, exists);
    expect(
      testRoot.binInternalEngineVersion.readAsStringSync(),
      equalsIgnoringWhitespace(engineVersionTrackedContents),
    );
  });

  test('writes nothing, even if files are set, if we are on "beta"', () async {
    setupRepo(branch: 'beta');
    setupTrackedEngineVersion();
    setupRemote(remote: 'upstream');

    runUpdateEngineVersion();

    expect(testRoot.binInternalEngineVersion, exists);
    expect(
      testRoot.binInternalEngineVersion.readAsStringSync(),
      equalsIgnoringWhitespace(engineVersionTrackedContents),
    );
  });

  group('if DEPS and engine/src/.gn are present, engine.version is derived from', () {
    setUp(() async {
      setupRepo(branch: 'master');
    });

    test('merge-base HEAD upstream/master on non-LUCI when upstream is set', () async {
      setupRemote(remote: 'upstream');

      final io.ProcessResult mergeBaseHeadUpstream = run('git', <String>[
        'merge-base',
        'HEAD',
        'upstream/master',
      ]);
      runUpdateEngineVersion();

      expect(testRoot.binInternalEngineVersion, exists);
      expect(
        testRoot.binInternalEngineVersion.readAsStringSync(),
        equalsIgnoringWhitespace(mergeBaseHeadUpstream.stdout as String),
      );
    });

    test('merge-base HEAD origin/master on non-LUCI when upstream is not set', () async {
      setupRemote(remote: 'origin');

      final io.ProcessResult mergeBaseHeadOrigin = run('git', <String>[
        'merge-base',
        'HEAD',
        'origin/master',
      ]);
      runUpdateEngineVersion();

      expect(testRoot.binInternalEngineVersion, exists);
      expect(
        testRoot.binInternalEngineVersion.readAsStringSync(),
        equalsIgnoringWhitespace(mergeBaseHeadOrigin.stdout as String),
      );
    });

    test('rev-parse HEAD when running on LUCI', () async {
      environment['LUCI_CONTEXT'] = '_NON_NULL_AND_NON_EMPTY_STRING';
      runUpdateEngineVersion();

      final io.ProcessResult revParseHead = run('git', <String>['rev-parse', 'HEAD']);
      expect(testRoot.binInternalEngineVersion, exists);
      expect(
        testRoot.binInternalEngineVersion.readAsStringSync(),
        equalsIgnoringWhitespace(revParseHead.stdout as String),
      );
    });
  });

  group('if DEPS or engine/src/.gn are omitted', () {
    setUp(() {
      for (final File f in <File>[testRoot.deps, testRoot.engineSrcGn]) {
        f.createSync(recursive: true);
      }
      setupRepo(branch: 'master');
      setupRemote(remote: 'origin');
    });

    test('[DEPS] engine.version is blank', () async {
      testRoot.deps.deleteSync();

      runUpdateEngineVersion();

      expect(testRoot.binInternalEngineVersion, exists);
      expect(testRoot.binInternalEngineVersion.readAsStringSync(), equalsIgnoringWhitespace(''));
    });

    test('[engine/src/.gn] engine.version is blank', () async {
      testRoot.engineSrcGn.deleteSync();

      runUpdateEngineVersion();

      expect(testRoot.binInternalEngineVersion, exists);
      expect(testRoot.binInternalEngineVersion.readAsStringSync(), equalsIgnoringWhitespace(''));
=======
  /// Returns the SHA computed by `merge-base HEAD {{ref}}/master`.
  String gitMergeBase({required String ref}) {
    final io.ProcessResult mergeBaseHeadOrigin = run('git', <String>[
      'merge-base',
      'HEAD',
      '$ref/master',
    ]);
    return mergeBaseHeadOrigin.stdout as String;
  }

  group('if FLUTTER_PREBUILT_ENGINE_VERSION is set', () {
    setUp(() {
      environment['FLUTTER_PREBUILT_ENGINE_VERSION'] = '123abc';
      initGitRepoWithBlankInitialCommit();
    });

    test('writes it to cache/engine.stamp with no git interaction', () async {
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineStamp, _hasFileContentsMatching('123abc'));
    });

    test('takes precedence over bin/internal/engine.version, even if set', () async {
      pinEngineVersionForReleaseBranch(engineHash: '456def');
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineStamp, _hasFileContentsMatching('123abc'));
    });
  });

  group('if bin/internal/engine.version is set', () {
    setUp(() {
      initGitRepoWithBlankInitialCommit();
    });

    test('and tracked it is used', () async {
      setupRemote(remote: 'upstream');
      pinEngineVersionForReleaseBranch(engineHash: 'abc123');
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineStamp, _hasFileContentsMatching('abc123'));
    });

    test('but not tracked, it is ignored', () async {
      setupRemote(remote: 'upstream');
      pinEngineVersionForReleaseBranch(engineHash: 'abc123', gitTrack: false);
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineStamp, _hasFileContentsMatching(gitMergeBase(ref: 'upstream')));
    });
  });

  group('resolves engine artifacts with git merge-base', () {
    setUp(() {
      initGitRepoWithBlankInitialCommit();
    });

    test('default to upstream/master if available', () async {
      setupRemote(remote: 'upstream');
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineStamp, _hasFileContentsMatching(gitMergeBase(ref: 'upstream')));
    });

    test('fallsback to origin/master', () async {
      setupRemote(remote: 'origin');
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineStamp, _hasFileContentsMatching(gitMergeBase(ref: 'origin')));
    });
  });

  group('engine.realm', () {
    setUp(() {
      initGitRepoWithBlankInitialCommit();
      environment['FLUTTER_PREBUILT_ENGINE_VERSION'] = '123abc';
    });

    test('is empty by default', () async {
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineRealm, _hasFileContentsMatching(''));
    });

    test('is the value in FLUTTER_REALM if set', () async {
      environment['FLUTTER_REALM'] = 'flutter_archives_v2';
      runUpdateEngineVersion();

      expect(testRoot.binCacheEngineRealm, _hasFileContentsMatching('flutter_archives_v2'));
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
    });
  });
}

/// A FrUT, or "Flutter Root"-Under Test (parallel to a SUT, System Under Test).
///
/// For the intent of this test case, the "Flutter Root" is a directory
/// structure with the following elements:
///
/// ```txt
/// ├── bin
/// │   ├── internal
<<<<<<< HEAD
/// │   │   ├── engine.version
/// │   │   ├── engine.realm
/// │   │   └── update_engine_version.{sh|ps1}
/// │   └── engine
/// │       └── src
/// │           └── .gn
/// └── DEPS
=======
/// │   │   └── update_engine_version.{sh|ps1}
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
/// ```
final class _FlutterRootUnderTest {
  /// Creates a root-under test using [path] as the root directory.
  ///
  /// It is assumed the files already exist or will be created if needed.
  factory _FlutterRootUnderTest.fromPath(
    String path, {
    FileSystem fileSystem = const LocalFileSystem(),
    Platform platform = const LocalPlatform(),
<<<<<<< HEAD
=======
    bool forcePowershell = false,
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
  }) {
    final Directory root = fileSystem.directory(path);
    return _FlutterRootUnderTest._(
      root,
<<<<<<< HEAD
      deps: root.childFile('DEPS'),
      engineSrcGn: root.childFile(fileSystem.path.join('engine', 'src', '.gn')),
      binInternalEngineVersion: root.childFile(
        fileSystem.path.join('bin', 'internal', 'engine.version'),
      ),
      binInternalEngineRealm: root.childFile(
        fileSystem.path.join('bin', 'internal', 'engine.realm'),
      ),
=======
      binInternalEngineVersion: root.childFile(
        fileSystem.path.join('bin', 'internal', 'engine.version'),
      ),
      binCacheEngineRealm: root.childFile(fileSystem.path.join('bin', 'cache', 'engine.realm')),
      binCacheEngineStamp: root.childFile(fileSystem.path.join('bin', 'cache', 'engine.stamp')),
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
      binInternalUpdateEngineVersion: root.childFile(
        fileSystem.path.join(
          'bin',
          'internal',
<<<<<<< HEAD
          'update_engine_version.${platform.isWindows ? 'ps1' : 'sh'}',
=======
          'update_engine_version.${platform.isWindows || forcePowershell ? 'ps1' : 'sh'}',
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
        ),
      ),
    );
  }

<<<<<<< HEAD
  factory _FlutterRootUnderTest.findWithin([
    String? path,
    FileSystem fileSystem = const LocalFileSystem(),
  ]) {
=======
  factory _FlutterRootUnderTest.findWithin({
    String? path,
    FileSystem fileSystem = const LocalFileSystem(),
    bool forcePowershell = false,
  }) {
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
    path ??= fileSystem.currentDirectory.path;
    Directory current = fileSystem.directory(path);
    while (!current.childFile('DEPS').existsSync()) {
      if (current.path == current.parent.path) {
        throw ArgumentError.value(path, 'path', 'Could not resolve flutter root');
      }
      current = current.parent;
    }
<<<<<<< HEAD
    return _FlutterRootUnderTest.fromPath(current.path);
=======
    return _FlutterRootUnderTest.fromPath(current.path, forcePowershell: forcePowershell);
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
  }

  const _FlutterRootUnderTest._(
    this.root, {
<<<<<<< HEAD
    required this.deps,
    required this.engineSrcGn,
    required this.binInternalEngineVersion,
    required this.binInternalEngineRealm,
=======
    required this.binCacheEngineStamp,
    required this.binInternalEngineVersion,
    required this.binCacheEngineRealm,
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
    required this.binInternalUpdateEngineVersion,
  });

  final Directory root;

<<<<<<< HEAD
  /// `DEPS`.
  ///
  /// The presenence of this file is an indicator we are in a fused (mono) repo.
  final File deps;

  /// `engine/src/.gn`.
  ///
  /// The presenence of this file is an indicator we are in a fused (mono) repo.
  final File engineSrcGn;

  /// `bin/internal/engine.version`.
  ///
  /// This file contains a SHA of which engine binaries to download.
  final File binInternalEngineVersion;

  /// `bin/internal/engine.realm`.
  ///
  /// It is a mystery what this file contains, but it's set by `FLUTTER_REALM`.
  final File binInternalEngineRealm;
=======
  /// `bin/internal/engine.version`.
  ///
  /// This file contains a pinned SHA of which engine binaries to download.
  ///
  /// If omitted, the file is ignored.
  final File binInternalEngineVersion;

  /// `bin/cache/engine.stamp`.
  ///
  /// This file contains a _computed_ SHA of which engine binaries to download.
  final File binCacheEngineStamp;

  /// `bin/cache/engine.realm`.
  ///
  /// If non-empty, the value comes from the environment variable `FLUTTER_REALM`,
  /// which instructs the tool where the SHA stored in [binCacheEngineStamp]
  /// should be fetched from (it differs for presubmits run for flutter/flutter
  /// and builds downloaded by end-users or by postsubmits).
  final File binCacheEngineRealm;
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4

  /// `bin/internal/update_engine_version.{sh|ps1}`.
  ///
  /// This file contains a shell script that conditionally writes, on execution:
  /// - [binInternalEngineVersion]
  /// - [binInternalEngineRealm]
  final File binInternalUpdateEngineVersion;
}

extension on File {
  void copySyncRecursive(String newPath) {
    fileSystem.directory(fileSystem.path.dirname(newPath)).createSync(recursive: true);
    copySync(newPath);
  }
}
<<<<<<< HEAD
=======

/// Returns a matcher, that, given [contents]:
///
/// 1. Asserts the 'actual' entity is a [File];
/// 2. Asserts that the file exists;
/// 3. Asserts that the file's contents, after applying [collapseWhitespace], is the same as
///    [contents], after applying [collapseWhitespace].
///
/// This replaces multiple other matchers, and still provides a high-quality error message
/// when it fails.
Matcher _hasFileContentsMatching(String contents) {
  return _ExistsWithStringContentsIgnoringWhitespace(contents);
}

final class _ExistsWithStringContentsIgnoringWhitespace extends Matcher {
  _ExistsWithStringContentsIgnoringWhitespace(String contents)
    : _expected = collapseWhitespace(contents);

  final String _expected;

  @override
  bool matches(Object? item, _) {
    if (item is! File || !item.existsSync()) {
      return false;
    }
    final String actual = item.readAsStringSync();
    return collapseWhitespace(actual) == collapseWhitespace(_expected);
  }

  @override
  Description describe(Description description) {
    return description.add('a file exists that matches (ignoring whitespace): $_expected');
  }

  @override
  Description describeMismatch(Object? item, Description mismatch, _, _) {
    if (item is! File) {
      return mismatch.add('is not a file (${item.runtimeType})');
    }
    if (!item.existsSync()) {
      return mismatch.add('does not exist');
    }
    return mismatch
        .add('is ')
        .addDescriptionOf(collapseWhitespace(item.readAsStringSync()))
        .add(' with whitespace compressed');
  }
}
>>>>>>> 85235a41f623cd5aec4f78bd0f3505167bbfbfe4
