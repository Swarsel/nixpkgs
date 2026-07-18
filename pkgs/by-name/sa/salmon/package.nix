{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  bzip2,
  catch2_3,
  cereal,
  cmake,
  curl,
  htslib,
  icu,
  jemalloc,
  libdeflate,
  libgff,
  libiconv,
  libstaden-read,
  mimalloc,
  onetbb,
  openssl,
  pkg-config,
  python3,
  xz,
  zlib-ng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "salmon";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "COMBINE-lab";
    repo = "salmon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ggFPp6sHPcR4Wq/B0AaMVf0LZVIz+QcvKMNrTfnAY4w=";
  };

  patches = [ ./fix_pufferfish.patch ];

  postPatch = ''
    patchShebangs .

    substituteInPlace CMakeLists.txt --replace-fail "CMP0167 OLD" "CMP0167 NEW"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    (boost.override {
      enableShared = false;
      enabledStatic = true;
    })
    bzip2
    catch2_3
    cereal
    curl
    htslib
    icu
    jemalloc
    libdeflate
    libgff
    libstaden-read
    mimalloc
    onetbb
    openssl
    xz
    zlib-ng
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  cmakeFlags = [
    "-DSALMON_PUFFERFISH_SOURCE_DIR=${finalAttrs.pufferFishSrc}"
    "-DSALMON_FQFEEDER_SOURCE_DIR=${finalAttrs.FQFeederSrc}"
    "-DSALMON_FETCH_MISSING_DEPS=OFF"
  ];

  # These are needed to please htslib
  env.NIX_LDFLAGS = toString [
    "-lcrypto"
    "-ldeflate"
  ];

  # SALMON_FQFEEDER_GIT_TAG defined in cmake/SalmonDependencies.cmake
  FQFeederSrc = fetchFromGitHub {
    hash = "sha256-csRKUdNlEKKHNIvKRRTt79+27LBmnsJpswzBnWtA/XU=";
    owner = "rob-p";
    repo = "FQFeeder";
    rev = "f5b08d1002351c192b69048ac9f6cf4c7c116265";
  };

  # SALMON_PUFFERFISH_GIT_TAG defined in cmake/SalmonDependencies.cmake
  pufferFishSrc = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-N9KYmFsl90eY8R1wH1Jbi3nnNld6YVGeQjqoxYxPqtE=";
    owner = "COMBINE-lab";
    repo = "pufferfish";
    rev = "1c788594cef77f0558b183281f32152e0ed22ba9";
  };

  meta = {
    description = "Tool for quantifying the expression of transcripts using RNA-seq data";

    longDescription = ''
      Salmon is a tool for quantifying the expression of transcripts
      using RNA-seq data. Salmon uses new algorithms (specifically,
      coupling the concept of quasi-mapping with a two-phase inference
      procedure) to provide accurate expression estimates very quickly
      and while using little memory. Salmon performs its inference using
      an expressive and realistic model of RNA-seq data that takes into
      account experimental attributes and biases commonly observed in
      real RNA-seq data.
    '';

    homepage = "https://combine-lab.github.io/salmon";
    changelog = "https://github.com/COMBINE-lab/salmon/releases/tag/" + "v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "salmon";
    downloadPage = "https://github.com/COMBINE-lab/salmon/releases";
  };
})
