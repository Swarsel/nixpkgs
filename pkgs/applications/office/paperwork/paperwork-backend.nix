{
  lib,
  buildPythonPackage,
  callPackage,
  distro,
  gettext,
  gtk3,
  libinsane,
  libreoffice,
  natsort,
  openpaperwork-core,
  openpaperwork-gtk,
  poppler_gi,
  psutil,
  pycountry,
  pyenchant,
  pygobject3,
  pyocr,
  pypillowfight,
  scikit-learn,
  setuptools-scm,
  shared-mime-info,
  termcolor,
  unittestCheckHook,
  which,
  whoosh,
}:

buildPythonPackage (finalAttrs: {
  inherit (callPackage ./src.nix { }) version src;
  pname = "paperwork-backend";

  patches = [
    # disables a flaky test https://gitlab.gnome.org/World/OpenPaperwork/paperwork/-/issues/1035#note_1493700
    ./flaky_test.patch
  ];

  postPatch = ''
    chmod a+w -R ..
    patchShebangs ../tools
  '';

  nativeBuildInputs = [
    gettext
    shared-mime-info
    which
    setuptools-scm
  ];

  propagatedBuildInputs = [
    distro
    gtk3
    libinsane
    natsort
    openpaperwork-core
    pyenchant
    pycountry
    pygobject3
    pyocr
    pypillowfight
    poppler_gi
    scikit-learn
    termcolor
    whoosh
  ];

  preBuild = ''
    make l10n_compile
  '';

  nativeCheckInputs = [
    libreoffice
    openpaperwork-gtk
    psutil
    unittestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  patchFlags = [ "-p2" ];
  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/paperwork-backend";

  meta = {
    description = "Backend part of Paperwork (Python API, no UI)";
    homepage = "https://openpaper.work";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aszlig
      symphorien
    ];
  };
})
