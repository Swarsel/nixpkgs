{
  lib,
  fetchFromGitHub,
  asciidoc,
  gobject-introspection,
  gtk3,
  installShellFiles,
  libappindicator-gtk3,
  libnotify,
  librsvg,
  python3Packages,
  testers,
  udiskie,
  udisks,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "udiskie";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "coldfix";
    repo = "udiskie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8+Fo3rECMPq7FdmZgrnE0/dz15fuLjd7EDVwLZwfgn0=";
  };

  patches = [
    ./locale-path.patch
  ];

  postPatch = ''
    substituteInPlace udiskie/locale.py --subst-var out
  '';

  nativeBuildInputs = [
    asciidoc # Man page
    gobject-introspection
    installShellFiles
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    libnotify
    librsvg # SVG icons
    udisks
  ];

  postBuild = ''
    make -C doc
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  postInstall = ''
    installManPage doc/udiskie.8

    installShellCompletion \
      --bash completions/bash/* \
      --zsh completions/zsh/*
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    docopt
    keyutils
    pygobject3
    pyyaml
  ];

  dontWrapGApps = true;
  pyproject = true;

  passthru.tests.version = testers.testVersion {
    package = udiskie;
  };

  meta = {
    description = "Removable disk automounter for udisks";

    longDescription = ''
      udiskie is a udisks2 front-end that allows to manage removeable media such
      as CDs or flash drives from userspace.

      Its features include:
      - automount removable media
      - notifications
      - tray icon
      - command line tools for manual un-/mounting
      - LUKS encrypted devices
      - unlocking with keyfiles (requires udisks 2.6.4)
      - loop devices (mounting iso archives)
      - password caching (requires python keyutils 0.3)
    '';

    homepage = "https://github.com/coldfix/udiskie";
    changelog = "https://github.com/coldfix/udiskie/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "udiskie";
  };
})
