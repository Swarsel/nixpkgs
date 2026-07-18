{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  libx11,
  pcsclite,
  testers,
}:

let
  version = "4.20.0";
  buildNum = "4284";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tlclient";
  version = "${version}-${buildNum}";

  src = fetchurl {
    url = "https://www.cendio.com/downloads/clients/tl-${finalAttrs.version}-client-linux-dynamic-x86_64.tar.gz";
    hash = "sha256-iq1OUFyMZwYWqEI57zSwj1RDh5OZ8qNu8knpe6Hbdeo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    libx11
    pcsclite
  ];

  installPhase = ''
    runHook preInstall

    rm etc/ssh_known_hosts
    rm --recursive lib/tlclient/lib
    substituteInPlace lib/tlclient/share/applications/thinlinc-client.desktop \
      --replace-fail "/opt/thinlinc/bin/" ""
    cp --recursive . $out
    cp --recursive $out/lib/tlclient/share $out/share
    install -D --mode=0644 $out/lib/tlclient/EULA.txt $out/share/licenses/tlclient/EULA.txt
    install -D --mode=0644 $out/lib/tlclient/open_source_licenses.txt $out/share/licenses/tlclient/open_source_licenses.txt

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru.tests.version = testers.testVersion {
    version = "${version} build ${buildNum}";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Linux remote desktop client built on open source technology";
    homepage = "https://www.cendio.com/";
    changelog = "https://www.cendio.com/thinlinc/docs/relnotes/${version}/";

    license = {
      free = false;
      fullName = "Cendio end-user license agreement";
      url = "https://www.cendio.com/thinlinc/docs/legal/eula";
    };

    maintainers = with lib.maintainers; [
      felixalbrigtsen
      kyehn
    ];

    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "tlclient";
    broken = !(stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64);
  };
})
