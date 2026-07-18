{
  lib,
  stdenv,
  fetchurl,
  boost,
  cairo,
  fontconfig,
  libsigcxx30,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cairomm";
  version = "1.18.0";

  src = fetchurl {
    url = "https://www.cairographics.org/releases/cairomm-${finalAttrs.version}.tar.xz";
    sha256 = "uBJVOU4+qOiqiHJ20ir6iYX8ja72BpLrJAfSMEnwPPs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    boost # for tests
    fontconfig
  ];

  propagatedBuildInputs = [
    cairo
    libsigcxx30
  ];

  mesonFlags = [
    "-Dbuild-tests=true"
  ];

  # Tests fail on Darwin, possibly because of sandboxing.
  doCheck = !stdenv.hostPlatform.isDarwin;

  meta = {
    description = "C++ bindings for the Cairo vector graphics library";
    homepage = "https://www.cairographics.org/";

    license = with lib.licenses; [
      lgpl2Plus
      mpl10
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
