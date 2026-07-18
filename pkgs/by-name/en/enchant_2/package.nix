{
  lib,
  stdenv,
  fetchurl,
  aspell,
  glib,
  groff,
  hspell,
  hunspell,
  libvoikko,
  nuspell,
  pkg-config,
  unittest-cpp,
  withAppleSpell ? stdenv.hostPlatform.isDarwin,
  withAspell ? true,
  withHspell ? true,
  withHunspell ? true,
  withNuspell ? true,
  withVoikko ? true,
}:

assert withAppleSpell -> stdenv.hostPlatform.isDarwin;

stdenv.mkDerivation (finalAttrs: {
  pname = "enchant";
  version = "2.6.9";

  src = fetchurl {
    url = "https://github.com/rrthomas/enchant/releases/download/v${finalAttrs.version}/enchant-${finalAttrs.version}.tar.gz";
    hash = "sha256-2aWhDcmzikOzoPoix27W67fgnrU1r/YpVK/NvUDv/2s=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    groff
    pkg-config
  ];

  buildInputs = [
    glib
  ]
  ++ lib.optionals withHunspell [
    hunspell
  ]
  ++ lib.optionals withNuspell [
    nuspell
  ]
  ++ lib.optionals withVoikko [
    libvoikko
  ];

  # libtool puts these to .la files
  propagatedBuildInputs =
    lib.optionals withHspell [
      hspell
    ]
    ++ lib.optionals withAspell [
      aspell
    ];

  configureFlags = [
    "--enable-relocatable" # needed for tests
    (lib.withFeature withAspell "aspell")
    (lib.withFeature withHspell "hspell")
    (lib.withFeature withHunspell "hunspell")
    (lib.withFeature withNuspell "nuspell")
    (lib.withFeature withVoikko "voikko")
    (lib.withFeature withAppleSpell "applespell")
  ];

  doCheck = true;

  checkInputs = [
    unittest-cpp
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Generic spell checking library";
    homepage = "https://rrthomas.github.io/enchant/";
    license = lib.licenses.lgpl21Plus; # with extra provision for non-free checkers
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
  };
})
