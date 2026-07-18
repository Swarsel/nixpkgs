{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  installShellFiles,
  zig_0_16,
}:

let
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "linuxwave";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "orhun";
    repo = "linuxwave";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5LcAExNFCsQIeRqLHMCLO+MnK7p2q2qOA1SdMCR4nCw=";
  };

  nativeBuildInputs = [
    installShellFiles
    zig
  ];

  postInstall = ''
    installManPage man/linuxwave.1
  '';

  zigBuildFlags = [
    "--system"
    (callPackage ./deps.nix { })
  ];

  meta = {
    inherit (zig.meta) platforms;
    description = "Generate music from the entropy of Linux";
    homepage = "https://github.com/orhun/linuxwave";
    changelog = "https://github.com/orhun/linuxwave/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
    mainProgram = "linuxwave";
  };
})
