{
  lib,
  stdenv,
  callPackage,
  fetchFromSourcehut,
  harec,
  mailcap,
  pkgsCross,
  replaceVars,
  scdoc,
  tzdata,
  aarch64PkgsCrossToolchain ?
    if stdenv.hostPlatform.isMusl then
      pkgsCross.aarch64-multiplatform-musl
    else
      pkgsCross.aarch64-multiplatform,
  enableCrossCompilation ? (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.is64bit),
  riscv64PkgsCrossToolchain ?
    if stdenv.hostPlatform.isMusl then pkgsCross.riscv64-musl else pkgsCross.riscv64,
  x86_64PkgsCrossToolchain ? if stdenv.hostPlatform.isMusl then pkgsCross.musl64 else pkgsCross.gnu64,
}:

# There's no support for `aarch64` or `riscv64` for freebsd nor for openbsd on nix.
# See `lib.systems.doubles.aarch64` and `lib.systems.doubles.riscv64`.
assert
  let
    inherit (stdenv.hostPlatform) isLinux is64bit;
    inherit (lib) intersectLists platforms concatStringsSep;
    workingPlatforms = intersectLists platforms.linux (with platforms; x86_64 ++ aarch64 ++ riscv64);
  in
  lib.assertMsg (enableCrossCompilation -> isLinux && is64bit) ''
    The cross-compilation toolchains may only be enabled on the following platforms:
    ${concatStringsSep "\n" workingPlatforms}
  '';

let
  inherit (harec) qbe;
  buildArch = stdenv.buildPlatform.uname.processor;
  arch = stdenv.hostPlatform.uname.processor;
  platform = lib.toLower stdenv.hostPlatform.uname.system;
  qbePlatform =
    {
      aarch64 = "arm64";
      riscv64 = "rv64";
      x86_64 = "amd64_sysv";
    }
    .${arch};
  embeddedOnBinaryTools =
    let
      genPaths =
        toolchain:
        let
          inherit (toolchain.stdenv.cc) targetPrefix;
          inherit (toolchain.stdenv.targetPlatform.uname) processor;
        in
        {
          "${processor}" = {
            "as" = lib.getExe' toolchain.buildPackages.binutils "${targetPrefix}as";
            "cc" = lib.getExe' toolchain.stdenv.cc "${targetPrefix}cc";
            "ld" = lib.getExe' toolchain.buildPackages.binutils "${targetPrefix}ld";
          };
        };
    in
    builtins.foldl' (acc: elem: acc // (genPaths elem)) { } [
      x86_64PkgsCrossToolchain
      aarch64PkgsCrossToolchain
      riscv64PkgsCrossToolchain
    ];
  crossCompMakeFlags = builtins.filter (x: !(lib.hasPrefix (lib.toUpper buildArch) x)) [
    "RISCV64_AS=${embeddedOnBinaryTools.riscv64.as}"
    "RISCV64_CC=${embeddedOnBinaryTools.riscv64.cc}"
    "RISCV64_LD=${embeddedOnBinaryTools.riscv64.ld}"
    "AARCH64_AS=${embeddedOnBinaryTools.aarch64.as}"
    "AARCH64_CC=${embeddedOnBinaryTools.aarch64.cc}"
    "AARCH64_LD=${embeddedOnBinaryTools.aarch64.ld}"
    "X86_64_AS=${embeddedOnBinaryTools.x86_64.as}"
    "X86_64_CC=${embeddedOnBinaryTools.x86_64.cc}"
    "X86_64_LD=${embeddedOnBinaryTools.x86_64.ld}"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hare";
  version = "0.26.0.1";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "hare";
    tag = finalAttrs.version;
    hash = "sha256-ypu3GXO2hTGg26l0+FUzEMK/+HiylJIWQxe9UbhKXz4=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Replace FHS paths with nix store
    (replaceVars ./001-tzdata.patch {
      inherit tzdata;
    })
    # Don't build haredoc since it uses the build `hare` bin, which breaks
    # cross-compilation.
    ./002-dont-build-haredoc.patch
    # Hardcode harec and qbe.
    (replaceVars ./003-hardcode-qbe-and-harec.patch {
      harec_bin = lib.getExe harec;
      qbe_bin = lib.getExe qbe;
    })
    # Use mailcap `/etc/mime.types` for Hare's mime module
    (replaceVars ./004-use-mailcap-for-mimetypes.patch {
      inherit mailcap;
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    harec
    qbe
    scdoc
  ];

  buildInputs = [
    harec
    qbe
  ];

  makeFlags = [
    "HARECACHE=.harecache"
    "PREFIX=${placeholder "out"}"
    "ARCH=${arch}"
    "VERSION=${finalAttrs.version}-nixpkgs"
    "QBEFLAGS=-t${qbePlatform}"
    "AS=${stdenv.cc.targetPrefix}as"
    "LD=${stdenv.cc.targetPrefix}ld"
    "${lib.toUpper buildArch}_AS=${embeddedOnBinaryTools.${buildArch}.as}"
    "${lib.toUpper buildArch}_CC=${embeddedOnBinaryTools.${buildArch}.cc}"
    "${lib.toUpper buildArch}_LD=${embeddedOnBinaryTools.${buildArch}.ld}"
    # Strip the variable of an empty $(SRCDIR)/hare/third-party, since nix does
    # not follow the FHS.
    "HAREPATH=$(SRCDIR)/hare/stdlib"
  ]
  ++ lib.optionals enableCrossCompilation crossCompMakeFlags;

  # Append the distribution name to the version
  env.LOCALVER = "nixpkgs";

  postConfigure = ''
    ln -s configs/${platform}.mk config.mk
  '';

  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    # To be propagated by `hareHook`.
    inherit harec qbe;

    tests =
      lib.optionalAttrs enableCrossCompilation {
        crossCompilation = callPackage ./cross-compilation-tests.nix { hare = finalAttrs.finalPackage; };
      }
      // lib.optionalAttrs (stdenv.buildPlatform.canExecute stdenv.hostPlatform) {
        mimeModule = callPackage ./mime-module-test.nix { hare = finalAttrs.finalPackage; };
      }
      //
        lib.optionalAttrs (enableCrossCompilation && stdenv.buildPlatform.canExecute stdenv.hostPlatform)
          {
            crossCompilation = callPackage ./cross-compilation-tests.nix { hare = finalAttrs.finalPackage; };
          };
  };

  meta = {
    inherit (harec.meta) platforms badPlatforms;
    description = "Systems programming language designed to be simple, stable, and robust";
    homepage = "https://harelang.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "hare";
  };
})
