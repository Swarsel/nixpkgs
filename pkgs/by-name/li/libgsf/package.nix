{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bzip2,
  gdk-pixbuf,
  gettext,
  glib,
  gnome,
  gtk-doc,
  intltool,
  libiconv,
  libintl,
  libxml2,
  perl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgsf";
  version = "1.14.58";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "libgsf";
    tag = "LIBGSF_${lib.replaceString "." "_" finalAttrs.version}";
    hash = "sha256-0QQas3AsH46OOCSuezoBSeIQSilaenl50stpNwNJsKc=";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # Fix cross-compilation
    substituteInPlace configure.ac \
      --replace "AC_PATH_PROG(PKG_CONFIG, pkg-config, no)" \
                "PKG_PROG_PKG_CONFIG"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    pkg-config
    intltool
    libintl
  ];

  buildInputs = [
    gettext
    bzip2
    zlib
  ];

  propagatedBuildInputs = [
    libxml2
    glib
    gdk-pixbuf
    libiconv
  ];

  # checking pkg-config is at least version 0.9.0... ./configure: line 15213: no: command not found
  # configure: error: in `/build/libgsf-1.14.50':
  # configure: error: The pkg-config script could not be found or is too old.  Make sure it
  # is in your PATH or set the PKG_CONFIG environment variable to the full
  preConfigure = ''
    export PKG_CONFIG="$(command -v "$PKG_CONFIG")"
  '';

  doCheck = true;

  nativeCheckInputs = [
    perl
  ];

  preCheck = ''
    patchShebangs ./tests/
  '';

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/gsf-office.thumbnailer \
      --replace-fail "TryExec=gsf-office-thumbnailer" "TryExec=$out/bin/gsf-office-thumbnailer" \
      --replace-fail "Exec=gsf-office-thumbnailer" "Exec=$out/bin/gsf-office-thumbnailer"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = finalAttrs.pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "GNOME's Structured File Library";

    longDescription = ''
      Libgsf aims to provide an efficient extensible I/O abstraction for
      dealing with different structured file formats.
    '';

    homepage = "https://gitlab.gnome.org/GNOME/libgsf";
    changelog = "https://gitlab.gnome.org/GNOME/libgsf/-/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.lgpl21Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
