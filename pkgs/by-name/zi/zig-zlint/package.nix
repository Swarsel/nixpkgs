{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  versionCheckHook,
  zig_0_16,
}:

let
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zig-zlint";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "DonIsaac";
    repo = "zlint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z5HYJbt4VAOI/o9TqFdZ4Q1BhgIin/NR29gFIZCX/i0=";
    name = "zlint"; # tests expect this
  };

  nativeBuildInputs = [
    zig
  ];

  doCheck = true;

  # `zig build` produces a lot more artifacts, just copy over the ones we want
  installPhase = ''
    runHook preInstall
    install -vDm755 zig-out/bin/zlint $out/bin/zlint
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/zlint";

  zigBuildFlags = [
    "-Dversion=v${finalAttrs.version}"
    "--system"
    (callPackage ./build.zig.zon.nix { })
  ];

  zigCheckFlags = finalAttrs.zigBuildFlags;

  meta = {
    inherit (zig.meta) platforms;
    description = "Linter for the Zig programming language";
    homepage = "https://github.com/DonIsaac/zlint";
    changelog = "https://github.com/DonIsaac/zlint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ christoph-heiss ];
    mainProgram = "zlint";
  };
})
