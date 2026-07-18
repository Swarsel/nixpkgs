{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  glib,
  libuuid,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "libkvmi";
  version = "1.1.0-unstable-2023-12-13";

  src = fetchFromGitHub {
    owner = "bitdefender";
    repo = "libkvmi";
    rev = "bc80de986bda1b891a1106badf87587bb92dbbb3";
    hash = "sha256-evYRIwguaKgJ8pMhhKKkSc/65GDYnG6DoYRMSkLjowI=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs = [
    glib
    libuuid
  ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = {
    description = "KVM virtual machine introspection library";
    homepage = "https://github.com/bitdefender/libkvmi";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ sigmasquadron ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "hookguest-libkvmi";
    outputsToInstall = [ "lib" ];
  };
}
