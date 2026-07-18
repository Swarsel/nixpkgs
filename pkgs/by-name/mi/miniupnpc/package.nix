{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  nixosTests,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "miniupnpc";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = "miniupnp";
    repo = "miniupnp";
    tag = "miniupnpc_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-8EWchUppW4H2kEUCGBXIk1meARJj2usKKO5gFYPoW3s=";
  };

  patches = [
    # fix missing include
    # remove on next release
    (fetchpatch {
      hash = "sha256-PHqjruFOcsGT3rdFS/GD3wEvalCmoRY4BtIKFxCjKDw=";
      stripLen = 1;
      url = "https://github.com/miniupnp/miniupnp/commit/e263ab6f56c382e10fed31347ec68095d691a0e8.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "UPNPC_BUILD_SHARED" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "UPNPC_BUILD_STATIC" stdenv.hostPlatform.isStatic)
  ];

  doCheck = !stdenv.hostPlatform.isFreeBSD;

  postInstall = ''
    mv $out/bin/upnpc-* $out/bin/upnpc
    mv $out/bin/upnp-listdevices-* $out/bin/upnp-listdevices
    mv $out/bin/external-ip.sh $out/bin/external-ip
    chmod +x $out/bin/external-ip
    patchShebangs $out/bin/external-ip
    substituteInPlace $out/bin/external-ip \
      --replace-fail "upnpc" $out/bin/upnpc
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  sourceRoot = "${finalAttrs.src.name}/miniupnpc";
  versionCheckProgram = "${placeholder "out"}/bin/upnpc";

  passthru.tests = {
    inherit (nixosTests) upnp;
  };

  meta = {
    description = "Client that implements the UPnP Internet Gateway Device (IGD) specification";
    homepage = "https://miniupnp.tuxfamily.org/";
    license = lib.licenses.bsd3;
    platforms = with lib.platforms; linux ++ freebsd ++ darwin;
    mainProgram = "upnpc";
  };
})
