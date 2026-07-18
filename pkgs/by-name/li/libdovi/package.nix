{
  lib,
  stdenv,
  buildPackages,
  cargo-c,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "libdovi";
  version = "3.3.1";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-ecd+r0JWZtP/rxt4Y3Cj2TkygXIMy5KZhZpXBwJNPx4=";
    pname = "dolby_vision";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ cargo-c ];
  cargoLock.lockFile = ./Cargo.lock;

  buildPhase = ''
    runHook preBuild
    ${buildPackages.rust.envVars.setEnv} cargo cbuild -j $NIX_BUILD_CORES --release --frozen --prefix=${placeholder "out"} --target ${stdenv.hostPlatform.rust.rustcTarget}
    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck
    ${buildPackages.rust.envVars.setEnv} cargo ctest -j $NIX_BUILD_CORES --release --frozen --prefix=${placeholder "out"} --target ${stdenv.hostPlatform.rust.rustcTarget}
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    ${buildPackages.rust.envVars.setEnv} cargo cinstall -j $NIX_BUILD_CORES --release --frozen --prefix=${placeholder "out"} --target ${stdenv.hostPlatform.rust.rustcTarget}
    runHook postInstall
  '';

  meta = {
    description = "C library for Dolby Vision metadata parsing and writing";
    homepage = "https://crates.io/crates/dolby_vision";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
