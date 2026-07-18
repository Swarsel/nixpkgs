{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "verdict";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "sandialabs";
    repo = "verdict";
    tag = finalAttrs.version;
    hash = "sha256-8RUFag3XsWsrvVXsz/+ARTHfmGAJ6giQApn+XDwslMQ=";
  };

  nativeBuildInputs = [
    cmake
  ];

  doCheck = true;

  nativeCheckInputs = [
    gtest
  ];

  meta = {
    description = "Compute functions of 2- and 3-dimensional regions";
    homepage = "https://github.com/sandialabs/verdict";
    changelog = "https://github.com/sandialabs/verdict/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
})
