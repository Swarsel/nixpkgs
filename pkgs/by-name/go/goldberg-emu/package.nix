{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  protobuf_21,
}:
let
  protobuf = protobuf_21;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "goldberg-emu";
  version = "0.2.5";

  src = fetchFromGitLab {
    owner = "mr_goldberg";
    repo = "goldberg_emulator";
    tag = finalAttrs.version;
    hash = "sha256-goOgMNjtDmIKOAv9sZwnPOY0WqTN90LFJ5iEp3Vkzog=";
  };

  # It attempts to install windows-only libraries which we never build
  patches = [ ./dont-install-unsupported.patch ];

  postPatch = ''
    # Fix gcc-13 build failure due to missing <string> include.
    sed -e '1i #include <string>' -i dll/settings.h
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ protobuf ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}/share/goldberg"
  ];

  preFixup = ''
    mkdir -p $out/{bin,lib}
    chmod +x $out/share/goldberg/tools/find_interfaces.sh

    ln -s $out/share/goldberg/libsteam_api.so $out/lib
    ln -s $out/share/goldberg/lobby_connect/lobby_connect $out/bin
    ln -s $out/share/goldberg/tools/generate_interfaces_file $out/bin
    ln -s $out/share/goldberg/tools/find_interfaces.sh $out/bin/find_interfaces
  '';

  meta = {
    description = "Program that emulates steam online features";

    longDescription = ''
      Steam emulator that emulates steam online features. Lets you play games that
      use the steam multiplayer apis on a LAN without steam or an internet connection.
    '';

    homepage = "https://gitlab.com/Mr_Goldberg/goldberg_emulator";
    changelog = "https://gitlab.com/Mr_Goldberg/goldberg_emulator/-/releases";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "lobby_connect";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
