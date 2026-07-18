{
  lib,
  fetchurl,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  libnotify,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "bleachbit";
  version = "6.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/bleachbit/bleachbit-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-ixQQirPj2zPEt6wBtFGlok60BsQlHJy8yp1QMonWX/c=";
  };

  # Patch the many hardcoded uses of /usr/share/ and /usr/bin
  postPatch = ''
    find -type f -exec sed -i -e 's@/usr/share@${placeholder "out"}/share@g' {} \;
    find -type f -exec sed -i -e 's@/usr/bin@${placeholder "out"}/bin@g' {} \;
    find -type f -exec sed -i -e 's@${placeholder "out"}/bin/python3@${python3Packages.python}/bin/python3@' {} \;
  '';

  strictDeps = false;

  nativeBuildInputs = [
    gettext
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libnotify
  ];

  propagatedBuildInputs = with python3Packages; [
    chardet
    pygobject3
    requests
  ];

  dontBuild = true;
  # Prevent double wrapping from wrapGApps and wrapPythonProgram
  dontWrapGApps = true;

  installFlags = [
    "prefix=${placeholder "out"}"
  ];

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
  ];

  pyproject = false;

  meta = {
    description = "Program to clean your computer";
    longDescription = "BleachBit helps you easily clean your computer to free space and maintain privacy.";
    homepage = "https://bleachbit.sourceforge.net";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      leonardoce
      mbprtpmnr
    ];

    mainProgram = "bleachbit";
  };
})
