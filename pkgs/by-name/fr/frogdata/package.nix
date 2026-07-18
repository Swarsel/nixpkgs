{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  frog,
  gitUpdater,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "frogdata";
  version = "0.22";

  src = fetchFromGitHub {
    owner = "LanguageMachines";
    repo = "frogdata";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N5AA3y18nPpqrnkDpnTweucz6l1aabQyosX4OwPBUzo=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libtool
    autoconf-archive
  ];

  passthru = {
    tests = {
      /**
        Reverse dependencies. Does not respect overrides.
      */
      reverseDependencies = lib.recurseIntoAttrs {
        inherit frog;
      };
    };

    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Data for Frog, a Tagger-Lemmatizer-Morphological-Analyzer-Dependency-Parser for Dutch";
    homepage = "https://languagemachines.github.io/frog";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ roberth ];
    platforms = lib.platforms.all;
  };

})
