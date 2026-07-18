{
  meek,
  obfs4,
  onionshare,
  python3Packages,
  qt5,
  replaceVars,
  snowflake,
  tor,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  inherit (onionshare)
    src
    version
    build-system
    pythonRelaxDeps
    ;

  pname = "onionshare";

  patches = [
    # hardcode store paths of dependencies
    (replaceVars ./fix-paths-gui.patch {
      inherit
        meek
        obfs4
        snowflake
        tor
        ;

      inherit (tor) geoip;
    })
  ];

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];
  buildInputs = [ qt5.qtwayland ];
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/{appdata,applications,icons}
    cp $src/desktop/org.onionshare.OnionShare.desktop $out/share/applications
    cp $src/desktop/org.onionshare.OnionShare.svg $out/share/icons
    cp $src/desktop/org.onionshare.OnionShare.appdata.xml $out/share/appdata
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    onionshare
    pyside6
    python-gnupg
    qrcode
  ];

  dontWrapQtApps = true;
  pyproject = true;
  pythonImportsCheck = [ "onionshare" ];
  sourceRoot = "${finalAttrs.src.name}/desktop";

  meta = onionshare.meta // {
    mainProgram = "onionshare";
  };
})
