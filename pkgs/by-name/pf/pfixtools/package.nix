{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  git,
  gperf,
  libev,
  libsrs2,
  pcre,
  pkg-config,
  tokyocabinet,
  unbound,
}:

let
  version = "0.9";

  pfixtoolsSrc = fetchFromGitHub {
    owner = "Fruneau";
    repo = "pfixtools";
    rev = "pfixtools-${version}";
    sha256 = "1vmbrw686f41n6xfjphfshn96vl07ynvnsyjdw9yfn9bfnldcjcq";
  };

  srcRoot = pfixtoolsSrc.name;

  libCommonSrc = fetchFromGitHub {
    owner = "Fruneau";
    repo = "libcommon";
    rev = "b07e6bdea3d24748e0d39783d7d817096d10cc67";
    sha256 = "14fxldp29j4vmfmhfgwwi37pj8cz0flm1aykkxlbgakz92d4pm35";
  };

in

stdenv.mkDerivation {
  inherit version;
  pname = "pfixtools";
  src = pfixtoolsSrc;
  patches = [ ./0001-Fix-build-with-unbound-1.6.1.patch ];

  postPatch = ''
    substituteInPlace postlicyd/policy_tokens.sh \
                      --replace /bin/bash ${bash}/bin/bash;

    substituteInPlace postlicyd/*_tokens.sh \
      --replace "unsigned int" "size_t"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    git
    gperf
    pcre
    unbound
    libev
    tokyocabinet
    bash
    libsrs2
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "prefix="
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result -Wno-error=nonnull-compare -Wno-error=format-truncation";

  postUnpack = ''
    cp -Rp ${libCommonSrc}/* ${srcRoot}/common;
    chmod -R +w ${srcRoot}/common;
  '';

  meta = {
    description = "Collection of postfix-related tools";
    homepage = "https://github.com/Fruneau/pfixtools";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ jerith666 ];
    platforms = lib.platforms.linux;
  };
}
