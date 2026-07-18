{
  lib,
  gobject-introspection,
  gtk3,
  nmap,
  python3Packages,
  wrapGAppsHook3,
  xterm,
}:

python3Packages.buildPythonApplication {
  pname = "zenmap";
  version = nmap.version;
  src = nmap.src;

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    nmap
    gtk3
    xterm
  ];

  nativeCheckInputs = [
    nmap
  ];

  checkPhase = ''
    runHook preCheck

    cd test
    ${python3Packages.python.interpreter} run_tests.py 2>&1 | tee /dev/stderr | tail -n1 | grep '^OK$'

    runHook postCheck
  '';

  postInstall = ''
    # Icons
    install -Dm 644 "zenmapCore/data/pixmaps/zenmap.png" -t "$out/share/icons/hicolor/256x256/apps"
    # Desktop-files for application
    install -Dm 644 "install_scripts/unix/zenmap.desktop" -t "$out/share/applications/"
    install -Dm 644 "install_scripts/unix/zenmap-root.desktop" -t "$out/share/applications/"
    install -Dm 755 "install_scripts/unix/su-to-zenmap.sh" -t "$out/bin/"
    substituteInPlace "$out/bin/su-to-zenmap.sh" \
        --replace-fail 'COMMAND="zenmap"' \
                      'COMMAND="'"$out/bin/zenmap"'"' \
        --replace-fail 'xterm' \
                      '"${xterm}/bin/xterm"'
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ nmap ]})
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-gettext
  ];

  dependencies = with python3Packages; [
    pygobject3
  ];

  dontWrapGApps = true;

  prePatch = ''
    cd zenmap
  '';

  pyproject = true;

  meta = nmap.meta // {
    description = "Offical nmap Security Scanner GUI";
    homepage = "https://nmap.org/zenmap/";

    maintainers = with lib.maintainers; [
      dvaerum
      mymindstorm
    ];
  };
}
