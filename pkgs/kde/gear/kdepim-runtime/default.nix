{
  lib,
  cyrus_sasl,
  libetebase,
  libkgapi,
  libxslt,
  mkKdeDerivation,
  pkg-config,
  qtnetworkauth,
  qtspeech,
  qtwebengine,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kdepim-runtime";

  # FIXME: libkolabxml
  extraBuildInputs = [
    qtnetworkauth
    qtspeech
    qtwebengine
    cyrus_sasl
    libetebase
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
    libxslt
  ];

  qtWrapperArgs = [
    "--prefix SASL_PATH : ${
      lib.makeSearchPath "lib/sasl2" [
        cyrus_sasl.out
        libkgapi
      ]
    }"
  ];
}
