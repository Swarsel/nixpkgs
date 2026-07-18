{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk4-layer-shell,
  libadwaita,
  nix-update-script,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonPackage rec {
  pname = "niriswitcher";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "isaksamsten";
    repo = "niriswitcher";
    tag = version;
    hash = "sha256-qsw2D9Q9ZJYBsRECzT+qoytYMda4uZxX321/YxNWk9o=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = [
    gtk4-layer-shell
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gtk4-layer-shell ]}
    )
  '';

  build-system = [ python3Packages.hatchling ];
  dependencies = [ python3Packages.pygobject3 ];
  dontWrapGApps = true;
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Application switcher for niri";
    homepage = "https://github.com/isaksamsten/niriswitcher";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bokicoder ];
    platforms = lib.platforms.linux;
    mainProgram = "niriswitcher";
  };
}
