{
  lib,
  stdenv,
  fetchurl,
  bash-completion,
  cmocka,
  git,
  libftdi1,
  libjaylink,
  libusb1,
  meson,
  ninja,
  openssl,
  pciutils,
  pkg-config,
  sphinx,
  jlinkSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flashrom";
  version = "1.7.0";

  src = fetchurl {
    url = "https://download.flashrom.org/releases/flashrom-v${finalAttrs.version}.tar.xz";
    hash = "sha256-Qyis6YM/fv58M0vdc0gs3oKGgZgmzAAUnoP7qWvzq08=";
  };

  postPatch = ''
    substituteInPlace util/flashrom_udev.rules \
      --replace 'GROUP="plugdev"' 'TAG+="uaccess", TAG+="udev-acl"'
  '';

  nativeBuildInputs = [
    git
    meson
    ninja
    pkg-config
    sphinx
    bash-completion
  ];

  buildInputs = [
    openssl
    cmocka
    libftdi1
    libusb1
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ pciutils ]
  ++ lib.optional jlinkSupport libjaylink;

  mesonFlags = [
    (lib.mesonBool "werror" false)
    (lib.mesonOption "programmer" "auto")
    (lib.mesonEnable "man-pages" true)
    (lib.mesonEnable "tests" (!stdenv.buildPlatform.isDarwin))
    (lib.mesonEnable "generate_authors_list" false)
  ];

  env = lib.optionalAttrs (stdenv.cc.isClang && !stdenv.hostPlatform.isDarwin) {
    NIX_CFLAGS_COMPILE = "-Wno-gnu-folding-constant";
  };

  doCheck = !stdenv.hostPlatform.isDarwin;

  postInstall = ''
    install -Dm644 $NIX_BUILD_TOP/$sourceRoot/util/flashrom_udev.rules $out/lib/udev/rules.d/flashrom.rules
  '';

  doInstallCheck = true;

  meta = {
    description = "Utility for reading, writing, erasing and verifying flash ROM chips";
    homepage = "https://www.flashrom.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.all;
    mainProgram = "flashrom";
  };
})
