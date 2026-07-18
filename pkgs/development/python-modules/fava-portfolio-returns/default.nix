{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  buildPythonPackage,
  fava,
  hatch-vcs,
  hatchling,
  numpy,
  pandas,
  protobuf,
  pytestCheckHook,
  scipy,
}:
let
  pname = "fava-portfolio-returns";
  version = "2.4.0";
  src = fetchFromGitHub {
    owner = "andreasgerstmayr";
    repo = "fava-portfolio-returns";
    tag = "v${version}";
    hash = "sha256-3v5zIpho6HppNm1yJdVJKhPxKgNsvRetOQIAKkp6u9U=";
  };

  frontend = buildNpmPackage (finalAttrs: {
    inherit version;
    pname = "${pname}-frontend";
    src = "${src}/frontend";

    postPatch = ''
      substituteInPlace package.json \
        --replace-fail '"name": "fava-portfolio-returns",' '"name": "fava-portfolio-returns", "version": "${finalAttrs.version}",'
    '';

    npmDepsHash = "sha256-/9sCyhGUOZ/muwJNKABy7ouPJa5ieVXjIFCSWw9AyRo=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp ../src/fava_portfolio_returns/FavaPortfolioReturns.js $out/

      runHook postInstall
    '';
  });
in
buildPythonPackage {
  inherit pname version src;
  nativeCheckInputs = [ pytestCheckHook ];

  preInstall = ''
    cp ${frontend}/FavaPortfolioReturns.js src/fava_portfolio_returns/
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    fava
    numpy
    pandas
    protobuf
    scipy
  ];

  pyproject = true;

  # Use importlib import mode to avoid `PYTHONPATH` issues related to `pytestCheckHook` ([1])
  # [1]: https://github.com/NixOS/nixpkgs/issues/255262
  pytestFlags = [
    "--import-mode=importlib"
  ];

  pythonImportsCheck = [ "fava_portfolio_returns" ];

  passthru = {
    inherit frontend;
  };

  meta = {
    description = "Show portfolio returns in Fava";
    homepage = "https://github.com/andreasgerstmayr/fava-portfolio-returns";
    changelog = "https://github.com/andreasgerstmayr/fava-portfolio-returns/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
}
