{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  gnome-common,
  gobject-introspection,
  json-glib,
  libgee,
  libtool,
  libxkbcommon,
  pkg-config,
  skkDictionaries,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libskk";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ueno";
    repo = "libskk";
    tag = finalAttrs.version;
    hash = "sha256-Dciz5VeflaX2eYt1B90NpgLKNtCHY/CDabuCx+T/SS0=";
  };

  nativeBuildInputs = [
    vala
    gnome-common
    gobject-introspection
    libtool
    gettext
    pkg-config
  ];

  buildInputs = [ libxkbcommon ];

  propagatedBuildInputs = [
    libgee
    json-glib
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=int-conversion"
    ];
  };

  # link SKK-JISYO.L from skkdicts for the bundled tool `skk`
  preInstall = ''
    dictDir=$out/share/skk
    mkdir -p $dictDir
    ln -s ${skkDictionaries.l}/share/skk/SKK-JISYO.L $dictDir/
  '';

  configureScript = "./autogen.sh";
  enableParallelBuilding = true;

  meta = {
    description = "Library to deal with Japanese kana-to-kanji conversion method";

    longDescription = ''
      Libskk is a library that implements basic features of SKK including:
      new word registration, completion, numeric conversion, abbrev mode, kuten input,
      hankaku-katakana input, Lisp expression evaluation (concat only), and re-conversion.
      It also supports various typing rules including: romaji-to-kana, AZIK, TUT-Code, and NICOLA,
      as well as various dictionary types including: file dictionary (such as SKK-JISYO.[SML]),
      user dictionary, skkserv, and CDB format dictionary.
    '';

    homepage = "https://github.com/ueno/libskk";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ yuriaisaka ];
    platforms = lib.platforms.linux;
    mainProgram = "skk";
  };
})
