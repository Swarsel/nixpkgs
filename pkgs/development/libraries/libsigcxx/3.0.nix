{
  lib,
  stdenv,
  fetchFromGitHub,
  gnome,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsigc++";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "libsigcplusplus";
    repo = "libsigcplusplus";
    tag = finalAttrs.version;
    hash = "sha256-ZV1gcq/efFaf4MkkDZP9Z1isNqwnvUWWouVwtTnpyhc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "libsigcxx30";
      packageName = "libsigc++";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Typesafe callback system for standard C++";
    homepage = "https://libsigcplusplus.github.io/libsigcplusplus/";
    changelog = "https://github.com/libsigcplusplus/libsigcplusplus/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.gnome ];
  };
})
