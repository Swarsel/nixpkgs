{
  lib,
  stdenv,
  fetchurl,
  cctools,
  darwin,
  runCommand,
  unzip,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dart";
  version = "3.12.2";

  src =
    let
      selectSystem =
        attrs:
        attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      system = selectSystem {
        aarch64-darwin = "macos-arm64";
        aarch64-linux = "linux-arm64";
        x86_64-linux = "linux-x64";
      };
      hash = selectSystem {
        aarch64-darwin = "sha256-zYdTko53trZlvXDc4OZLTsbS4v3hQdZAm7cWyKwfHAo=";
        aarch64-linux = "sha256-+CyD7OfRaAR1UN/UpmTkBxrHxIi923LcQxAsItfgtRg=";
        x86_64-linux = "sha256-KOR7RM8HXzZ3EEbAaLsNF0IBz5x2CHRK7RzCMgQpnC0=";
      };
    in
    fetchurl {
      inherit hash;

      url = "https://storage.googleapis.com/dart-archive/channels/${
        if lib.strings.hasSuffix ".beta" finalAttrs.version then "beta" else "stable"
      }/release/${finalAttrs.version}/sdk/dartsdk-${system}-release.zip";
    };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    rm LICENSE README revision
    cp -R . $out
  ''
  + lib.optionalString (stdenv.hostPlatform.isLinux) ''
    find $out/bin -type f -executable | while read f; do
      if patchelf --print-interpreter "$f" >/dev/null 2>&1; then
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                 --set-rpath "${lib.makeLibraryPath [ (lib.getLib stdenv.cc.cc) ]}" "$f"
      fi
    done
  ''
  + ''
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontStrip = true;

  passthru = {
    fetchGitHashesScript = ./fetch-git-hashes.py;

    tests = {
      testCompile =
        runCommand "dart-test-compile"
          {
            nativeBuildInputs = [
              finalAttrs.finalPackage
            ]
            ++ lib.optionals stdenv.hostPlatform.isDarwin [
              cctools
              darwin.sigtool
            ];
          }
          ''
            HELLO_MESSAGE="Hello, world!"
            echo "void main() => print('$HELLO_MESSAGE');" > hello.dart
            dart compile exe hello.dart
            PROGRAM_OUT=$(./hello.exe)

            [[ "$PROGRAM_OUT" == "$HELLO_MESSAGE" ]]
            touch $out
          '';

      testCreate = runCommand "dart-test-create" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
        PROJECTNAME="dart_test_project"
        dart create --no-pub $PROJECTNAME

        [[ -d $PROJECTNAME ]]
        [[ -f $PROJECTNAME/bin/$PROJECTNAME.dart ]]
        touch $out
      '';
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Scalable programming language, with robust libraries and runtimes, for building web, server, and mobile apps";

    longDescription = ''
      Dart is a class-based, single inheritance, object-oriented language
      with C-style syntax. It offers compilation to JavaScript, interfaces,
      mixins, abstract classes, reified generics, and optional typing.
    '';

    homepage = "https://dart.dev";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "dart";
    teams = [ lib.teams.flutter ];
  };
})
