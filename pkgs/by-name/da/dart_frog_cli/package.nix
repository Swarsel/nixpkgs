{
  lib,
  fetchFromGitHub,
  buildDartApplication,
  callPackage,
  versionCheckHook,
}:
buildDartApplication (finalAttrs: {
  pname = "dart_frog_cli";
  version = "1.2.14";

  src = fetchFromGitHub {
    owner = "dart-frog-dev";
    repo = "dart_frog";
    tag = "dart_frog_cli-v${finalAttrs.version}";
    hash = "sha256-B5ET/SwQzYw251Ox/RyuLM27+M//xTehke9JJSD7Gf8=";
  };

  strictDeps = true;

  preBuild = ''
    rm pubspec_overrides.yaml
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  dartEntryPoints = {
    "bin/dart_frog" = "bin/dart_frog.dart";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${finalAttrs.src.name}/packages/dart_frog_cli";

  passthru = {
    # If your tests.nix needs the package itself, pass finalAttrs.finalPackage
    tests = callPackage ./tests.nix { };
    updateScript = lib.getExe (callPackage ./update.nix { });
  };

  meta = {
    description = "Command line tools for Dart Frog";

    longDescription = ''
      The official command line interface for Dart Frog — a fast, minimalistic backend framework for Dart.
    '';

    homepage = "https://dart-frog.dev";

    changelog = "https://pub.dev/packages/dart_frog_cli/changelog#${
      lib.replaceString "." "" finalAttrs.version
    }";

    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ KristijanZic ];
    mainProgram = "dart_frog";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "dart-frog-dev" finalAttrs.version;
  };
})
