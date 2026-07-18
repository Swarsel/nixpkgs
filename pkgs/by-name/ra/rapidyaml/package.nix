{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rapidyaml";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "biojppm";
    repo = "rapidyaml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NjpEpjBFB2Ydfo81VzOYoMPqMdJbIYcQWBRcxCbJlY4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    git
  ];

  meta = {
    description = "Library to parse and emit YAML, and do it fast";
    homepage = "https://github.com/biojppm/rapidyaml";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
