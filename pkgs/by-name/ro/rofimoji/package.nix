{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
  wl-clipboard,
  wtype,
  xdotool,
  xsel,
  waylandSupport ? (!stdenv.hostPlatform.isDarwin),
  x11Support ? (!stdenv.hostPlatform.isDarwin),
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rofimoji";
  version = "6.8.0";

  src = fetchFromGitHub {
    owner = "fdw";
    repo = "rofimoji";
    tag = finalAttrs.version;
    hash = "sha256-KOWj/u5JxgHiUf/hPBu+PfPgSRd/HVivU3F8oWqzIv4=";
  };

  # The 'extractors' sub-module is used for development
  # and has additional dependencies.
  postPatch = ''
    rm -rf extractors
  '';

  nativeBuildInputs = [
    python3Packages.hatchling
    installShellFiles
  ];

  # `rofi` and the `waylandSupport` and `x11Support` dependencies
  # contain binaries needed at runtime.
  propagatedBuildInputs = [
    python3Packages.configargparse
  ]
  ++ lib.optionals waylandSupport [
    wl-clipboard
    wtype
  ]
  ++ lib.optionals x11Support [
    xdotool
    xsel
  ];

  postInstall = ''
    installManPage src/picker/docs/rofimoji.1
  '';

  pyproject = true;

  meta = {
    description = "Simple emoji and character picker for rofi";
    homepage = "https://github.com/fdw/rofimoji";
    changelog = "https://github.com/fdw/rofimoji/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ justinlovinger ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "rofimoji";
  };
})
