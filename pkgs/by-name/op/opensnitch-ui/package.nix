{
  lib,
  opensnitch,
  python3Packages,
  qt6,
}:

python3Packages.buildPythonApplication {
  inherit (opensnitch) src version;
  pname = "opensnitch-ui";

  postPatch = ''
    substituteInPlace opensnitch/utils/__init__.py \
      --replace-fail /usr/lib/python3/dist-packages/data ${python3Packages.pyasn}/${python3Packages.python.sitePackages}/pyasn/data
  '';

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtwayland
  ];

  preBuild = ''
    make -C ../proto ../ui/opensnitch/ui_pb2.py
    # sourced from ui/Makefile
    sed -i 's/^import ui_pb2/from . import ui_pb2/' opensnitch/proto/ui_pb2*
  '';

  # All tests are sandbox-incompatible and disabled for now
  doCheck = false;

  preCheck = ''
    export PYTHONPATH=opensnitch:$PYTHONPATH
  '';

  postInstall = ''
    mv $out/${python3Packages.python.sitePackages}/usr/* $out/
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    grpcio-tools
    notify2
    packaging
    pyasn
    pyinotify
    pyqt6
    qt-material
    python-slugify
    unidecode
  ];

  dontWrapQtApps = true;
  makeWrapperArgs = [ "\${qtWrapperArgs[@]}" ];
  pyproject = true;
  pythonImportsCheck = [ "opensnitch" ];
  sourceRoot = "${opensnitch.src.name}/ui";

  meta = {
    description = "Application firewall";
    homepage = "https://github.com/evilsocket/opensnitch/wiki";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      onny
      grimmauld
    ];

    platforms = lib.platforms.linux;
    mainProgram = "opensnitch-ui";
  };
}
