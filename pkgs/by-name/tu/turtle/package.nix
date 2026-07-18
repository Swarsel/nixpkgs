{
  lib,
  fetchFromGitLab,
  gobject-introspection,
  installShellFiles,
  libadwaita,
  meld,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "turtle";
  version = "0.14";

  src = fetchFromGitLab {
    owner = "philippun1";
    repo = "turtle";
    tag = finalAttrs.version;
    hash = "sha256-+XDDscw5xBUp39tbZLqZWK+wsRDi401mRDjx+VR6Cu0=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    substituteInPlace ./install.py \
      --replace-fail "/usr" "$out" \
      --replace-fail "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
    installShellFiles
  ];

  buildInputs = [ libadwaita ];

  postInstall = ''
    python ./install.py install
    installManPage data/man/*
  '';

  postFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      --prefix PATH : ${lib.makeBinPath [ meld ]}
    )
    wrapPythonPrograms
  ''
  # Dialogs are not imported, but executed. The same does
  # nautilus-python plugins. So we need to patch them as well.
  + ''
    for dialog_scripts in $out/lib/python*/site-packages/turtlevcs/dialogs/*.py; do
      patchPythonScript $dialog_scripts
    done
    for nautilus_extensions in $out/share/nautilus-python/extensions/*.py; do
      patchPythonScript $nautilus_extensions
    done
    substituteInPlace $out/share/nautilus-python/extensions/turtle_nautilus_compare.py \
      --replace-fail 'Popen(["meld"' 'Popen(["${lib.getExe meld}"'
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    pygit2
    secretstorage
    dbus-python
  ];

  # Avoid wrapping two times
  dontWrapGApps = true;
  # Make sure we patch other scripts after wrapper is generated
  # to get $program_PYTHONPATH
  dontWrapPythonPrograms = true;
  pyproject = true;

  meta = {
    description = "Graphical interface for version control intended to run on gnome and nautilus";
    homepage = "https://gitlab.gnome.org/philippun1/turtle";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "turtle_cli";
  };
})
