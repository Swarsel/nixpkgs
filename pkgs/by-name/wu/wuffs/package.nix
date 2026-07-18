{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  makeBinaryWrapper,
  replaceVars,
  testers,
}:
let
  compiler =
    if stdenv.cc.isClang then
      "clang"
    else if stdenv.cc.isGNU then
      "gcc"
    else
      throw "unsupported compiler";
in
buildGoModule (finalAttrs: {
  pname = "wuffs";
  version = "0.4.0-alpha.9";

  src = fetchFromGitHub {
    owner = "google";
    repo = "wuffs";
    tag = "v" + finalAttrs.version;
    hash = "sha256-XbupK4QYnPudUlO5tRWrQRncGHITzJL//Yk/E7WNxYk=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  strictDeps = true;
  nativeBuildInputs = [ makeBinaryWrapper ];
  vendorHash = null;
  # There are no checks
  doCheck = false;

  postInstall =
    let
      pkgconfig = replaceVars ./wuffs.pc {
        DESCRIPTION = finalAttrs.meta.description;
        DEV = placeholder "dev";
        LIB = placeholder "lib";
        VERSION = finalAttrs.version;
      };
    in
    ''
      wrapProgram "$out/bin/wuffs" \
        --prefix PATH : "$out/bin"

      "$out/bin/wuffs" gen std/...
      "$out/bin/wuffs" genlib -ccompilers=${compiler}

      install -Dm444 -t "$lib/lib" gen/lib/c/${compiler}-dynamic/libwuffs.*

      install -Dm444 release/c/wuffs-unsupported-snapshot.c "$dev/include/wuffs/wuffs-v0.4.c"

      install -Dm444 ${pkgconfig} "$dev/lib/pkgconfig/wuffs.pc"
    '';

  subPackages = [
    "cmd/wuffs-c"
    "cmd/wuffs"
  ];

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "memory-safe programming language and standard library for wrangling untrusted data";
    homepage = "https://github.com/google/wuffs";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = [
    ];

    mainProgram = "wuffs";
    pkgConfigModules = [ "wuffs" ];
  };
})
