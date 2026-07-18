{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  meson,
  ninja,
  pkg-config,
  test-drive,
  toml-f,
  buildType ? "meson",
}:

assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);

stdenv.mkDerivation (finalAttrs: {
  pname = "jonquil";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "toml-f";
    repo = "jonquil";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eu5+cVvIF8AXye8zrcfaHoQzd+7bx6q9KtFuH5w2sFc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix wrong generation of package config include paths
    ./cmake.patch
  ];

  nativeBuildInputs = [
    gfortran
    pkg-config
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optional (buildType == "cmake") cmake;

  buildInputs = [
    test-drive
  ];

  propagatedBuildInputs = [
    toml-f
  ];

  meta = {
    description = "JSON parser on top of TOML implementation";
    homepage = "https://github.com/toml-f/jonquil";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
})
