{
  lib,
  fetchFromGitHub,
  buildGoModule,
  # tests
  callPackage,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "dutctl";
  version = "1.0.0-alpha.1-unstable-2026-07-05";

  src = fetchFromGitHub {
    owner = "BlindspotSoftware";
    repo = "dutctl";
    rev = "1ee4c9baee1b088154fd3b94cf1023ef88f8cd0a";
    hash = "sha256-45C4ktDKiz4wkisKTSUCqlR5n5TI13IYPKAbsj5bekY=";
  };

  vendorHash = "sha256-RJviv/FMfU6COdwUcsQb13cETAVOINYEGZNv5y4tKD0=";
  __structuredAttrs = true;

  ldflags = [
    "-s"
  ];

  passthru = {
    tests = callPackage ./test.nix {
      dutctl = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    description = "Unified device management for open firmware development";

    longDescription = ''
      dutctl stands for "Device-under-Test Control" and is an open-source
      command-line utility and service ecosystem for managing development and
      test devices in firmware environments.

      By providing a unified interface to interact with boards and test
      fixtures across platforms, dutctl eliminates the fragmentation of device
      management tools that has long plagued firmware workflows.

      The project features remote device control, command streaming,
      multi-architecture testing, and a flexible plugin architecture for
      extensibility.
    '';

    homepage = "https://github.com/BlindspotSoftware/dutctl";
    changelog = "https://github.com/BlindspotSoftware/dutctl/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "dutctl";
    teams = with lib.teams; [ ngi ];
  };
})
