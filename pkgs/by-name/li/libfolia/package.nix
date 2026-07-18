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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfolia";
  version = "2.22";

  src = fetchFromGitHub {
    owner = "LanguageMachines";
    repo = "libfolia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D7iA40E0dkkLCqjLUcUd5UvoQJnIzdXAPdXPyeozrow=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    bzip2
    libtool
    autoconf-archive
    libtar
    libxml2
    icu
    ticcutils
  ];

  # compat with icu61+ https://github.com/unicode-org/icu/blob/release-64-2/icu4c/readme.html#L554
  env.CXXFLAGS = toString [ "-DU_USING_ICU_NAMESPACE=1" ];

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
    description = "C++ API for FoLiA documents; an XML-based linguistic annotation format";

    longDescription = ''
      A high-level C++ API to read, manipulate, and create FoLiA documents. FoLiA is an XML-based annotation format, suitable for the representation of linguistically annotated language resources. FoLiA’s intended use is as a format for storing and/or exchanging language resources, including corpora.
    '';

    homepage = "https://proycon.github.io/folia/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ roberth ];
    platforms = lib.platforms.all;
    mainProgram = "folialint";
  };

})
