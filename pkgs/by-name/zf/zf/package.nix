{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  installShellFiles,
  testers,
  zig_0_15,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zf";
  version = "${finalAttrs.upstreamVersion}-unstable-2025-10-14";

  src = fetchFromGitHub {
    owner = "natecraddock";
    repo = "zf";
    rev = finalAttrs.rev;
    hash = "sha256-BfAZILill3I/nBf1oWwol77N34Jcpm4hudC+XSeMgZY=";
  };

  nativeBuildInputs = [
    installShellFiles
    zig_0_15
  ];

  doCheck = true;

  postInstall = ''
    installManPage doc/zf.1
    installShellCompletion \
      --bash complete/zf \
      --fish complete/zf.fish \
      --zsh complete/_zf
  '';

  doInstallCheck = true;

  deps = callPackage ./deps.nix {
    name = "${finalAttrs.pname}-cache-${finalAttrs.version}";
  };

  dontSetZigDefaultFlags = true;
  rev = "3c52637b7e937c5ae61fd679717da3e276765b23";
  upstreamVersion = "0.10.3";

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
    "-Dcpu=baseline"
    "-Doptimize=ReleaseFast"
  ];

  zigCheckFlags = finalAttrs.zigBuildFlags;

  passthru.tests.version = testers.testVersion {
    version = finalAttrs.upstreamVersion;
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Commandline fuzzy finder that prioritizes matches on filenames";
    homepage = "https://github.com/natecraddock/zf";
    changelog = "https://github.com/natecraddock/zf/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mmlb
    ];

    platforms = lib.platforms.unix;
    mainProgram = "zf";
  };
})
