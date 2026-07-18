{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gitUpdater,
  incus,
  libuv,
  lz4,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "raft-cowsql";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "cowsql";
    repo = "raft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aGw/ATu8Xdjfqa0qWg8Sld9PKCmQsMtZhuNBwagER7M=";
  };

  outputs = [
    "dev"
    "out"
  ];

  patches = [
    # network tests either hang indefinitely, or fail outright
    ./disable-net-tests.patch

    # missing dir check is flaky
    ./disable-missing-dir-test.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libuv
    lz4
  ];

  preConfigure = ''
    substituteInPlace configure --replace /usr/bin/ " "
  '';

  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    inherit (incus) tests;

    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Asynchronous C implementation of the Raft consensus protocol";
    homepage = "https://github.com/cowsql/raft";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxc ];
  };
})
