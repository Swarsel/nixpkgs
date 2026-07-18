{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gamemode,
  gamescope,
  icoextract,
  icoutils,
  icu,
  mangohud,
  pkg-config,
  qt6,
  qt6Packages,
  umu-launcher,
  winetricks,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nero-umu";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "SeongGino";
    repo = "Nero-umu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dwM9ZRgNBLA16faO68pSnNsfWC4Naom6QRg1RYwXxLA=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    qt6.qt5compat
    qt6Packages.quazip
    icu
  ];

  cmakeFlags = [
    (lib.cmakeFeature "NERO_QT_VERSION" "Qt6")
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "nero-umu" "$out/bin/nero-umu"
    for size in 32 48 64 128; do
      install -Dm644 "$src/img/ico/ico_"$size".png" "$out/share/icons/hicolor/"$size"x"$size"/apps/xyz.TOS.Nero.png"
    done
    install -Dm644 "$src/xyz.TOS.Nero.desktop" "$out/share/applications/xyz.TOS.Nero.desktop"
    runHook postInstall
  '';

  preFixup = ''
    qtWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps}
    )
  '';

  #Replace quazip git submodule with pre-packaged quazip
  postUnpack = ''
    rmdir source/lib/quazip/
    ln -s ${qt6Packages.quazip.src} source/lib/quazip
  '';

  runtimeDeps = [
    icoextract
    icoutils
    winetricks
    umu-launcher
    mangohud
    gamescope
    gamemode
  ];

  meta = {
    description = "Fast and efficient Proton prefix runner and manager using umu as backend";
    homepage = "https://github.com/SeongGino/Nero-umu";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      ern775
      blghnks
      keenanweaver
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "nero-umu";
  };
})
