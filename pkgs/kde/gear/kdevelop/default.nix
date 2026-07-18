{
  lib,
  apr,
  aprutil,
  boost,
  kdevelop-pg-qt,
  libastyle,
  libclang,
  libllvm,
  mkKdeDerivation,
  pkg-config,
  qttools,
  qtwebengine,
  shared-mime-info,
  subversion,
}:
mkKdeDerivation {
  pname = "kdevelop";

  extraBuildInputs = [
    qttools
    apr
    aprutil
    boost
    libastyle
    libclang
    libllvm
    subversion
  ];

  extraCmakeFlags = [
    "-DCLANG_BUILTIN_DIR=${lib.getLib libclang}/lib/clang/${lib.versions.major libclang.version}/include"
    "-DAPR_CONFIG_PATH=${apr.dev}/bin"
    "-DAPU_CONFIG_PATH=${aprutil.dev}/bin"
  ];

  extraNativeBuildInputs = [
    kdevelop-pg-qt
    pkg-config
    shared-mime-info
  ];

  extraPropagatedBuildInputs = [
    qtwebengine
  ];
}
