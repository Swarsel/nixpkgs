{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zug";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = "zug";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0HrvCpbVnxEvwvG4btXu0hRzdcHsGwM/HUWES/fmxrs=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    catch2
  ];

  cmakeFlags = [ "-Dzug_BUILD_EXAMPLES=OFF" ];

  preConfigure = ''
    rm BUILD
  '';

  doCheck = true;

  meta = {
    description = "Library for functional interactive c++ programs";
    homepage = "https://github.com/arximboldi/zug";
    license = lib.licenses.boost;
    maintainers = [ ];
  };
})
