{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  libserialport,
  nix-update-script,
  pkg-config,
  sdl3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "m8c";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "laamaa";
    repo = "m8c";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cr5tat7JOFJ7y7AEinphgV/5T138gV6jidb87GooZ8U=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    sdl3
    libserialport
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];
  installFlags = [ "PREFIX=$(out)" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform M8 tracker headless client";
    homepage = "https://github.com/laamaa/m8c";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrtnvgr ];
    platforms = lib.platforms.all;
    mainProgram = "m8c";
  };
})
