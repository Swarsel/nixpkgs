{
  lib,
  buildPythonPackage,
  callPackage,
  fabulous,
  getkey,
  isPy3k,
  isPyPy,
  openpaperwork-core,
  openpaperwork-gtk,
  paperwork-backend,
  pkgs,
  psutil,
  rich,
  setuptools-scm,
  shared-mime-info,
}:

buildPythonPackage (finalAttrs: {
  inherit (callPackage ./src.nix { }) version src;
  pname = "paperwork-shell";

  nativeBuildInputs = [
    pkgs.gettext
    pkgs.which
    setuptools-scm
  ];

  propagatedBuildInputs = [
    openpaperwork-core
    paperwork-backend
    fabulous
    getkey
    psutil
    rich
  ];

  preBuild = ''
    make l10n_compile
  '';

  nativeCheckInputs = [
    shared-mime-info
    openpaperwork-gtk
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    "$out/bin/paperwork-cli" chkdeps
  '';

  # Python 2.x is not supported.
  disabled = !isPy3k && !isPyPy;

  patchPhase = ''
    chmod a+w -R ..
    patchShebangs ../tools
  '';

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/paperwork-shell";

  meta = {
    description = "CLI for Paperwork";
    homepage = "https://openpaper.work/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aszlig
      symphorien
    ];
  };
})
