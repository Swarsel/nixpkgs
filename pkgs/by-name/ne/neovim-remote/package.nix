{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  neovim,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "neovim-remote";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "mhinz";
    repo = "neovim-remote";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uO5KezbUQGj3rNpuw2SJOzcP86DZqX7DJFz3BxEnf1E=";
  };

  patches = [
    # Fix a compatibility issue with neovim 0.8.0
    (fetchpatch {
      hash = "sha256-/PjE+9yfHtOUEp3xBaobzRM8Eo2wqOhnF1Es7SIdxvM=";
      url = "https://github.com/mhinz/neovim-remote/commit/56d2a4097f4b639a16902390d9bdd8d1350f948c.patch";
    })
    # Fix nvr --version: replace deprecated pkg_resources with importlib.metadata
    # (stdlib since Python 3.8). setuptools was correctly kept in build-system
    # only; this avoids adding it as a spurious runtime dependency.
    ./use-importlib-metadata.patch
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    neovim
    python3.pkgs.pytestCheckHook
  ];

  preCheck = ''
    export HOME="$(mktemp -d)"
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    pynvim
    psutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "nvr" ];

  meta = {
    description = "Tool that helps controlling nvim processes from a terminal";
    homepage = "https://github.com/mhinz/neovim-remote/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ edanaher ];
    platforms = lib.platforms.unix;
    mainProgram = "nvr";
  };
})
