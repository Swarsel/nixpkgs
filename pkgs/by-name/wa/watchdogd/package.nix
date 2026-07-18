{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libconfuse,
  libite,
  libuev,
  nixosTests,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "watchdogd";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "watchdogd";
    rev = finalAttrs.version;
    hash = "sha256-Q3j16hxDwusZdmIjHm/CVi7VrwRziPGERAvJ3F/Bvdg=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libite
    libuev
    libconfuse
  ];

  passthru.tests = { inherit (nixosTests) watchdogd; };

  meta = {
    description = "Advanced system & process supervisor for Linux";
    homepage = "https://troglobit.com/watchdogd.html";
    changelog = "https://github.com/troglobit/watchdogd/releases/tag/${finalAttrs.version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ vifino ];
    platforms = lib.platforms.linux;
  };
})
