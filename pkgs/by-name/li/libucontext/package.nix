{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libucontext";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "kaniini";
    repo = "libucontext";
    rev = "libucontext-${finalAttrs.version}";
    hash = "sha256-asT0pV3s4L4zB2qtDJ+2XYxEP6agIEo1LtCuFeOjpRA=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ucontext implementation featuring glibc-compatible ABI";
    homepage = "https://github.com/kaniini/libucontext";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lix ];
  };
})
