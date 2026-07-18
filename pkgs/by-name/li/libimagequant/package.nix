{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cargo-c,
  libimagequant,
  python3,
  rustPlatform,
  # tests
  testers,
  vips,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "libimagequant";
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "ImageOptim";
    repo = "libimagequant";
    rev = finalAttrs.version;
    hash = "sha256-A7idjAAJ+syqIahyU+LPZBF+MLxVDymY+M3HM7d/qk0=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ cargo-c ];

  cargoLock = {
    # created it by running `cargo update` in the source tree.
    lockFile = ./Cargo.lock;
  };

  postBuild = ''
    pushd imagequant-sys
    ${buildPackages.rust.envVars.setEnv} cargo cbuild --release --frozen --prefix=${placeholder "out"} --target ${stdenv.hostPlatform.rust.rustcTarget}
    popd
  '';

  postInstall = ''
    pushd imagequant-sys
    ${buildPackages.rust.envVars.setEnv} cargo cinstall --release --frozen --prefix=${placeholder "out"} --target ${stdenv.hostPlatform.rust.rustcTarget}
    popd
  '';

  passthru.tests = {
    inherit vips;
    inherit (python3.pkgs) pillow;

    pkg-config = testers.hasPkgConfigModules {
      moduleNames = [ "imagequant" ];
      package = libimagequant;
    };
  };

  meta = {
    description = "Image quantization library";
    longDescription = "Small, portable C library for high-quality conversion of RGBA images to 8-bit indexed-color (palette) images.";
    homepage = "https://pngquant.org/lib/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ma9e ];
    platforms = lib.platforms.unix;
  };
})
