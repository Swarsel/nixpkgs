{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cmake,
  doxygen,
  graphviz,
  libGL,
  libffi,
  makeFontsConf,
  pkg-config,
  pugixml,
  wayland,
  docSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waylandpp";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "NilsBrause";
    repo = "waylandpp";
    tag = finalAttrs.version;
    hash = "sha256-vKYKUXq5lmjQcZ0rD+b2O7N1iCVnpkpKd8Z/RTI083g=";
  };

  outputs = [
    "bin"
    "dev"
    "lib"
    "out"
  ]
  ++ lib.optionals docSupport [
    "doc"
    "devman"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optionals docSupport [
    doxygen
    graphviz
  ];

  buildInputs = [
    pugixml
    wayland
    libGL
    libffi
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_DATADIR" (placeholder "dev"))
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    (lib.cmakeFeature "WAYLAND_SCANNERPP" "${buildPackages.waylandpp}/bin/wayland-scanner++")
  ];

  # Complains about not being able to find the fontconfig config file otherwise
  env = lib.optionalAttrs docSupport {
    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [ ];
    };
  };

  # Resolves the warning "Fontconfig error: No writable cache directories"
  preBuild = ''
    export XDG_CACHE_HOME="$(mktemp -d)"
  '';

  meta = {
    description = "Wayland C++ binding";
    homepage = "https://github.com/NilsBrause/waylandpp/";

    license = with lib.licenses; [
      bsd2
      hpnd
    ];

    maintainers = with lib.maintainers; [ minijackson ];
    platforms = lib.platforms.linux;
    mainProgram = "wayland-scanner++";
  };
})
