{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cargo,
  darwin,
  libepoxy,
  libkrun-efi,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "krunkit";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "libkrun";
    repo = "krunkit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aC/p+MoCG05hyADZaz+bbONLXTcR7uJIcMrZOn4Rjbg=";
  };

  nativeBuildInputs = [
    cargo
    darwin.sigtool
    pkg-config
    rustc
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    libepoxy
    libkrun-efi
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    install -Dm444 edk2/KRUN_EFI.silent.fd $out/share/krunkit/KRUN_EFI.silent.fd
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-ptMqyCiIJsQfjFyislyc3pR0BGpwnu8Ba3OcQYLJPtM=";
  };

  # This is necessary in order for the binary to keep its entitlements
  dontStrip = true;

  passthru = {
    tests.boot = lib.optional stdenv.isDarwin (
      callPackage ./boot-test.nix { krunkit = finalAttrs.finalPackage; }
    );

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Launch configurable virtual machines with libkrun";
    homepage = "https://github.com/libkrun/krunkit";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ quinneden ];
    platforms = [ "aarch64-darwin" ];
  };
})
