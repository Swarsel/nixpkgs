{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  libev,
  libevdev,
  ninja,
  pkg-config,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "illum";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "codyps";
    repo = "illum";
    tag = "v${finalAttrs.version}";
    sha256 = "S4lUBeRnZlRUpIxFdN/bh979xvdS7roF6/6Dk0ZUrnM=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      name = "prevent-unplug-segfault"; # See https://github.com/codyps/illum/issues/19
      sha256 = "sha256-hIBBCIJXAt8wnZuyKye1RiEfOCelP3+4kcGrM43vFOE=";
      url = "https://github.com/codyps/illum/commit/47b7cd60ee892379e5d854f79db343a54ae5a3cc.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    ninja
    libevdev
    libev
    udev
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv illum-d $out/bin
  '';

  configurePhase = ''
    runHook preConfigure

    bash ./configure

    runHook postConfigure
  '';

  meta = {
    description = "Daemon that wires button presses to screen backlight level";
    homepage = "https://github.com/codyps/illum";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.dancek ];
    platforms = lib.platforms.linux;
    mainProgram = "illum-d";
  };
})
