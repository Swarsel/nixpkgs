{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  cmake,
  intel-compute-runtime,
  nix-update-script,
  openvino,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "level-zero";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "level-zero";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/3HVvivHKSwvrrFEU7LHP2H/6bHDBDyI1SVr/3A6Ie0=";
  };

  nativeBuildInputs = [
    cmake
    addDriverRunpath
  ];

  postFixup = ''
    addDriverRunpath $out/lib/libze_loader.so
  '';

  setupHook = ./setup-hook.sh;

  passthru = {
    tests = {
      inherit intel-compute-runtime openvino;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "oneAPI Level Zero Specification Headers and Loader";
    homepage = "https://github.com/oneapi-src/level-zero";
    changelog = "https://github.com/oneapi-src/level-zero/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ziguana ];
    platforms = lib.platforms.linux;
  };
})
