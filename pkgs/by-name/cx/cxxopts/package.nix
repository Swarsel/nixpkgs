{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch2,
  icu,
  pkg-config,
  testers,
  validatePkgConfig,
  enableUnicodeHelp ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cxxopts";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "jarro2783";
    repo = "cxxopts";
    rev = "v${finalAttrs.version}";
    hash = "sha256-baM6EX9D0yfrKxuPXyUUV9RqdrVLyygeG6x57xN8lc4=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-bqd3H66Op1/EkN2HLd84Obky4Y2ndPPY8MGZ5fqtdk4=";
      name = "fix-icu-uc-typo-in-pkgconfig.patch";
      url = "https://github.com/jarro2783/cxxopts/commit/e98c73d665915b292a0592bf34fcbe8522035bc1.patch?full_index=1";
    })
  ];

  # https://github.com/jarro2783/cxxopts/issues/332
  postPatch = ''
    substituteInPlace packaging/pkgconfig.pc.in \
      --replace-fail '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
  '';

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals enableUnicodeHelp [
    pkg-config
    validatePkgConfig
  ];

  propagatedBuildInputs = lib.optionals enableUnicodeHelp [ icu.dev ];

  cmakeFlags = [
    "-DCXXOPTS_BUILD_EXAMPLES=OFF"
    "-DCXXOPTS_CXX_STANDARD=17"
  ]
  ++ lib.optional enableUnicodeHelp "-DCXXOPTS_USE_UNICODE_HELP=TRUE";

  doCheck = true;
  # Conflict on case-insensitive filesystems.
  dontUseCmakeBuildDir = true;

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };
  };

  meta = {
    description = "Lightweight C++ GNU-style option parser library";
    homepage = "https://github.com/jarro2783/cxxopts";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.spease ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "cxxopts" ];
  };
})
