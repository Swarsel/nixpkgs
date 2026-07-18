{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
  testers,
  validatePkgConfig,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qtwebapp";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "fffaraz";
    repo = "QtWebApp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RbFgz2ed1eEVy44LX+milP4hPSeiabakU3TMvHYR7TU=";
  };

  postPatch = ''
    cat >>QtWebApp.pro <<EOF
    unix {
      target.path += $out/lib
      INSTALLS += target
    }
    EOF
  '';

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    validatePkgConfig
  ];

  propagatedBuildInputs = [
    # For libs in the pkg-config, they must be
    # propagated so that packages that depend on
    # it can properly use it.
    qt6.qtbase
    qt6.qt5compat
  ];

  postInstall = ''
    mkdir -p "$out/lib/pkgconfig"
    cp "$pkgConfigFile" "$out/lib/pkgconfig/QtWebApp.pc"
    substituteInPlace "$out/lib/pkgconfig/QtWebApp.pc" \
      --subst-var out \
      --subst-var version

    mkdir -p "$out/include/QtWebApp/httpserver"
    cp httpserver/*.h "$out/include/QtWebApp/httpserver"

    mkdir -p "$out/include/QtWebApp/logging"
    cp logging/*.h "$out/include/QtWebApp/logging"

    mkdir -p "$out/include/QtWebApp/templateengine"
    cp templateengine/*.h "$out/include/QtWebApp/templateengine"
  '';

  __structuredAttrs = true;
  pkgConfigFile = ./pkg-config.in;
  qmakeFlags = [ "QtWebApp.pro" ];
  sourceRoot = "${finalAttrs.src.name}/QtWebApp";
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "HTTP server library in C++, inspired by Java Servlets";
    homepage = "https://stefanfrings.de/qtwebapp/index-en.html";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ xddxdd ];

    pkgConfigModules = [
      "QtWebApp"
    ];
  };
})
