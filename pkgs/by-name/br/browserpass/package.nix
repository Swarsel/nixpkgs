{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  browserpass,
  buildGoModule,
  gnupg,
  makeWrapper,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "browserpass";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "browserpass";
    repo = "browserpass-native";
    tag = finalAttrs.version;
    sha256 = "sha256-UZzOPRRiCUIG7uSSp9AEPMDN/+4cgyK47RhrI8oUx8U=";
  };

  postPatch = ''
    # Because this Makefile will be installed to be used by the user, patch
    # variables to be valid by default
    substituteInPlace Makefile \
      --replace "PREFIX ?= /usr" ""
    sed -i -e 's/SED =.*/SED = sed/' Makefile
    sed -i -e 's/INSTALL =.*/INSTALL = install/' Makefile
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  vendorHash = "sha256-CjuH4ANP2bJDeA+o+1j+obbtk5/NVLet/OFS3Rms4r0=";
  env.DESTDIR = placeholder "out";

  postConfigure = ''
    make configure
  '';

  buildPhase = ''
    make browserpass
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  installPhase = ''
    make install

    wrapProgram $out/bin/browserpass \
      --suffix PATH : ${lib.makeBinPath [ gnupg ]}

    # This path is used by our firefox wrapper for finding native messaging hosts
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    # Copy ff manifests rather than linking to allow link-farming to work recursively in dependants
    cp $out/lib/browserpass/hosts/firefox/*.json $out/lib/mozilla/native-messaging-hosts/
  '';

  checkTarget = "test";

  passthru.tests.version = testers.testVersion {
    command = "browserpass --version";
    package = browserpass;
  };

  meta = {
    description = "Browserpass native client app";
    homepage = "https://github.com/browserpass/browserpass-native";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ rvolosatovs ];
    mainProgram = "browserpass";
  };
})
