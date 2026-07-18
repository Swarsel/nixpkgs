{
  lib,
  fetchFromGitHub,
  buildDartApplication,
  dart,
  runCommand,
  testers,
  unsure,
  writeText,
}:

buildDartApplication rec {
  pname = "unsure";
  version = "0.4.0-unstable-2025-04-15";

  src = fetchFromGitHub {
    owner = "filiph";
    repo = "unsure";
    rev = "123712482b7053974cbef9ffa7ba46c1cdfb765f";
    hash = "sha256-rn10vy6l12ToiqO4vGVT4N7WNlj6PY/r+xVzjmYqILw=";
  };

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    [[ "$("$out/bin/unsure" "4~6 * 1~2" | head --lines=2)" == "$(printf '\n\t%s' '5~11')" ]]

    runHook postInstallCheck
  '';

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Calculate with numbers you’re not sure about";
    homepage = "https://filiph.github.io/unsure";
    changelog = "https://github.com/filiph/unsure/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.l0b0
      lib.maintainers.rksm
    ];

    mainProgram = "unsure";
    downloadPage = "https://github.com/filiph/unsure";
  };
}
