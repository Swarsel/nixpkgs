{
  lib,
  stdenv,
  fetchFromGitHub,
  net-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hans";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "friedrich";
    repo = "hans";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-r6IDs8Seys94LBNnedcfVX5aW8x//ZN0Yh/DGTg8niA=";
  };

  postPatch = ''
    substituteInPlace src/tun.cpp --replace "/sbin/" "${net-tools}/bin/"
  '';

  buildInputs = [ net-tools ];

  installPhase = ''
    install -D -m0755 hans $out/bin/hans
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Tunnel IPv4 over ICMP";

    longDescription = ''
      Hans makes it possible to tunnel IPv4 through ICMP echo packets, so you
      could call it a ping tunnel. This can be useful when you find yourself in
      the situation that your Internet access is firewalled, but pings are
      allowed.
    '';

    homepage = "https://code.gerade.org/hans/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "hans";
  };
})
