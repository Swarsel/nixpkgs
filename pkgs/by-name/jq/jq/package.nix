{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  bison,
  nix-update-script,
  oniguruma,
  removeReferencesTo,
  testers,
  tzdata,
  onigurumaSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jq";
  version = "1.8.2";

  # Note: do not use fetchpatch or fetchFromGitHub to keep this package available in __bootPackages
  src = fetchurl {
    url = "https://github.com/jqlang/jq/releases/download/jq-${finalAttrs.version}/jq-${finalAttrs.version}.tar.gz";
    hash = "sha256-cbjW6PX+gfbG0NEQ44kiUfbOdu0JWr0xXibm4Rk6868=";
  };

  outputs = [
    "bin"
    "doc"
    "man"
    "dev"
    "out"
  ];

  patches = lib.optionals stdenv.hostPlatform.is32bit [
    # needed because epoch conversion test here is right at the end of 32 bit integer space
    # See also: https://github.com/jqlang/jq/blob/859a8073ee8a21f2133154eea7c2bd5e0d60837f/tests/optional.test#L15-L18
    # "-D_TIME_BITS=64 -D_FILE_OFFSET_BITS=64" would be preferrable, but breaks with dynamic linking,
    # unless done globally in stdenv for all of 32 bit.
    ./disable-end-of-epoch-conversion-test.patch
  ];

  # https://github.com/jqlang/jq/issues/2871
  postPatch = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
    substituteInPlace Makefile.am --replace-fail "tests/mantest" "" --replace-fail "tests/optionaltest" ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    removeReferencesTo
    autoreconfHook
    bison
  ];

  buildInputs = lib.optionals onigurumaSupport [ oniguruma ];

  configureFlags = [
    "--bindir=\${bin}/bin"
    "--sbindir=\${bin}/bin"
    "--datadir=\${doc}/share"
    "--mandir=\${man}/share/man"
  ]
  ++ lib.optional (!onigurumaSupport) "--with-oniguruma=no"
  # jq is linked to libjq:
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) "LDFLAGS=-Wl,-rpath,\\\${libdir}";

  # Upstream script that writes the version that's eventually compiled
  # and printed in `jq --help` relies on a .git directory which our src
  # doesn't keep.
  preConfigure = ''
    echo "#!/bin/sh" > scripts/version
    echo "echo ${finalAttrs.version}" >> scripts/version
    patchShebangs scripts/version
  '';

  # paranoid mode: make sure we never use vendored version of oniguruma
  # Note: it must be run after automake, or automake will complain
  preBuild = ''
    rm -r ./vendor/oniguruma
  '';

  doInstallCheck = true;

  # jq binary includes the whole `configureFlags` in:
  # https://github.com/jqlang/jq/commit/583e4a27188a2db097dd043dd203b9c106bba100
  # Strip unnecessary dependencies here to reduce closure size and break the
  # dependency cycle: $dev also refers to $bin via propagated-build-outputs
  postFixup = ''
    remove-references-to \
      -t "$dev" \
      -t "$man" \
      -t "$doc" \
      "$bin/bin/jq"
  '';

  enableParallelBuilding = true;
  installCheckTarget = "check";

  postInstallCheck = ''
    $bin/bin/jq -r '.values[1]' <<< '{"values":["hello","world"]}' | grep '^world$' > /dev/null
  '';

  preInstallCheck = ''
    substituteInPlace tests/shtest \
      --replace-fail "TZ=" "TZ=${tzdata}/share/zoneinfo/"
  '';

  passthru = {
    inherit onigurumaSupport;

    tests.version = testers.testVersion {
      command = "jq --version";
      package = lib.getBin finalAttrs.finalPackage;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "jq-(.+)"
      ];
    };
  };

  meta = {
    description = "Lightweight and flexible command-line JSON processor";
    homepage = "https://jqlang.github.io/jq/";
    changelog = "https://github.com/jqlang/jq/releases/tag/jq-${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      raskin
      artturin
      ncfavier
      jk
    ];

    platforms = lib.platforms.unix;
    mainProgram = "jq";
    downloadPage = "https://jqlang.github.io/jq/download/";

    identifiers.purlParts = {
      spec = "jqlang/jq@jq-${finalAttrs.version}";
      type = "github";
    };
  };
})
