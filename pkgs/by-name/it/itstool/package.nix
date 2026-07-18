{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  python3,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "itstool";
  version = "2.0.7";

  src = fetchurl {
    url = "https://files.itstool.org/itstool/itstool-${finalAttrs.version}.tar.bz2";
    hash = "sha256-a5p80poSu5VZj1dQ6HY87niDahogf4W3TYsydbJ+h8o=";
  };

  patches = [
    # https://github.com/itstool/itstool/pull/51
    (fetchpatch {
      hash = "sha256-5J4mRXQu24o2rqVtaXN/ETgj6A8R0Ym+YkZhqhZTzIc=";
      name = "fix-insufficiently-quoted-regular-expressions-pr51";
      url = "https://github.com/itstool/itstool/commit/19f9580f27aa261ea383b395fdef7e153f3f9e6d.patch";
    })
  ];

  postPatch = ''
    # Do not let autoconf find Python, but set it directly. This fixes cross-compilation.
    substituteInPlace configure.ac \
      --replace-fail 'AM_PATH_PYTHON([2.6])' "" \
      --replace-fail 'AC_MSG_ERROR(Python module $py_module is needed to run this package)' ""
    substituteInPlace itstool.in \
      --replace-fail "@PYTHON@" "${python3.interpreter}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    python3.pkgs.wrapPython
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapPythonPrograms
  '';

  pythonPath = [
    python3.pkgs.libxml2
  ];

  meta = {
    description = "XML to PO and back again";
    homepage = "https://itstool.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "itstool";
  };
})
