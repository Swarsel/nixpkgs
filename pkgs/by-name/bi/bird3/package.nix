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
  version = "3.3.1";

  src = fetchFromGitLab {
    owner = "labs";
    repo = "bird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aJo6Ut/ULBDGoekSXgN1WvmFmonTzNA3TES1FHqCiOM=";
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
  passthru.tests = nixosTests.bird3;

  meta = {
    description = "BIRD Internet Routing Daemon";
    homepage = "https://bird.nic.cz/";
    changelog = "https://gitlab.nic.cz/labs/bird/-/blob/v${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ herbetom ];
    platforms = lib.platforms.linux;
  };
})
