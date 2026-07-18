{
  lib,
  fetchFromGitHub,
  cliphist,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  nix-update-script,
  python3Packages,
  wl-clipboard,
  wrapGAppsHook3,
}:

python3Packages.buildPythonPackage rec {
  pname = "nwg-clipman";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-clipman";
    tag = "v${version}";
    hash = "sha256-GVA842yCSSO2vDD51AObEQNhDVuRIdH1c6BF1tv2Q8E=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk-layer-shell
    gtk3
  ];

  nativeCheckInputs = [
    wl-clipboard
    cliphist
  ];

  postInstall = ''
    install -Dm644 nwg-clipman.desktop -t $out/share/applications/
    install -Dm644 nwg-clipman.svg -t $out/share/icons/hicolor/scalable/apps/
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = [ python3Packages.setuptools ];
  dependencies = with python3Packages; [ pygobject3 ];
  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "nwg_clipman" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK3-based GUI for cliphist";
    homepage = "https://github.com/nwg-piotr/nwg-clipman";
    changelog = "https://github.com/nwg-piotr/nwg-clipman/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ averyanalex ];
    platforms = lib.platforms.linux;
    mainProgram = "nwg-clipman";
  };
}
