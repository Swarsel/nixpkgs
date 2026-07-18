{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  bzip2,
  frog,
  gitUpdater,
  icu,
  libtar,
  libtool,
  libxml2,
  pkg-config,
  ticcutils,
  timbl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mbt";
  version = "3.11";

  src = fetchFromGitHub {
    owner = "LanguageMachines";
    repo = "mbt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7PpUa/WoPMjdADi1ongQkvqSDWPeb1dNsWee2hjGArk=";
  };

  patches = [ ./mbt-add-libxml2-dep.patch ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    bzip2
    libtar
    libtool
    autoconf-archive
    libxml2
    icu
    ticcutils
    timbl
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
    description = "Memory Based Tagger";

    longDescription = ''
      MBT is a memory-based tagger-generator and tagger in one. The tagger-generator part can generate a sequence tagger on the basis of a training set of tagged sequences; the tagger part can tag new sequences. MBT can, for instance, be used to generate part-of-speech taggers or chunkers for natural language processing. It has also been used for named-entity recognition, information extraction in domain-specific texts, and disfluency chunking in transcribed speech.

      Mbt is used by Frog for Dutch tagging.
    '';

    homepage = "https://languagemachines.github.io/mbt/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ roberth ];
    platforms = lib.platforms.all;
  };

})
