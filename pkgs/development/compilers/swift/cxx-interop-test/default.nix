{
  lib,
  stdenv,
  swift,
  swiftPackages,
  swiftpm,
}:

swiftPackages.stdenv.mkDerivation (finalAttrs: {
  src = ./src;

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  env = {
    # Gross hack copied from `protoc-gen-swift` :(
    LD_LIBRARY_PATH = lib.optionalString stdenv.hostPlatform.isLinux (
      lib.makeLibraryPath [
        swiftPackages.Dispatch
      ]
    );
  };

  installPhase = ''
    runHook preInstall

    binPath="$(swiftpmBinPath)"
    mkdir -p -- "$out/bin"
    cp -- "$binPath/${finalAttrs.meta.mainProgram}" "$out/bin"

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/${finalAttrs.meta.mainProgram}" | grep 'Hello, world!'

    runHook postInstallCheck
  '';

  name = "swift-cxx-interop-test";

  meta = {
    inherit (swift.meta)
      team
      platforms
      badPlatforms
      ;

    license = lib.licenses.mit;
    mainProgram = "CxxInteropTest";
  };
})
