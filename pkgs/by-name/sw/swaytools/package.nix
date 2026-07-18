{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  slurp,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "swaytools";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "tmccombs";
    repo = "swaytools";
    rev = finalAttrs.version;
    sha256 = "sha256-UoWK53B1DNmKwNLFwJW1ZEm9dwMOvQeO03+RoMl6M0Q=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools ];
  propagatedBuildInputs = [ slurp ];
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Collection of simple tools for sway (and i3)";
    homepage = "https://github.com/tmccombs/swaytools";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
