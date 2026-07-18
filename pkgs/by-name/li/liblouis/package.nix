{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gettext,
  help2man,
  libyaml,
  perl,
  pkg-config,
  python3,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liblouis";
  version = "3.38.0";

  src = fetchFromGitHub {
    owner = "liblouis";
    repo = "liblouis";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OmYMldo2id2HKAM0Hxi6r86khSUnzu22CkJhGBhaaL8=";
  };

  outputs = [
    "out"
    "dev"
    "info"
    "doc"
  ]
  # configure: WARNING: cannot generate manual pages while cross compiling
  ++ lib.optionals (stdenv.hostPlatform == stdenv.buildPlatform) [ "man" ];

  postPatch = ''
    patchShebangs tests
    substituteInPlace python/louis/__init__.py.in \
      --replace-fail "###LIBLOUIS_SONAME###" "$out/lib/liblouis.so"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gettext
    python3
    python3.pkgs.build
    python3.pkgs.installer
    python3.pkgs.setuptools
    python3.pkgs.wheel
    # Docs, man, info
    texinfo
    help2man
  ];

  buildInputs = [
    # lou_checkYaml
    libyaml
  ];

  configureFlags = [
    # Required by Python bindings
    "--enable-ucs4"
  ];

  doCheck = true;

  nativeCheckInputs = [
    perl
  ];

  postInstall = ''
    pushd python
    python -m build --no-isolation --outdir dist/ --wheel
    python -m installer --prefix $out dist/*.whl
    popd

    make install-html MAKEINFOFLAGS="--no-headers --no-split"
    pushd doc
    make liblouis.txt
    popd
    install -D -t "$doc/share/doc/liblouis" doc/liblouis.txt
  '';

  meta = {
    description = "Open-source braille translator and back-translator";
    homepage = "https://liblouis.io/";

    license = with lib.licenses; [
      lgpl21Plus # library
      gpl3Plus # tools
    ];

    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
  };
})
