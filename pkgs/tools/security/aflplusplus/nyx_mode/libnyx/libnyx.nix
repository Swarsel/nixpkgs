{
  lib,
  stdenv,
  aflplusplus,
  python3,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "libnyx";
  version = builtins.readFile (aflplusplus.src + "/nyx_mode/LIBNYX_VERSION");
  src = aflplusplus.src;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp "target/${stdenv.hostPlatform.rust.rustcTarget}/release/liblibnyx.so" $out/lib/libnyx.so
    runHook postInstall
  '';

  postUnpack = ''
    sourceRoot="$sourceRoot/nyx_mode/libnyx/libnyx"
    cp ${./Cargo.lock} "$sourceRoot/Cargo.lock"
  '';

  meta = {
    description = "Rust library to build hypervisor-based snapshot fuzzers";
    homepage = "https://github.com/nyx-fuzz/libnyx";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ekzyis ];
    platforms = lib.platforms.linux;
  };
}
