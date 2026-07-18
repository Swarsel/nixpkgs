{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bzip2,
  coreutils,
  dosfstools,
  libarchive,
  libconfuse,
  libsodium,
  mtools,
  pkg-config,
  unzip,
  which,
  xdelta,
  xz,
  zip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fwup";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "fwup-home";
    repo = "fwup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SIRDVlC/g+rq5m4Ind7dqPzjdCjAxRK/kAdXt6byL/8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    bzip2
    libarchive
    libconfuse
    libsodium
    xz
    zlib
  ];

  propagatedBuildInputs = [
    coreutils
    unzip
    zip
  ]
  ++ lib.optionals finalAttrs.doCheck [
    mtools
    dosfstools
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    which
    xdelta
  ];

  meta = {
    description = "Configurable embedded Linux firmware update creator and runner";
    homepage = "https://github.com/fwup-home/fwup";
    changelog = "https://github.com/fwup-home/fwup/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.georgewhewell ];
    platforms = lib.platforms.all;
  };
})
