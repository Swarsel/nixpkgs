{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "soplex";
  version = "716";

  src = fetchFromGitHub {
    owner = "scipopt";
    repo = "soplex";
    rev = "release-${builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version}";
    hash = "sha256-v2lDtnY3O1nP8RYALqpeO8q4b3bUAKZe4b3QhtnGiGg=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ];
  doCheck = true;

  meta = {
    description = "Sequential object-oriented simPlex";
    homepage = "https://scipopt.org";
    license = with lib.licenses; [ asl20 ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "soplex";
  };
})
