{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  python3Packages,
  wlr-randr,
  wrapGAppsHook3,
}:

python3Packages.buildPythonPackage rec {
  pname = "nwg-wrapper";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-wrapper";
    tag = "v${version}";
    sha256 = "sha256-GKDAdjO67aedCEFHKDukQ+oPMomTPwFE/CvJu112fus=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtk-layer-shell
  ];

  # No tests
  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : "${lib.makeBinPath [ wlr-randr ]}"
    )
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    i3ipc
    pygobject3
  ];

  pyproject = true;
  pythonImportsCheck = [ "nwg_wrapper" ];

  meta = {
    description = "Wrapper to display a script output or a text file content on the desktop in sway or other wlroots-based compositors";
    homepage = "https://github.com/nwg-piotr/nwg-wrapper/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artturin ];
    mainProgram = "nwg-wrapper";
  };
}
