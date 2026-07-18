{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "bashplotlib";
  version = "0.6.5-unstable-2021-03-31";

  src = fetchFromGitHub {
    owner = "glamp";
    repo = "bashplotlib";
    rev = "db4065cfe65c0bf7c530e0e8b9328daf9593ad74";
    sha256 = "sha256-0S6mgy6k7CcqsDR1kE5xcXGidF1t061e+M+ZuP2Gk3c=";
  };

  # No tests
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plotting in the terminal";
    homepage = "https://github.com/glamp/bashplotlib";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
