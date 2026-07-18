{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  flutter332,
  makeDesktopItem,
  quickemu,
}:
flutter332.buildFlutterApplication rec {
  pname = "quickgui";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "quickemu-project";
    repo = "quickgui";
    rev = version;
    hash = "sha256-M2Qy66RqsjXg7ZpHwaXCN8qXRIsisnIyaENx3KqmUfQ=";
  };

  nativeBuildInputs = [ copyDesktopItems ];

  postFixup = ''
    for n in 16 32 48 64 128 256 512; do
      size=$n"x"$n
      mkdir -p $out/share/icons/hicolor/$size/apps/
      cp -av assets/resources/quickgui_$n.png $out/share/icons/hicolor/$size/apps/quickgui.png
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "System"
      ];

      comment = "An elegant virtual machine manager for the desktop";
      desktopName = "Quickgui";
      exec = "quickgui";
      icon = "quickgui";
      name = "quickgui";
    })
  ];

  extraWrapProgramArgs = "--prefix PATH : ${
    lib.makeBinPath [
      quickemu
    ]
  }";

  gitHashes = {
    window_size = "sha256-XelNtp7tpZ91QCEcvewVphNUtgQX7xrp5QP0oFo6DgM=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  meta = {
    description = "Elegant virtual machine manager for the desktop";
    homepage = "https://github.com/quickemu-project/quickgui";
    changelog = "https://github.com/quickemu-project/quickgui/releases/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flexiondotorg
      heyimnova
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "quickgui";
  };
}
