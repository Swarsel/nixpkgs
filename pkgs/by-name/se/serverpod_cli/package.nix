{
  lib,
  fetchFromGitHub,
  buildDartApplication,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  yq-go,
}:
buildDartApplication rec {
  pname = "serverpod_cli";
  version = "3.4.11";

  # Fetch the whole monorepo
  src = fetchFromGitHub {
    owner = "serverpod";
    repo = "serverpod";
    tag = version;
    hash = "sha256-IYsTP1ruidXO/FNa72sU6n7w2hzZ181hSjR74HxBAFM=";
  };

  nativeBuildInputs = [ yq-go ];

  preBuild = ''
    # Set productionMode to true.
    substituteInPlace lib/src/generated/version.dart \
      --replace-fail "const productionMode = false;" "const productionMode = true;"

    # Remove the dependency_overrides section.
    # Relative path overrides in the monorepo break the Nix build which expects
    # all dependencies to be resolved via the lockfile.
    yq -i 'del(.dependency_overrides)' pubspec.yaml
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  dartEntryPoints = {
    "bin/serverpod" = "bin/serverpod_cli.dart";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${src.name}/tools/serverpod_cli";
  versionCheckKeepEnvironment = "HOME";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Command line tools for Serverpod";

    longDescription = ''
      Serverpod is a next-generation app and web server,
      built for the Flutter community.
      It allows you to write your server-side code in Dart,
      automatically generate your APIs, and hook up your
      database with minimal effort. Serverpod is open-source,
      and you can host your server anywhere.
    '';

    homepage = "https://serverpod.dev";
    changelog = "https://raw.githubusercontent.com/serverpod/serverpod/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ KristijanZic ];
    mainProgram = "serverpod";
  };
}
