{
  lib,
  stdenv,
  fetchFromGitHub,
  duperemove,
  glib,
  libbsd,
  libgcrypt,
  pkg-config,
  sqlite,
  testers,
  util-linux,
  xxhash,
  linuxHeaders ? stdenv.cc.libc.linuxHeaders,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "duperemove";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "markfasheh";
    repo = "duperemove";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Y3HIqq61bLfZi4XR2RtSyuCPmcWrTxeWvqpTh+3hUjc=";
  };

  postPatch = ''
    substituteInPlace util.c --replace \
      "lscpu" "${lib.getBin util-linux}/bin/lscpu"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libbsd
    libgcrypt
    glib
    linuxHeaders
    sqlite
    util-linux
    xxhash
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "VERSION=v${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "duperemove --version";
    package = duperemove;
  };

  meta = {
    description = "Simple tool for finding duplicated extents and submitting them for deduplication";
    homepage = "https://github.com/markfasheh/duperemove";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      thoughtpolice
    ];

    platforms = lib.platforms.linux;
    mainProgram = "duperemove";
  };
})
