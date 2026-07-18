{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libplist,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libimobiledevice-glue";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libimobiledevice-glue";
    rev = finalAttrs.version;
    hash = "sha256-cUcJARbZV9Yaqd9TP3NVmF9p8Pjz88a3GmAh4c4sEHo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  propagatedBuildInputs = [
    libplist
  ];

  preAutoreconf = ''
    export RELEASE_VERSION=${finalAttrs.version}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library with common code used by the libraries and tools around the libimobiledevice project";
    homepage = "https://github.com/libimobiledevice/libimobiledevice-glue";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
