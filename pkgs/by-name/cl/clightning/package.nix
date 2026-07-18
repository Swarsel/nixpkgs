{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  autogen,
  automake,
  cctools,
  darwin,
  gettext,
  gmp,
  jq,
  libpq,
  libsodium,
  libtool,
  lowdown-unsandboxed,
  protobuf,
  python3,
  sqlite,
  unzip,
  which,
  zlib,
}:
let
  py3 = python3.withPackages (p: [
    p.distutils
    p.mako
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "clightning";
  version = "26.04.1";

  src = fetchurl {
    url = "https://github.com/ElementsProject/lightning/releases/download/v${finalAttrs.version}/clightning-v${finalAttrs.version}.zip";
    hash = "sha256-MEsZ5GPCY6q/SNO+xcktfGiCZUVgl4p7pdMOiqIqFJM=";
  };

  # this causes some python trouble on a darwin host so we skip this step.
  # also we have to tell libwally-core to use sed instead of gsed.
  postPatch =
    if !stdenv.hostPlatform.isDarwin then
      ''
        patchShebangs \
          tools/generate-wire.py \
          tools/update-mocks.sh \
          tools/mockup.sh \
          tools/fromschema.py \
          devtools/sql-rewrite.py
      ''
    else
      ''
        substituteInPlace external/libwally-core/tools/autogen.sh --replace gsed sed && \
        substituteInPlace external/libwally-core/configure.ac --replace gsed sed
      '';

  # when building on darwin we need cctools to provide the correct libtool
  # as libwally-core detects the host as darwin and tries to add the -static
  # option to libtool, also we have to add the modified gsed package.
  nativeBuildInputs = [
    autoconf
    autogen
    automake
    gettext
    libtool
    lowdown-unsandboxed
    protobuf
    py3
    unzip
    which
    libpq.pg_config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
    darwin.autoSignDarwinBinariesHook
  ];

  buildInputs = [
    gmp
    libsodium
    sqlite
    zlib
    jq
  ];

  configureFlags = [ "--disable-valgrind" ];
  makeFlags = [ "VERSION=v${finalAttrs.version}" ];

  # workaround for build issue, happens only x86_64-darwin, not aarch64-darwin
  # ccan/ccan/fdpass/fdpass.c:16:8: error: variable length array folded to constant array as an extension [-Werror,-Wgnu-folding-constant]
  #                 char buf[CMSG_SPACE(sizeof(fd))];
  env.NIX_CFLAGS_COMPILE = lib.optionalString (
    stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64
  ) "-Wno-error=gnu-folding-constant";

  enableParallelBuilding = true;

  meta = {
    description = "Bitcoin Lightning Network implementation in C";

    longDescription = ''
      c-lightning is a standard compliant implementation of the Lightning
      Network protocol. The Lightning Network is a scalability solution for
      Bitcoin, enabling secure and instant transfer of funds between any two
      parties for any amount.
    '';

    homepage = "https://github.com/ElementsProject/lightning";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jb55
      prusnak
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
