{
  lib,
  fetchFromGitHub,
  bubblewrap,
  cacert,
  delta,
  git,
  glow,
  installShellFiles,
  nix,
  nix-eval-jobs,
  nix-output-monitor,
  python3Packages,
  versionCheckHook,
  withAutocomplete ? true,
  withDelta ? false,
  withGlow ? false,
  withNom ? false,
  withSandboxSupport ? false,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nixpkgs-review";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nixpkgs-review";
    tag = finalAttrs.version;
    hash = "sha256-u0DbEwe28csVWKbu8x9v9/Ah0ZUUgqXtZU2Rr5IJpWI=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals withAutocomplete [
    python3Packages.argcomplete
  ];

  nativeCheckInputs = [
    versionCheckHook
  ];

  postInstall = lib.optionalString withAutocomplete ''
    for cmd in nix-review nixpkgs-review; do
      installShellCompletion --cmd $cmd \
        --bash <(register-python-argcomplete $cmd) \
        --fish <(register-python-argcomplete $cmd -s fish) \
        --zsh <(register-python-argcomplete $cmd -s zsh)
    done
  '';

  __structuredAttrs = true;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = lib.optionals withAutocomplete [
    python3Packages.argcomplete
  ];

  makeWrapperArgs =
    let
      binPath = [
        nix
        nix-eval-jobs
        git
      ]
      ++ lib.optional withSandboxSupport bubblewrap
      ++ lib.optional withNom nix-output-monitor
      ++ lib.optional withDelta delta
      ++ lib.optional withGlow glow;
    in
    [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath binPath)
      "--set-default"
      "NIX_SSL_CERT_FILE"
      "${cacert}/etc/ssl/certs/ca-bundle.crt"
      # we don't have any runtime deps but nixpkgs-review shells might inject unwanted dependencies
      "--unset"
      "PYTHONPATH"
    ];

  pyproject = true;

  meta = {
    description = "Review pull-requests on https://github.com/NixOS/nixpkgs";
    homepage = "https://github.com/Mic92/nixpkgs-review";
    changelog = "https://github.com/Mic92/nixpkgs-review/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      figsoda
      mdaniels5757
      mic92
    ];

    mainProgram = "nixpkgs-review";
  };
})
