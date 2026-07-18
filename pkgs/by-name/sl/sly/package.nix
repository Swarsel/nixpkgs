{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  flutter335,
  gitUpdater,
  runCommand,
  sly,
  yq,
}:

flutter335.buildFlutterApplication rec {
  pname = "sly";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "kra-mo";
    repo = "Sly";
    tag = "v${version}";
    hash = "sha256-pFTP+oDY3pCSgO26ZtqUR+puMJSFZAEdbM2AqmfkNX8=";
  };

  postInstall = ''
    install -Dm0644 packaging/linux/page.kramo.Sly.svg $out/share/icons/hicolor/scalable/apps/page.kramo.Sly.svg
    install -Dm0644 packaging/linux/page.kramo.Sly.desktop $out/share/applications/sly.desktop
  '';

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  passthru = {
    pubspecSource =
      runCommand "pubspec.lock.json"
        {
          inherit (sly) src;
          nativeBuildInputs = [ yq ];
        }
        ''
          cat $src/pubspec.lock | yq > $out
        '';

    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater { rev-prefix = "v"; })
      (_experimental-update-script-combinators.copyAttrOutputToFile "sly.pubspecSource" ./pubspec.lock.json)
    ];
  };

  meta = {
    description = "Friendly image editor";
    homepage = "https://github.com/kra-mo/Sly";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "sly";
  };
}
