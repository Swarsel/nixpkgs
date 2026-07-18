{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
  python3Packages,
  wrapGAppsHook3,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pixelflasher";
  version = "8.14.3.1";

  src = fetchFromGitHub {
    owner = "badabing2005";
    repo = "PixelFlasher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ey6wUl/9OaXxnQ17PvnhpBFB21++WbUsRhkGlrr7Yuk=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    python3Packages.pyinstaller
    copyDesktopItems
  ];

  buildPhase =
    let
      specFile =
        if stdenv.hostPlatform.isDarwin then
          if stdenv.hostPlatform.isAarch64 then "build-on-mac" else "build-on-mac-intel-only"
        else
          "build-on-linux";
    in
    ''
      runHook preBuild

      pyinstaller --clean --noconfirm --log-level=DEBUG ${specFile}.spec

      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/64x64/apps
    cp dist/PixelFlasher $out/bin/pixelflasher
    cp images/icon-64.png $out/share/icons/hicolor/64x64/apps/pixelflasher.png

    runHook postInstall
  '';

  dependencies = with python3Packages; [
    attrdict
    beautifulsoup4
    bsdiff4
    chardet
    cryptography
    darkdetect
    httplib2
    json5
    lz4
    markdown
    platformdirs
    polib
    protobuf
    psutil
    pyperclip
    requests
    rsa
    six
    wxpython
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      desktopName = "PixelFlasher";
      exec = "pixelflasher";
      genericName = "Pixel™ phone flashing GUI utility with features";
      icon = "pixelflasher";
      name = "PixelFlasher";
    })
  ];

  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pixel™ phone flashing GUI utility with features";
    homepage = "https://github.com/badabing2005/PixelFlasher";
    changelog = "https://github.com/badabing2005/PixelFlasher/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ cything ];
    platforms = lib.platforms.linux;
    mainProgram = "pixelflasher";
  };
})
