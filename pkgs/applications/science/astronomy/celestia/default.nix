{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch2,
  gtk2,
  gtkglext,
  libGL,
  libGLU,
  libglut,
  libjpeg_turbo,
  libtheora,
  libxmu,
  lua,
  perl,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "celestia";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "CelestiaProject";
    repo = "Celestia";
    rev = version;
    sha256 = "sha256-MkElGo1ZR0ImW/526QlDE1ePd+VOQxwkX7l+0WyZ6Vs=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-hEZ6BhSEx6Qm+fLisc63xSCDT6GX92AHD0BuldOhzFk=";
      url = "https://github.com/CelestiaProject/Celestia/commit/94894bed3bf98d41c5097e7829d491d8ff8d4a62.patch?full_index=1";
    })
  ];

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail "dnl AM_GNU_GETTEXT_VERSION([0.15])" "AM_GNU_GETTEXT_VERSION([0.15])"
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libglut
    gtk2
    gtkglext
    lua
    perl
    libjpeg_turbo
    libtheora
    libxmu
    libGLU
    libGL
  ];

  configureFlags = [
    "--with-gtk"
    "--with-lua=${lua}"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Real-time 3D simulation of space";
    homepage = "https://celestiaproject.space/";
    changelog = "https://github.com/CelestiaProject/Celestia/releases/tag/${version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      returntoreality
    ];

    platforms = lib.platforms.linux;
    mainProgram = "celestia";
  };
}
