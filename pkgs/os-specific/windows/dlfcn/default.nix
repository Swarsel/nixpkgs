{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "dlfcn";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "dlfcn-win32";
    repo = "dlfcn-win32";
    tag = "v${version}";
    hash = "sha256-kLY8vvHTT02gENPlVvyDyR0ULC8NA+E/P6mWtU6MbBY=";
  };

  nativeBuildInputs = [ cmake ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Set of functions that allows runtime dynamic library loading";
    homepage = "https://github.com/dlfcn-win32/dlfcn-win32";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marius851000 ];
    platforms = lib.platforms.windows;
  };
}
