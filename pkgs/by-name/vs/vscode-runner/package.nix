{
  lib,
  fetchFromGitHub,
  buildDartApplication,
  kdePackages,
  sqlite,
}:

let
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "Merrit";
    repo = "vscode-runner";
    rev = "v${version}";
    hash = "sha256-y9mexT02z6rw0uAbkHxOsPZQw5kgsm4v9qHHlyumcmo=";
  };
in
buildDartApplication {
  inherit version src;
  pname = "vscode-runner";
  buildInputs = [ sqlite ];
  vendorHash = "sha256-jS4jH00uxZIX81sZQIi+s42ofmXpD4/tPMRV2heaM2U=";

  postInstall = ''
    substituteInPlace ./package/codes.merritt.vscode_runner.service \
      --replace-fail "Exec=" "Exec=$out/bin/vscode_runner"
    install -D \
      ./package/codes.merritt.vscode_runner.service \
      $out/share/dbus-1/services/codes.merritt.vscode_runner.service

    install -D \
      ./package/plasma-runner-vscode_runner.desktop \
      $out/share/krunner/dbusplugins/plasma-runner-vscode_runner.desktop
  '';

  dartEntryPoints = {
    "bin/vscode_runner" = "bin/vscode_runner.dart";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  passthru.updateScript = ./update.sh;

  meta = {
    inherit (kdePackages.krunner.meta) platforms;
    description = "KRunner plugin for quickly opening recent VSCode workspaces";
    homepage = "https://github.com/Merrit/vscode-runner";
    changelog = "https://github.com/Merrit/vscode-runner/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.pinage404 ];
    mainProgram = "vscode_runner";
  };
}
