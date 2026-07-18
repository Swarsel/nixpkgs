{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  glib,
  gobject-introspection,
  gtk4,
  makeDesktopItem,
  networkmanager,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nmgui";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "s-adi-dev";
    repo = "nmgui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HS/n40Ng8S5N14DtEH/upwlxdzwCoOEJA40EMdCcLw4=io";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
    copyDesktopItems
  ];

  buildInputs = [
    gtk4
    glib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/applications,opt/nmgui}
    # Copy the app files
    cp -r app $out/opt/nmgui/

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${python3Packages.python.interpreter} $out/bin/nmgui \
      --add-flags "$out/opt/nmgui/app/main.py" \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      "''${gappsWrapperArgs[@]}"
  '';

  dependencies = with python3Packages; [
    pygobject3
    nmcli
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "GTK"
      ];

      comment = "GTK4-based Network Manager GUI using nmcli";
      desktopName = "NM GUI";
      exec = "nmgui";
      icon = "network-wireless-symbolic";
      name = "nmgui";
      startupNotify = true;
    })
  ];

  pyproject = false;

  meta = {
    inherit (networkmanager.meta) platforms;
    description = "Python library for interacting with NetworkManager CLI";
    homepage = "https://github.com/s-adi-dev/nmgui";
    changelog = "https://github.com/s-adi-dev/nmgui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ktechmidas ];
    mainProgram = "nmgui";
  };
})
