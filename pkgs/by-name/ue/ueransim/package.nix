{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  iproute2,
  lksctp-tools,
  makeWrapper,
  nix-update-script,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ueransim";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "aligungr";
    repo = "ueransim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lTo/XYkRddyNdOpNO7MIAwq5mKMHDarCVzXjDomeXec=";
  };

  postPatch = ''
    substituteInPlace tools/nr-binder \
      --replace-fail "./libdevbnd.so" "$out/lib/libdevbnd.so"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [ lksctp-tools ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}

    chmod +x ../tools/nr-binder
    cp ../tools/nr-binder $out/bin

    for app in nr-gnb nr-ue nr-cli; do
      cp $app $out/bin
      wrapProgram "$out/bin/$app" \
        --prefix PATH : ${lib.makeBinPath [ iproute2 ]}
    done

    cp libdevbnd.so $out/lib

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open source 5G UE and RAN (gNodeB) implementation";
    homepage = "https://github.com/aligungr/UERANSIM";
    changelog = "https://github.com/aligungr/UERANSIM/releases";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ theobori ];
    platforms = lib.platforms.linux;
  };
})
