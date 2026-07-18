{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  zig_0_15,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flow-control";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "neurocyte";
    repo = "flow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5+F0DKb4LXtcMXNutUSJuIe7cdBoFUoJhCs8vbm20jg=";
  };

  nativeBuildInputs = [ zig_0_15 ];
  env.VERSION = finalAttrs.version;

  deps = callPackage ./build.zig.zon.nix {
    zig = zig_0_15;
  };

  dontSetZigDefaultFlags = true;

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
    "-Dcpu=baseline"
    "-Doptimize=ReleaseFast"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Programmer's text editor";
    homepage = "https://github.com/neurocyte/flow";
    changelog = "https://github.com/neurocyte/flow/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "flow";
  };
})
