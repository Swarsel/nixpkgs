{
  lib,
  fetchFromGitLab,
  fetchpatch,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  nix-update-script,
  python3Packages,
  wrapGAppsHook3,
  xrandr,
}:

let
  inherit (python3Packages)
    buildPythonApplication
    setuptools
    docutils
    pygobject3
    ;
in
buildPythonApplication (finalAttrs: {
  pname = "arandr";
  version = "0.1.11";

  src = fetchFromGitLab {
    owner = "arandr";
    repo = "arandr";
    tag = finalAttrs.version;
    hash = "sha256-nQtfOKAnWKsy2DmvtRGJa4+Y9uGgX41BeHpd9m4d9YA=";
  };

  patches = [
    # patch to set mtime=0 on setup.py
    ./gzip-timestamp-fix.patch

    # fixes build with setuptools 81+, while keeping it backwards compatible
    (fetchpatch {
      hash = "sha256-b9U8b4rdkN5lWDVpv50szaVS0rAZVSy7q6IXNVLvq3A=";
      name = "arandr-0.1.11-setuptools-81.patch";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/x11-misc/arandr/files/arandr-0.1.11-setuptools-81.patch";
    })
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gsettings-desktop-schemas
    gtk3
  ];

  propagatedBuildInputs = [
    xrandr
  ];

  preBuild = ''
    rm -rf data/po/*
  '';

  # no tests
  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = [ setuptools ];

  dependencies = [
    docutils
    pygobject3
  ];

  dontWrapGApps = true;
  pyproject = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex=(\\d.*)"
    ];
  };

  meta = {
    description = "Simple visual front end for XRandR";
    homepage = "https://christian.amsuess.com/tools/arandr/";
    changelog = "https://gitlab.com/arandr/arandr/-/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      gepbird
    ];

    mainProgram = "arandr";
  };
})
