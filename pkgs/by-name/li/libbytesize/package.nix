{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docbook_xml_dtd_43,
  docbook_xsl,
  gettext,
  gmp,
  gtk-doc,
  libxslt,
  mpfr,
  nix-update-script,
  pcre2,
  pkg-config,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libbytesize";
  version = "2.12";

  src = fetchFromGitHub {
    owner = "storaged-project";
    repo = "libbytesize";
    rev = finalAttrs.version;
    hash = "sha256-MQADGFruQODQ8rxu1R8TF9zqd4jKLtyRQrWFds5UNS0=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    docbook_xml_dtd_43
    docbook_xsl
    gettext
    gtk-doc
    libxslt
    pkg-config
    python3Packages.python
  ];

  buildInputs = [
    gmp
    mpfr
    pcre2
  ];

  postInstall = ''
    substituteInPlace $out/${python3Packages.python.sitePackages}/bytesize/bytesize.py \
      --replace-fail 'CDLL("libbytesize.so.1")' "CDLL('$out/lib/libbytesize.so.1')"

    # Force compilation of .pyc files to make them deterministic
    ${python3Packages.python.pythonOnBuildForHost.interpreter} -m compileall $out/${python3Packages.python.sitePackages}/bytesize
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    python3Packages.pythonImportsCheckHook
  ];

  pythonImportsCheck = [ "bytesize" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tiny library providing a C 'class' for working with arbitrary big sizes in bytes";
    homepage = "https://github.com/storaged-project/libbytesize";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.PlasmaPower ];
    platforms = lib.platforms.linux;
    mainProgram = "bscalc";
  };
})
