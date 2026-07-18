{
  lib,
  fetchFromGitHub,
  gnome-menus,
  gobject-introspection,
  gtk3,
  intltool,
  menulibre,
  nix-update-script,
  python3Packages,
  testers,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "menulibre";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "bluesabre";
    repo = "menulibre";
    tag = "menulibre-${finalAttrs.version}";
    hash = "sha256-IfsuOYP/H3r1GDWMVVSBfYvQS+01VJaAlZu+c05geWg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'data_dir =' "data_dir = '$out/share/menulibre' #" \
      --replace-fail 'update_desktop_file(desktop_file, script_path)' ""
  '';

  nativeBuildInputs = [
    gtk3
    intltool
    gobject-introspection
    wrapGAppsHook3
    writableTmpDirAsHomeHook
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    gnome-menus
    psutil
    distutils-extra
  ];

  pyproject = true;

  passthru = {
    tests.version = testers.testVersion {
      command = "HOME=$TMPDIR menulibre --version | cut -d' ' -f2";
      package = menulibre;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Advanced menu editor with an easy-to-use interface";
    homepage = "https://bluesabre.org/projects/menulibre";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ lelgenio ];
    platforms = lib.platforms.linux;
    mainProgram = "menulibre";
  };
})
