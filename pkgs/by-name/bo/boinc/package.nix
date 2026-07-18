{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  curl,
  gtk3,
  libGL,
  libGLU,
  libglut,
  libjpeg,
  libnotify,
  libtool,
  libx11,
  libxcb,
  libxcb-util,
  libxi,
  libxmu,
  libxscrnsaver,
  m4,
  patchelf,
  pkg-config,
  sqlite,
  wxwidgets_3_2,
  headless ? false,
}:

stdenv.mkDerivation rec {
  pname = "boinc";
  version = "8.2.13";

  src = fetchFromGitHub {
    owner = "BOINC";
    repo = "boinc";
    rev = "client_release/${lib.versions.majorMinor version}/${version}";
    hash = "sha256-BzP3yDGAhJ1DtrxLEc3s27EwJilMVi6A1NoTv0NwH9c=";
    name = "${pname}-${version}-src";
  };

  nativeBuildInputs = [
    libtool
    automake
    autoconf
    m4
    pkg-config
  ];

  buildInputs = [
    curl
    sqlite
    patchelf
  ]
  ++ lib.optionals (!headless) [
    libGLU
    libGL
    libxmu
    libxi
    libglut
    libjpeg
    wxwidgets_3_2
    gtk3
    libxscrnsaver
    libnotify
    libx11
    libxcb
    libxcb-util
  ];

  configureFlags = [
    "--disable-server"
    "--sysconfdir=${placeholder "out"}/etc"
  ]
  ++ lib.optionals headless [ "--disable-manager" ];

  env = lib.optionalAttrs (!headless) {
    NIX_LDFLAGS = "-lX11";
  };

  preConfigure = ''
    ./_autosetup
  '';

  postInstall = ''
    install --mode=444 -D 'client/scripts/boinc-client.service' "$out/etc/systemd/system/boinc.service"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Free software for distributed and grid computing";
    homepage = "https://boinc.berkeley.edu/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ Luflosi ];
    platforms = lib.platforms.linux;
  };
}
