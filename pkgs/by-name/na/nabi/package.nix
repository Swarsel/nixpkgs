{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gettext,
  gtk2,
  libhangul,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nabi";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "libhangul";
    repo = "nabi";
    tag = "nabi-${finalAttrs.version}";
    hash = "sha256-U3W8G7cJ+lIqso6gSixmenX1cWnKuJO6dumUz4SUWi0=";
  };

  postPatch = ''
    patchShebangs ./autogen.sh
    substituteInPlace ./autogen.sh --replace-fail "autopoint" "autopoint --force"
    substituteInPlace ./autogen.sh --replace-fail "aclocal" "aclocal -I m4"
  '';

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    gettext
  ];

  buildInputs = [
    gtk2
    libhangul
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = {
    description = "Easy Hangul XIM";
    homepage = "https://github.com/libhangul/nabi";
    changelog = "https://github.com/libhangul/nabi/blob/nabi-${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ianwookim ];
    platforms = lib.platforms.linux;
    mainProgram = "nabi";
  };
})
