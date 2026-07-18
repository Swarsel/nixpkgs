{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  distutils,
  python,
  sip4,
}:

buildPythonPackage rec {
  pname = "libsavitar";
  version = "4.12.0";

  src = fetchFromGitHub {
    owner = "Ultimaker";
    repo = "libSavitar";
    rev = version;
    hash = "sha256-MAA1WtGED6lvU6N4BE6wwY1aYaFrCq/gkmQFz3VWqNA=";
  };

  postPatch = ''
    sed -i 's#''${Python3_SITEARCH}#${placeholder "out"}/${python.sitePackages}#' cmake/SIPMacros.cmake

    substituteInPlace pugixml/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    sip4
  ];

  propagatedBuildInputs = [
    sip4
    distutils
  ];

  pyproject = false;

  meta = {
    description = "C++ implementation of 3mf loading with SIP python bindings";
    homepage = "https://github.com/Ultimaker/libSavitar";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
