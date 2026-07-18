{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libGL,
  libGLU,
  libglut,
  libx11,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "antiprism";
  version = "0.32";

  src = fetchFromGitHub {
    owner = "antiprism";
    repo = "antiprism";
    tag = finalAttrs.version;
    hash = "sha256-0FkaIsZixYHP45H0gytnzlpRvNd8mMYjW22w15z3RH8=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    libx11
    libGLU
    libGL
    libglut
  ];

  meta = {
    description = "Collection of programs for generating, manipulating, transforming and viewing polyhedra";
    homepage = "https://www.antiprism.com";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
  };
})
