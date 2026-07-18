{
  lib,
  buildPythonPackage,
  callPackage,
  distro,
  isPy3k,
  isPyPy,
  openpaperwork-core,
  pillow,
  pkgs,
  pygobject3,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  inherit (callPackage ./src.nix { }) version src;
  pname = "openpaperwork-gtk";

  nativeBuildInputs = [
    pkgs.gettext
    pkgs.which
    setuptools-scm
  ];

  propagatedBuildInputs = [
    pillow
    pygobject3
    pkgs.poppler_gi
    pkgs.gtk3
    pkgs.libhandy
    distro
    pkgs.pango
    openpaperwork-core
  ];

  preBuild = ''
    make l10n_compile
  '';

  # Python 2.x is not supported.
  disabled = !isPy3k && !isPyPy;

  patchPhase = ''
    chmod a+w -R ..
    patchShebangs ../tools
  '';

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/openpaperwork-gtk";

  meta = {
    description = "Reusable GTK components of Paperwork";
    homepage = "https://openpaper.work/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aszlig
      symphorien
    ];

    platforms = lib.platforms.linux;
  };
})
