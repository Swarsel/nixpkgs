{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  installShellFiles,
  miniupnpc,
  openssl,
  zlib,
  upnpSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "i2pd";
  version = "2.60.0";

  src = fetchFromGitHub {
    owner = "PurpleI2P";
    repo = "i2pd";
    tag = finalAttrs.version;
    hash = "sha256-oVC31GpygznXbmjQ3qv3XZ58jZ9l6ibBoueuBM5Hk0M=";
  };

  postPatch = lib.optionalString (!stdenv.hostPlatform.isx86) ''
    substituteInPlace Makefile.osx \
      --replace-fail "-msse" ""
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    boost
    zlib
    openssl
  ]
  ++ lib.optional upnpSupport miniupnpc;

  makeFlags = [
    "USE_UPNP=${lib.boolToYesNo upnpSupport}"
  ];

  installPhase = ''
    install -D i2pd $out/bin/i2pd
    install --mode=444 -D 'contrib/i2pd.service' "$out/etc/systemd/system/i2pd.service"
    installManPage 'debian/i2pd.1'
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Minimal I2P router written in C++";
    homepage = "https://i2pd.website";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ edwtjo ];
    platforms = lib.platforms.unix;
    mainProgram = "i2pd";
  };
})
