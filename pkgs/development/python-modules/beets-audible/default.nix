{
  lib,
  fetchFromGitHub,
  # native
  beets-minimal,
  buildPythonPackage,
  # dependencies
  markdownify,
  natsort,
  # passthru
  nix-update-script,
  tldextract,
  # build-system
  uv-build,
}:

buildPythonPackage rec {
  pname = "beets-audible";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "Neurrone";
    repo = "beets-audible";
    tag = "v${version}";
    hash = "sha256-u4EbUmUsaCs22QBGaKWzPjz0nzxH/zQBIQ8vsyVHBoE=";
  };

  nativeBuildInputs = [
    beets-minimal
  ];

  build-system = [
    uv-build
  ];

  dependencies = [
    markdownify
    natsort
    tldextract
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Beets-audible: Organize Your Audiobook Collection With Beets";
    homepage = "https://github.com/Neurrone/beets-audible";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ jwillikers ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
  };
}
