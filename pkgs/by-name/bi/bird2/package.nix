{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bison,
  flex,
  libssh,
  nixosTests,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bird";
  version = "2.19.1";

  src = fetchFromGitLab {
    owner = "labs";
    repo = "bird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8D83U9IgNQ0HDWk2WSQsRsy82bDmjkgectkCOXy2RyI=";
    domain = "gitlab.nic.cz";
  };

  patches = [
    ./dont-create-sysconfdir-2.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    flex
    bison
  ];

  buildInputs = [
    readline
    libssh
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--runstatedir=/run/bird"
  ];

  env.CPP = "${stdenv.cc.targetPrefix}cpp -E";
  passthru.tests = nixosTests.bird2;

  meta = {
    description = "BIRD Internet Routing Daemon";
    homepage = "https://bird.network.cz";
    changelog = "https://gitlab.nic.cz/labs/bird/-/blob/v${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ herbetom ];
    platforms = lib.platforms.linux;
  };
})
