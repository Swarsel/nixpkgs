{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gettext,
  glib,
  libtool,
  libx11,
  libxrandr,
  perl,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-launch";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "bbidulock";
    repo = "xdg-launch";
    rev = finalAttrs.version;
    sha256 = "sha256-S/0Wn1T5MSOPN6QXkzfmygHL6XTAnnMJr5Z3fBzsHEw=";
  };

  postPatch = ''
    # fix gettext configuration
    echo 'AM_GNU_GETTEXT_VERSION' >> configure.ac
    echo 'AM_GNU_GETTEXT([external])' >> configure.ac

    sed -i data/*.desktop \
      -e "s,/usr/bin,/$out/bin,g"
  '';

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    libtool
    perl # pod2man
    pkg-config
  ];

  buildInputs = [
    libx11
    libxrandr
    glib # can be optional
  ];

  preConfigure = "./autogen.sh";

  meta = {
    description = "Command line XDG compliant launcher and tools";
    homepage = "https://github.com/bbidulock/xdg-launch";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.ck3d ];
    platforms = lib.platforms.linux;
  };
})
