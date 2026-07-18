{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glib,
  jansson,
  pkg-config,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "libsearpc";
  version = "3.3-20241031";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = "libsearpc";
    rev = commit;
    sha256 = "sha256-Ze1dOEFUIA16OlqkyDjQw6c6JcDECjYsdCm5um0kG/c=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    python3
  ];

  propagatedBuildInputs = [
    glib
    jansson
  ];

  commit = "d00c062d76d86b76c8c179bfb4babc9e2200b3f1";

  meta = {
    description = "Simple and easy-to-use C language RPC framework based on GObject System";
    homepage = "https://github.com/haiwen/libsearpc";
    license = lib.licenses.lgpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "searpc-codegen.py";
  };
}
