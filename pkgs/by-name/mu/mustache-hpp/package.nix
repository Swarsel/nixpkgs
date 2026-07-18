{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mustache";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "kainjow";
    repo = "Mustache";
    rev = "v${finalAttrs.version}";
    sha256 = "0r9rbk6v1wpld2ismfsk2lkhbyv3dkf0p03hkjivbj05qkfhvlbb";
  };

  installPhase = ''
    mkdir -p $out/include
    cp mustache.hpp $out/include
  '';

  dontBuild = true;

  meta = {
    description = "Mustache text templates for modern C++";
    homepage = "https://github.com/kainjow/Mustache";
    license = lib.licenses.boost;
  };
})
