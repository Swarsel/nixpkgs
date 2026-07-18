{
  lib,
  fetchFromGitHub,
  buf,
  buildDartApplication,
  dart-sass,
  protoc-gen-dart,
  runCommand,
  testers,
  writableTmpDirAsHomeHook,
  writeText,
}:

let
  embedded-protocol-version = "3.2.0";

  embedded-protocol = fetchFromGitHub {
    hash = "sha256-yX30i1gbVZalVhefj9c37mpFOIDaQlsLeAh7UnY56ro=";
    owner = "sass";
    repo = "sass";
    tag = "embedded-protocol-${embedded-protocol-version}";
  };
in
buildDartApplication rec {
  pname = "dart-sass";
  version = "1.101.0";

  src = fetchFromGitHub {
    owner = "sass";
    repo = "dart-sass";
    tag = version;
    hash = "sha256-hs028qXBzRGrh9xZAQGaFw7iXtkQm9fixMuBohupjrI=";
  };

  nativeBuildInputs = [
    buf
    protoc-gen-dart
    writableTmpDirAsHomeHook
  ];

  preConfigure = ''
    mkdir -p build
    ln -s ${embedded-protocol} build/language
    buf generate
  '';

  postInstall = ''
    # dedupe identiall binaries
    ln -rsf $out/bin/{,dart-}sass
  '';

  dartCompileFlags = [ "--define=version=${version}" ];
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  passthru = {
    inherit embedded-protocol-version embedded-protocol;

    tests = {
      version = testers.testVersion {
        command = "dart-sass --version";
        package = dart-sass;
      };

      simple = testers.testEqualContents {
        actual =
          runCommand "actual"
            {
              nativeBuildInputs = [ dart-sass ];

              base = writeText "base" ''
                body {
                  $color: #123;
                  h1 {
                    color: $color;
                  }
                }
              '';
            }
            ''
              dart-sass --style=compressed $base > $out
            '';

        assertion = "dart-sass compiles a basic scss file";

        expected = writeText "expected" ''
          body h1{color:#123}
        '';
      };
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Reference implementation of Sass, written in Dart";
    homepage = "https://github.com/sass/dart-sass";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lelgenio ];
    mainProgram = "sass";
  };
}
