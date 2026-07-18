{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  doxygen,
  gbenchmark,
  graphviz,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ftxui";
  version = "6.1.9";

  src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "ftxui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-plJxTLhOhUyuay5uYv4KLK9UTmM2vsoda+iDXVa4b+k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
  ];

  cmakeFlags = [
    (lib.cmakeBool "FTXUI_BUILD_EXAMPLES" false)
    (lib.cmakeBool "FTXUI_BUILD_DOCS" true)
    (lib.cmakeBool "FTXUI_BUILD_TESTS" finalAttrs.doCheck)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkInputs = [
    gtest
    gbenchmark
  ];

  meta = {
    description = "Functional Terminal User Interface library for C++";
    homepage = "https://github.com/ArthurSonzogni/FTXUI";
    changelog = "https://github.com/ArthurSonzogni/FTXUI/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.all;
  };
})
