{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cppclean";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "myint";
    repo = "cppclean";
    rev = "v${finalAttrs.version}";
    sha256 = "081bw7kkl7mh3vwyrmdfrk3fgq8k5laacx7hz8fjpchrvdrkqph0";
  };

  checkPhase = ''
    ./test.bash
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  postUnpack = ''
    patchShebangs .
  '';

  pyproject = true;

  meta = {
    description = "Finds problems in C++ source that slow development of large code bases";
    homepage = "https://github.com/myint/cppclean";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nthorne ];
    platforms = lib.platforms.linux;
    mainProgram = "cppclean";
  };
})
