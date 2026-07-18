{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  clang,
  go,
  qt5,
  qt6,
  runCommand,
  udevCheckHook,
}:

let
  # Qt 6 doesn’t provide the rcc binary so we create an ad hoc package pulling
  # it from Qt 5.
  rcc = runCommand "rcc" { } ''
    mkdir -p $out/bin
    cp ${lib.getExe' qt5.qtbase.dev "rcc"} $out/bin
  '';
in
stdenv.mkDerivation rec {
  pname = "bitbox";
  version = "4.51.3";

  src = fetchFromGitHub {
    owner = "BitBoxSwiss";
    repo = "bitbox-wallet-app";
    tag = "v${version}";
    hash = "sha256-JdUoV4bp+pI8neyxHte1z7CULBwdNdLG/CaZFPmvDeg=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace frontends/qt/resources/linux/usr/share/applications/bitbox.desktop \
        --replace-fail 'Exec=BitBox %u' 'Exec=bitbox %u'
  '';

  nativeBuildInputs = [
    clang
    go
    qt6.wrapQtAppsHook
    rcc
    udevCheckHook
  ];

  buildInputs = [ qt6.qtwebengine ];

  buildPhase = ''
    runHook preBuild

    ln -s ${passthru.web} frontends/web/build
    export GOCACHE=$TMPDIR/go-cache
    cd frontends/qt
    make -C server linux
    ./genassets.sh
    qmake -o build/Makefile
    cd build
    make
    cd ../../..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r frontends/qt/resources/linux/usr/share $out
    mkdir $out/{bin,lib}
    cp frontends/qt/build/BitBox $out/bin/bitbox
    cp frontends/qt/build/assets.rcc $out/bin
    cp frontends/qt/server/libserver.so $out/lib
    install -m 644 -Dt $out/lib/udev/rules.d ${./rules.d}/*

    runHook postInstall
  '';

  doInstallCheck = true;
  dontConfigure = true;

  passthru.web = buildNpmPackage {
    inherit version;
    inherit src;
    pname = "bitbox-web";
    npmDepsHash = "sha256-kIYyUeaTgj4dJXfAJ1+3WDIYSADFcs5ypRGTODlxwDI=";
    installPhase = "cp -r build $out";
    sourceRoot = "${src.name}/frontends/web";
  };

  meta = {
    description = "Companion app for the BitBox02 hardware wallet";
    homepage = "https://bitbox.swiss/app/";

    changelog = "https://github.com/BitBoxSwiss/bitbox-wallet-app/blob/master/CHANGELOG.md#${
      builtins.replaceStrings [ "." ] [ "" ] version
    }";

    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.tensor5 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "bitbox";
    downloadPage = "https://github.com/BitBoxSwiss/bitbox-wallet-app";
  };
}
