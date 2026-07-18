{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git2-cpp";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "ken-matsui";
    repo = "git2-cpp";
    rev = finalAttrs.version;
    hash = "sha256-2jKSQW6dUCIKtl33paSTuZdYAaYdFnILx/Gxv/ghFiI=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "libgit2 bindings for C++";
    homepage = "https://github.com/ken-matsui/git2-cpp";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
# TODO [ ken-matsui ]: tests
