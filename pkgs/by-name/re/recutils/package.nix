{
  lib,
  stdenv,
  fetchurl,
  bash,
  bc,
  check,
  curl,
  fetchpatch,
  libgcrypt,
  libgpg-error,
  libuuid,
  withBashBuiltins ? true,
  withEncryption ? true,
  withUuid ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "recutils";
  version = "1.9";

  src = fetchurl {
    url = "mirror://gnu/recutils/recutils-${finalAttrs.version}.tar.gz";
    hash = "sha256-YwFZKwAgwUtFZ1fvXUNNSfYCe45fOkmdEzYvIFxIbg4=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-NazWrrwZhD8aKzpj6IC6zrD1J4qxrOZh5XpQLZ14yTw=";
      name = "configure-big_sur.diff";
      url = "https://github.com/Homebrew/formula-patches/raw/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff";
    })
  ];

  buildInputs = [
    curl
  ]
  ++ lib.optionals withEncryption [
    libgpg-error.dev
    libgcrypt.dev
  ]
  ++ lib.optionals withUuid [
    libuuid
  ]
  ++ lib.optionals withBashBuiltins [
    bash.dev
  ];

  configureFlags = lib.optionals withBashBuiltins [
    "--with-bash-headers=${bash.dev}/include/bash"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      "-Wno-error=implicit-function-declaration"
    ]
    ++ lib.optionals stdenv.cc.isGNU [
      "-Wno-error=implicit-function-declaration"
      "-Wno-error=incompatible-pointer-types"
    ]
  );

  doCheck = true;

  nativeCheckInputs = [
    bc
    check
  ];

  hardeningDisable = lib.optional stdenv.cc.isClang "format";

  meta = {
    description = "Tools and libraries to access human-editable, text-based databases";

    longDescription = ''
      GNU Recutils is a set of tools and libraries to access human-editable,
      text-based databases called recfiles. The data is stored as a sequence of
      records, each record containing an arbitrary number of named fields.
    '';

    homepage = "https://www.gnu.org/software/recutils/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
