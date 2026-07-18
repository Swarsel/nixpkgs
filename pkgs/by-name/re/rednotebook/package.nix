{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  gtksourceview,
  pango,
  python3Packages,
  webkitgtk_4_1,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rednotebook";
  version = "2.42";

  src = fetchFromGitHub {
    owner = "jendrikseipp";
    repo = "rednotebook";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-4e3LvBVrhqzNja9kOZ5xJVYvwjGkKNvIuXou4YfD6w4=";
  };

  nativeBuildInputs = [ gobject-introspection ];

  propagatedBuildInputs = [
    gdk-pixbuf
    glib
    gtk3
    gtksourceview
    pango
    webkitgtk_4_1
  ]
  ++ (with python3Packages; [
    pygobject3
    pyyaml
  ]);

  # We have not packaged tests.
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  makeWrapperArgs = [
    "--set GI_TYPELIB_PATH $GI_TYPELIB_PATH"
    "--prefix XDG_DATA_DIRS : $out/share"
    "--suffix XDG_DATA_DIRS : $XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rednotebook" ];

  meta = {
    description = "Modern journal that includes a calendar navigation, customizable templates, export functionality and word clouds";
    homepage = "https://rednotebook.sourceforge.io/";
    changelog = "https://github.com/jendrikseipp/rednotebook/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "rednotebook";
  };
})
