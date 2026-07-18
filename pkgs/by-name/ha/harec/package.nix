{
  lib,
  stdenv,
  _experimental-update-script-combinators,
  fetchFromSourcehut,
  gitUpdater,
  qbe,
}:
let
  platform = lib.toLower stdenv.hostPlatform.uname.system;
  arch = stdenv.hostPlatform.uname.processor;
  qbePlatform =
    {
      aarch64 = "arm64";
      riscv64 = "rv64";
      x86_64 = "amd64_sysv";
    }
    .${arch};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "harec";
  version = "0.26.0";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "harec";
    tag = finalAttrs.version;
    hash = "sha256-azj37C+Uw8wqy0lf3g/kB353iufY6P7Rf20aLCRp9a8=";
  };

  strictDeps = true;
  nativeBuildInputs = [ qbe ];
  buildInputs = [ qbe ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "ARCH=${arch}"
    "VERSION=${finalAttrs.version}-nixpkgs"
    "QBEFLAGS=-t${qbePlatform}"
    "CC=${stdenv.cc.targetPrefix}cc"
    "AS=${stdenv.cc.targetPrefix}as"
    "LD=${stdenv.cc.targetPrefix}ld"
  ];

  postConfigure = ''
    ln -s configs/${platform}.mk config.mk
  '';

  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    # To be kept in sync with the hare package.
    inherit qbe;

    updateScript = _experimental-update-script-combinators.sequence (
      map (item: item.command) [
        (gitUpdater {
          attrPath = "harec";
          ignoredVersions = [ "-rc[0-9]{1,}" ];
        })
        (gitUpdater {
          attrPath = "hare";
          ignoredVersions = [ "-rc[0-9]{1,}" ];
          url = "https://git.sr.ht/~sircmpwn/hare";
        })
      ]
    );
  };

  meta = {
    description = "Bootstrapping Hare compiler written in C for POSIX systems";
    homepage = "https://harelang.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sikmir ];

    # The upstream developers do not like proprietary operating systems; see
    # https://harelang.org/platforms/
    # UPDATE: https://github.com/hshq/harelang provides a MacOS port
    platforms =
      with lib.platforms;
      lib.intersectLists (freebsd ++ openbsd ++ linux) (aarch64 ++ x86_64 ++ riscv64);

    badPlatforms = lib.platforms.darwin;
    mainProgram = "harec";
  };
})
