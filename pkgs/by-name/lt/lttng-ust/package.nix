{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  autoreconfHook,
  liburcu,
  nix-update-script,
  numactl,
  pkg-config,
  python3,
  testers,
  xmlto,
}:

# NOTE:
#   ./configure ...
#   [...]
#   LTTng-UST will be built with the following options:
#
#   Java support (JNI): Disabled
#   sdt.h integration:  Disabled
#   [...]
#
# Debian builds with std.h (systemtap).

stdenv.mkDerivation (finalAttrs: {
  pname = "lttng-ust";
  version = "2.15.1";

  src = fetchFromGitHub {
    owner = "lttng";
    repo = "lttng-ust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AWo205IPGKpEyz5RlscHfdfCTV0zOWPHOGk4ImAJbcQ=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    # to build the manpages, xmlto uses xmllint which tries to fetch a dtd schema
    # from the internet - just don't validate to work around this
    substituteInPlace doc/man/Makefile.am \
      --replace-fail '$(XMLTO)' '$(XMLTO) --skip-validation'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    asciidoc
    xmlto
  ];

  buildInputs = [
    numactl
    python3
  ];

  propagatedBuildInputs = [ liburcu ];

  configureFlags = [
    "--disable-examples"
  ]
  ++ lib.optionals stdenv.hostPlatform.isMusl [
    # lttng-ust puts a single array on the stack that's the size of
    # musl's whole default stack.
    # https://review.lttng.org/c/lttng-ust/+/18160
    "CFLAGS=-Wl,-z,stack-size=2097152"
  ];

  preConfigure = ''
    patchShebangs .
  '';

  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v(.+)"
      ];
    };
  };

  meta = {
    description = "LTTng Userspace Tracer libraries";
    homepage = "https://lttng.org/";
    changelog = "https://github.com/lttng/lttng-ust/blob/v${finalAttrs.version}/ChangeLog";

    license = with lib.licenses; [
      lgpl21Only
      gpl2Only
      mit
    ];

    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.intersectLists lib.platforms.linux liburcu.meta.platforms;
    mainProgram = "lttng-gen-tp";

    pkgConfigModules = [
      "lttng-ust-ctl"
      "lttng-ust"
    ];
  };
})
