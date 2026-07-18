{
  lib,
  fetchFromGitHub,
  fetchpatch,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  gtksourceview4,
  itstool,
  libsecret,
  meson,
  ninja,
  pango,
  python3Packages,
  wrapGAppsHook3,
  xvfb-run,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gtg";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "getting-things-gnome";
    repo = "gtg";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Qojw9mJlPU234ijsCN92Gu/j2CyMVDvFFwzbYSYvMdU=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-i3F638ZGiKfSxVUZm6rzzPRpcIHLOO9dgV0SzNLSroI=";
      name = "replace-imp-with-importlib.patch";
      url = "https://github.com/getting-things-gnome/gtg/commit/568a00a3296d12cf3b2846c59bc99d13ecba7d47.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    itstool
    gettext
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3
    gtksourceview4
    pango
    gdk-pixbuf
    libsecret
  ];

  propagatedBuildInputs = with python3Packages; [
    pycairo
    pygobject3
    lxml
    gst-python
    liblarch
    caldav
    vobject
  ];

  preBuild = ''
    export HOME="$TMP"
  '';

  nativeCheckInputs = with python3Packages; [
    mock
    xvfb-run
    pytest
  ];

  checkPhase = "xvfb-run pytest ../tests/";
  pyproject = false;

  meta = {
    description = "Personal tasks and TODO-list items organizer";

    longDescription = ''
      "Getting Things GNOME" (GTG) is a personal tasks and ToDo list organizer inspired by the "Getting Things Done" (GTD) methodology.
      GTG is intended to help you track everything you need to do and need to know, from small tasks to large projects.
    '';

    homepage = "https://github.com/getting-things-gnome/gtg";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ oyren ];
    platforms = lib.platforms.linux;
    mainProgram = "gtg";
    downloadPage = "https://github.com/getting-things-gnome/gtg/releases";
  };
})
