{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "cxxtest";
  version = "4.4";

  src = fetchFromGitHub {
    owner = "CxxTest";
    repo = "cxxtest";
    rev = version;
    sha256 = "19w92kipfhp5wvs47l0qpibn3x49sbmvkk91yxw6nwk6fafcdl17";
  };

  nativeCheckInputs = [ python3Packages.ply ];

  preCheck = ''
    cd ../
  '';

  postCheck = ''
    cd python3
    python scripts/cxxtestgen --error-printer -o build/GoodSuite.cpp ../../test/GoodSuite.h
    $CXX -I../../ -o build/GoodSuite build/GoodSuite.cpp
    build/GoodSuite
  '';

  preInstall = ''
    cd python3
  '';

  postInstall = ''
    mkdir -p "$out/include"
    cp -r ../../cxxtest "$out/include"
  '';

  format = "setuptools";
  sourceRoot = "${src.name}/python";

  meta = {
    description = "Unit testing framework for C++";
    homepage = "https://github.com/CxxTest/cxxtest";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ juliendehos ];
    platforms = lib.platforms.unix;
    mainProgram = "cxxtestgen";
  };
}
