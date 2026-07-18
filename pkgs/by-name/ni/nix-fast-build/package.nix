{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  nix-eval-jobs,
  nix-output-monitor,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nix-fast-build";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-fast-build";
    tag = finalAttrs.version;
    hash = "sha256-PMBbenLBvn/0pSFOhwPVn171Vw7kU5YmBUNDhxllZ7c=";
  };

  # Don't run integration tests as they try to run nix
  # to build stuff, which we cannot do inside the sandbox.
  checkPhase = ''
    PYTHONPATH= $out/bin/nix-fast-build --help
  '';

  build-system = [ python3Packages.setuptools ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath (
        [
          nix-eval-jobs
          nix-eval-jobs.nix
          bashInteractive
        ]
        ++ lib.optional (lib.meta.availableOn stdenv.buildPlatform nix-output-monitor.compiler) nix-output-monitor
      )
    }"
  ];

  pyproject = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Combine the power of nix-eval-jobs with nix-output-monitor to speed-up your evaluation and building process";
    homepage = "https://github.com/Mic92/nix-fast-build";
    changelog = "https://github.com/Mic92/nix-fast-build/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      getchoo
      mic92
    ];

    mainProgram = "nix-fast-build";
  };
})
