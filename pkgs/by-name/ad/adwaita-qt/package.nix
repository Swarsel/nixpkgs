{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libxcb,
  ninja,
  nix-update-script,
  qt5,
  qt6,
  useQt6 ? false,
}:
let
  qt = if useQt6 then qt6 else qt5;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "adwaita-qt";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "FedoraQt";
    repo = "adwaita-qt";
    tag = finalAttrs.version;
    hash = "sha256-K/+SL52C+M2OC4NL+mhBnm/9BwH0KNNTGIDmPwuUwkM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # Fix plugin dir
    substituteInPlace src/style/CMakeLists.txt \
       --replace-fail "DESTINATION \"\''${QT_PLUGINS_DIR}/styles" "DESTINATION \"$qtPluginPrefix/styles"
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    qt.qtbase
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libxcb
  ]
  ++ lib.optionals (!useQt6) [
    qt5.qtx11extras
  ]
  ++ lib.optionals useQt6 [
    qt6.qtwayland
  ];

  cmakeFlags = lib.optionals useQt6 [
    "-DUSE_QT6=true"
  ];

  # Qt setup hook complains about missing `wrapQtAppsHook` otherwise.
  dontWrapQtApps = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Style to bend Qt applications to look like they belong into GNOME Shell";
    homepage = "https://github.com/FedoraQt/adwaita-qt";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
