{
  lib,
  fetchurl,
  copyDesktopItems,
  gettext,
  makeDesktopItem,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "timeline";
  version = "2.11.0";

  src = fetchurl {
    url = "mirror://sourceforge/thetimelineproj/timeline-${finalAttrs.version}.zip";
    sha256 = "sha256-XJ5Gu3nFLtSaEedzxBZERtPydIFMWWGi5frXWmgKxVA=";
  };

  nativeBuildInputs = [
    python3.pkgs.wrapPython
    copyDesktopItems
    wrapGAppsHook3
  ];

  doCheck = false;

  nativeCheckInputs = [
    gettext
    python3.pkgs.mock
  ];

  # tests fail because they need an x server
  # Unable to access the X Display, is $DISPLAY set properly?
  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} tools/execute-specs.py
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    site_packages=$out/${python3.pkgs.python.sitePackages}
    install -D -m755 source/timeline.py $out/bin/timeline
    mkdir -p $site_packages
    cp -r source/timelinelib $site_packages/

    mkdir -p $out/usr/share/timeline/locale
    cp -r icons $out/usr/share/timeline/
    cp -r translations/ $out/usr/share/timeline/

    mkdir -p $out/share/icons/hicolor/{48x48,32x32,16x16}/apps
    cp icons/48.png $out/share/icons/hicolor/48x48/apps/timeline.png
    cp icons/32.png $out/share/icons/hicolor/32x32/apps/timeline.png
    cp icons/16.png $out/share/icons/hicolor/16x16/apps/timeline.png

    runHook postInstall
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Office"
        "Calendar"
      ];

      comment = "Display and navigate information on a timeline";
      desktopName = "Timeline";
      exec = "timeline";
      icon = "timeline";
      name = "timeline";
    })
  ];

  dontBuild = true;
  dontWrapGApps = true;

  patchPhase = ''
    sed -i "s|_ROOT =.*|_ROOT = \"$out/usr/share/timeline/\"|" source/timelinelib/config/paths.py
  '';

  pyproject = false;

  pythonPath = with python3.pkgs; [
    wxpython
    humblewx
    icalendar
    markdown
  ];

  meta = {
    description = "Display and navigate information on a timeline";
    homepage = "https://thetimelineproj.sourceforge.net/";
    changelog = "https://thetimelineproj.sourceforge.net/changelog.html";

    license = with lib.licenses; [
      gpl3Only
      cc-by-sa-30
    ];

    maintainers = with lib.maintainers; [ davidak ];
    platforms = lib.platforms.unix;
    mainProgram = "timeline";
  };
})
