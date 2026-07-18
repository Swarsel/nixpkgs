{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  git,
  nix,
  parameterized,
  setuptools,
  sphinx-argparse,
  sphinxHook,
  unittestCheckHook,
  which,
}:

buildPythonPackage rec {
  pname = "nix-prefetch-github";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "seppeljordan";
    repo = "nix-prefetch-github";
    rev = "v${version}";
    hash = "sha256-eQd/MNlnuzXzgFzvwUMchvHoIvkIrbpGKV7iknO14Cc=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    sphinxHook
    sphinx-argparse
    setuptools
  ];

  # ignore tests which are impure
  env.DISABLED_TESTS = "network requires_nix_build";

  nativeCheckInputs = [
    unittestCheckHook
    git
    which
    parameterized
  ];

  dependencies = [ nix ];
  pyproject = true;
  sphinxBuilders = [ "man" ];
  sphinxRoot = "docs";

  meta = {
    description = "Prefetch sources from github";
    homepage = "https://github.com/seppeljordan/nix-prefetch-github";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ seppeljordan ];
  };
}
