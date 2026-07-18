{
  lib,
  fetchFromGitHub,
  buildDartApplication,
  callPackage,
  testers,
  versionCheckHook,
  yq-go,
}:
buildDartApplication (finalAttrs: {
  pname = "webdev";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "dart-lang";
    repo = "webdev";
    tag = "webdev-v${finalAttrs.version}";
    hash = "sha256-IwH0+J0iCSPxP/FbKPtmhpWjE16SGyYK88xa8ioBC2w=";
  };

  strictDeps = true;
  nativeBuildInputs = [ yq-go ];

  # Remove the dev_dependencies section.
  # Relative path overrides in the monorepo break the Nix build which expects
  # all dependencies to be resolved via the lockfile.
  preBuild = ''
    yq -i 'del(.dev_dependencies)' pubspec.yaml
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  dartEntryPoints = {
    "bin/webdev" = "bin/webdev.dart";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${finalAttrs.src.name}/webdev";

  passthru = {
    tests = {
      # Basic usage check
      usage = testers.runCommand {
        # Reference the package itself via finalPackage
        buildInputs = [ finalAttrs.finalPackage ];
        name = "webdev-usage-test";

        script = ''
          export HOME=$TMPDIR
          webdev --help > output.txt
          if grep -q "Usage: webdev" output.txt; then
            echo "Usage check passed ✅"
            touch $out
          else
            echo "Usage check failed ❌"
            exit 1
          fi
        '';
      };
    };

    updateScript = lib.getExe (callPackage ./update.nix { });
  };

  meta = {
    description = "Command-line tool for developing and deploying web applications with Dart";

    longDescription = ''
      A CLI for Dart web development. Provides an easy and consistent set of features for users and tools to build and deploy web applications with Dart.
    '';

    homepage = "https://dart.dev/tools/webdev";

    changelog = "https://pub.dev/packages/webdev/changelog#${
      lib.replaceString "." "" finalAttrs.version
    }";

    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ KristijanZic ];
    mainProgram = "webdev";

    identifiers.cpeParts =
      let
        versionSplit = lib.split "\\+" finalAttrs.version;
        versionPart = lib.elemAt versionSplit 0;
        updatePart =
          if lib.count (x: lib.isList x) versionSplit > 0 then lib.elemAt versionSplit 2 else "*";
      in
      {
        version = versionPart;
        product = "webdev";
        update = updatePart;
        vendor = "dart-lang";
      };
  };
})
