{
  lib,
  buildPythonPackage,
  callPackage,
  certifi,
  distro,
  isPy3k,
  isPyPy,
  pkgs,
  psutil,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  inherit (callPackage ./src.nix { }) version src;
  pname = "openpaperwork-core";

  nativeBuildInputs = [
    pkgs.gettext
    pkgs.which
    setuptools-scm
  ];

  propagatedBuildInputs = [
    distro
    setuptools
    psutil
    certifi
  ];

  preBuild = ''
    make l10n_compile
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  # Python 2.x is not supported.
  disabled = !isPy3k && !isPyPy;

  patchPhase = ''
    chmod a+w -R ..
    patchShebangs ../tools
  '';

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/openpaperwork-core";

  meta = {
    description = "Backend part of Paperwork (Python API, no UI)";
    homepage = "https://openpaper.work/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aszlig
      symphorien
    ];

    platforms = lib.platforms.linux;
  };
})
