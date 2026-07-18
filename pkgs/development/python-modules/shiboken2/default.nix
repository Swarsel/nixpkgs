{
  lib,
  stdenv,
  cmake,
  llvmPackages,
  pyside2,
  python,
  qt5,
}:

stdenv.mkDerivation {
  inherit (pyside2) version src patches;
  pname = "shiboken2";

  postPatch = ''
    cd sources/shiboken2
    substituteInPlace doc/CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 3.1)" \
      "cmake_minimum_required(VERSION 3.10)"
    for i in {.,ApiExtractor}/CMakeLists.txt; do
      substituteInPlace $i --replace-fail \
        "cmake_minimum_required(VERSION 3.1)" \
        "cmake_minimum_required(VERSION 3.10)"
      substituteInPlace $i --replace-fail \
        "cmake_policy(VERSION 3.1)" \
        "cmake_policy(VERSION 3.10)"
    done
    head CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    (python.withPackages (
      ps: with ps; [
        distutils
        setuptools
      ]
    ))
    qt5.qmake
  ];

  buildInputs = [
    llvmPackages.libclang
    python.pkgs.setuptools
    qt5.qtbase
    qt5.qtxmlpatterns
  ];

  cmakeFlags = [ "-DBUILD_TESTS=OFF" ];
  env.CLANG_INSTALL_DIR = llvmPackages.libclang.out;

  postInstall = ''
    cd ../../..
    ${python.pythonOnBuildForHost.interpreter} setup.py egg_info --build-type=shiboken2
    cp -r shiboken2.egg-info $out/${python.sitePackages}/
    rm $out/bin/shiboken_tool.py
  '';

  dontWrapQtApps = true;

  meta = {
    description = "Generator for the PySide2 Qt bindings";
    homepage = "https://wiki.qt.io/Qt_for_Python";

    license = with lib.licenses; [
      gpl2
      lgpl21
    ];

    maintainers = [ ];
    mainProgram = "shiboken2";
    broken = python.pythonAtLeast "3.13";
  };
}
