{
  lib,
  fetchurl,
  R,
  buildPythonPackage,
  bzip2,
  cffi,
  icu,
  isPyPy,
  libdeflate,
  pytestCheckHook,
  rWrapper,
  setuptools,
  xz,
  zlib,
  zstd,
}:

buildPythonPackage rec {
  pname = "rpy2-rinterface";
  version = "3.6.6";

  src = fetchurl {
    url = "mirror://pypi/${builtins.substring 0 1 pname}/${pname}/${
      builtins.replaceStrings [ "-" ] [ "_" ] pname
    }-${version}.tar.gz";

    hash = "sha256-qcwTQc5ctN8dxnxA3Dss4Mr6znIVvUJi/g7QEZWKM2k=";
  };

  patches = [
    # https://github.com/rpy2/rpy2/pull/1171#issuecomment-3263994962
    ./restore-initr-simple.patch

    # R_LIBS_SITE is used by the nix r package to point to the installed R libraries.
    # This patch sets R_LIBS_SITE when rpy2 is imported.
    ./rpy2-3.x-r-libs-site.patch
  ];

  postPatch = ''
    substituteInPlace 'src/rpy2/rinterface_lib/embedded.py' \
      --replace-fail '@NIX_R_LIBS_SITE@' "$R_LIBS_SITE"
  '';

  nativeBuildInputs = [
    R # needed at setup time to detect R_HOME (alternatively set R_HOME explicitly)
  ];

  buildInputs = [
    xz
    bzip2
    zlib
    zstd
    icu
    libdeflate
  ]
  ++ rWrapper.recommendedPackages;

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    cffi
  ];

  disabled = isPyPy;

  # https://github.com/rpy2/rpy2/issues/1111
  disabledTests = [
    "test_parse_incomplete_error"
    "test_parse_error"
    "test_parse_error_when_evaluting"
  ];

  pyproject = true;

  meta = {
    description = "Python interface to R";
    homepage = "https://rpy2.github.io/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ sage ];
  };
}
