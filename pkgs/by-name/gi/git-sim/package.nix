{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3,

  # Override Python packages using
  # self: super: { pkg = super.pkg.overridePythonAttrs (oldAttrs: { ... }); }
  # Applied after defaultOverrides
  packageOverrides ? self: super: { },
}:
let
  python = python3.override {
    packageOverrides = lib.composeManyExtensions [ packageOverrides ];
    self = python;
  };

  version = "0.3.5";
in

with python.pkgs;
buildPythonApplication {
  inherit version;
  pname = "git-sim";

  src = fetchFromGitHub {
    owner = "initialcommit-com";
    repo = "git-sim";
    rev = "v${version}";
    hash = "sha256-4jHkAlF2SAzHjBi8pmAJ0TKkcLxw+6EdGsXnHZUMILw=";
  };

  patches = [ ./tests.patch ];
  nativeBuildInputs = [ installShellFiles ];
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    git-dummy
  ];

  preCheck = ''
    PATH=$PATH:$out/bin
  '';

  postInstall =
    # https://github.com/NixOS/nixpkgs/issues/308283
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd git-sim \
        --bash <($out/bin/git-sim --show-completion bash) \
        --fish <($out/bin/git-sim --show-completion fish) \
        --zsh <($out/bin/git-sim --show-completion zsh)
    ''
    + "ln -s ${git-dummy}/bin/git-dummy $out/bin/";

  build-system = [ setuptools ];

  dependencies = [
    gitpython
    manim
    opencv4
    typer
    pydantic
    fonttools
    git-dummy
  ];

  # https://github.com/NixOS/nixpkgs/commit/8033561015355dd3c3cf419d81ead31e534d2138
  makeWrapperArgs = [ "--prefix PYTHONWARNINGS , ignore:::pydub.utils:" ];
  pyproject = true;
  pythonRemoveDeps = [ "opencv-python-headless" ];

  meta = {
    description = "Visually simulate Git operations in your own repos with a single terminal command";
    homepage = "https://initialcommit.com/tools/git-sim";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mathiassven ];
  };
}
