{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clib";
  version = "2.8.7";

  src = fetchFromGitHub {
    owner = "clibs";
    repo = "clib";
    rev = finalAttrs.version;
    sha256 = "sha256-uL8prMk2DrYLjCmZW8DdbCg5FJ5uksT3vIATyOW2ZzY=";
  };

  buildInputs = [ curl ];
  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "C micro-package manager";
    homepage = "https://github.com/clibs/clib";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jb55 ];
    platforms = lib.platforms.all;
  };
})
