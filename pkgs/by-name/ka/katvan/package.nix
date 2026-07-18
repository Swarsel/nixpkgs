{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  # nativeBuildInputs
  cmake,
  corrosion,
  # checkInputs
  gtest,
  hunspell,
  libarchive,
  pkg-config,
  python3,
  # buildInputs
  qt6,
  rustPlatform,
  rustc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "katvan";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "IgKh";
    repo = "katvan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WyPiRj/5So/1vjAytnXoldwYMG++tuLl0B0v31BeJxY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    qt6.qttools
    rustPlatform.cargoSetupHook
    rustc
    cargo
    (python3.withPackages (ps: [
      ps.mistletoe
    ]))
  ];

  buildInputs = [
    qt6.qtbase
    libarchive
    corrosion
    hunspell
  ];

  cmakeFlags = [
    # Don't set this to an absolute path, as it breaks upstream rpath settings
    # for the final executable, see: https://github.com/IgKh/katvan/issues/46
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
  ];

  doCheck = true;

  checkInputs = [
    gtest
  ];

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      cargoRoot
      ;

    hash = "sha256-p5cMFCuDy17uMoy99R8l+e6iQcbNXSavFj0sBRRsMwo=";
  };

  cargoRoot = "typstdriver/rust";

  # The CMakeLists files used by upstream issue a `cargo install` command to
  # install a rust tool (cxxbridge-cmd) that is supposed to be included in the Cargo.toml's and
  # `Cargo.lock` files of upstream. Setting CARGO_HOME like that helps `cargo
  # install` find the dependencies we prefetched. See also:
  # https://github.com/GothenburgBitFactory/taskwarrior/issues/3705
  postUnpack = ''
    export CARGO_HOME=$PWD/.cargo
  '';

  meta = {
    description = "bare-bones editor for Typst files, with a bias for Right-to-Left editing";
    homepage = "https://github.com/IgKh/katvan";
    changelog = "https://github.com/IgKh/katvan/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.all;
    mainProgram = "katvan";
  };
})
