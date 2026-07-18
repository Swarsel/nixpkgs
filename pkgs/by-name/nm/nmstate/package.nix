{
  lib,
  fetchurl,
  fetchFromGitHub,
  libfaketime,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nmstate";
  version = "2.2.57";

  postPatch = ''
    substituteInPlace packaging/nmstate.service --replace-fail /usr/bin $out/bin
  '';

  nativeBuildInputs = [
    libfaketime
  ];

  postInstall = ''
    ln -s ../target rust/target
    source_date=$(date --utc --date=@$SOURCE_DATE_EPOCH "+%F %T")
    PREFIX=$out LIBDIR=$out/lib RELEASE=1 SKIP_PYTHON_INSTALL=1 faketime -f "$source_date" make install
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "rust";
  cargoVendorDir = "vendor";

  postUnpack = ''
    mv vendor source/rust/
    cd source
  '';

  sourceRoot = ".";

  srcs = [
    (fetchFromGitHub {
      hash = "sha256-7X51XmoSwlIrbsdJFfTQ23bhO3bitkHXOObL6JaGpvI=";
      owner = "nmstate";
      repo = "nmstate";
      tag = "v${finalAttrs.version}";
    })
    (fetchurl {
      hash = "sha256-stOHNezPLPjSrt/f3HmhqWMxSaSfOh/hYVGB2+l8Pb4=";
      url = "https://github.com/nmstate/nmstate/releases/download/v${finalAttrs.version}/nmstate-vendor-${finalAttrs.version}.tar.xz";
    })
  ];

  meta = {
    description = "Nmstate: A Declarative Network API";
    homepage = "https://nmstate.io/";
    changelog = "https://github.com/nmstate/nmstate/blob/v${finalAttrs.version}/CHANGELOG";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      iwanb
    ];

    platforms = with lib.platforms; unix;
    mainProgram = "nmstatectl";
  };
})
