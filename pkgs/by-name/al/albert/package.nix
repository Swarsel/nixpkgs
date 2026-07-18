{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  libarchive,
  libqalculate,
  muparser,
  nix-update-script,
  pkg-config,
  python3Packages,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "albert";
  version = "34.0.10";

  src = fetchFromGitHub {
    owner = "albertlauncher";
    repo = "albert";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ryjv8oLUXxK9iOa4ed1lDEbMM7nRj9I02gVT0JNHonQ=";
    fetchSubmodules = true;
  };

  postPatch = ''
    find -type f -name CMakeLists.txt -exec sed -i {} -e '/INSTALL_RPATH/d' \;

    substituteInPlace src/app/qtpluginprovider.cpp \
      --replace-fail "QStringList install_paths;" "QStringList install_paths;${"\n"}install_paths << QFileInfo(\"$out/lib\").canonicalFilePath();"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qcoro
    kdePackages.qtkeychain
    libqalculate
    libarchive
    muparser
  ]
  ++ (with qt6; [
    qt5compat
    qtbase
    qtdeclarative
    qtscxml
    qtsvg
    qttools
    qtwayland
  ])
  ++ (with python3Packages; [
    python
    pybind11
  ]);

  postFixup = ''
    for i in $out/{bin/.albert-wrapped,lib/albert/plugins/*.so}; do
      patchelf $i --add-rpath $out/lib/albert
    done
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast and flexible keyboard launcher";

    longDescription = ''
      Albert is a desktop agnostic launcher. Its goals are usability and beauty,
      performance and extensibility. It is written in C++ and based on the Qt
      framework.
    '';

    homepage = "https://albertlauncher.github.io";
    changelog = "https://github.com/albertlauncher/albert/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    # See: https://github.com/NixOS/nixpkgs/issues/279226
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      eljamm
    ];

    platforms = lib.platforms.linux;
    mainProgram = "albert";
  };
})
