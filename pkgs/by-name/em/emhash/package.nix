{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "emhash";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ktprime";
    repo = "emhash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+oJIJvtphPHXPbmRquHRV9KkI61qwuGjJw3O1hpzwIw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    # By default, it will try to build the benchmark suite,
    # but we only care about the headers copied by the install target.
    "-DWITH_BENCHMARKS=Off"
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast and memory efficient c++ flat hash map/set";
    homepage = "https://github.com/ktprime/emhash";
    changelog = "https://github.com/ktprime/emhash/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kilyanni ];
    platforms = lib.platforms.all;
  };
})
