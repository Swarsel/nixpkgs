{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "graphlan";
  version = "1.1.3-unstable-2024-08-07";

  src = fetchFromGitHub {
    owner = "biobakery";
    repo = "graphlan";
    rev = "dc97f4feb0bb0bf3fa210e2699a86c5e476a647e";
    hash = "sha256-sBVlBu6RSs7dXQbxJrIQHWaDNliurY9UguzNeKj40gY=";
  };

  strictDeps = true;
  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    biopython
    matplotlib
    scipy
  ];

  patchPhase = ''
    sed -i 's|biopython==|biopython>=|' setup.py
  '';

  pyproject = true;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Quality control tool for metagenomic and metatranscriptomic sequencing data";
    homepage = "https://github.com/biobakery/graphlan";
    changelog = "https://github.com/biobakery/graphlan/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pandapip1 ];
    platforms = lib.platforms.all;
    mainProgram = "graphlan.py";
  };
}
