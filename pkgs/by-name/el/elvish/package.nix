{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
}:

buildGoModule (finalAttrs: {
  pname = "elvish";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "elves";
    repo = "elvish";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+qkr0ziHWs3MVhBoqAxrwwbsQVvmGHRKrlqiujqBKvs=";
  };

  strictDeps = true;
  vendorHash = "sha256-UjX1P8v97Mi5cLWv3n7pmxgnw+wCr4aRTHDHHd/9+Lo=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X src.elv.sh/pkg/buildinfo.Version==${finalAttrs.version}"
  ];

  subPackages = [ "cmd/elvish" ];

  passthru = {
    shellPath = "/bin/elvish";

    tests = {
      expectVersion = callPackage ./tests/expect-version.nix { };
    };
  };

  meta = {
    description = "Friendly and expressive command shell";

    longDescription = ''
      Elvish is a friendly interactive shell and an expressive programming
      language. It runs on Linux, BSDs, macOS and Windows. Despite its pre-1.0
      status, it is already suitable for most daily interactive use.
    '';

    homepage = "https://elv.sh/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "elvish";
  };
})
