{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hcxdumptool";
  version = "7.1.2";

  src = fetchFromGitHub {
    owner = "ZerBea";
    repo = "hcxdumptool";
    tag = finalAttrs.version;
    hash = "sha256-dEmjzduVN5QhFRhj2bs2KTGH4e8DIiDSrs4vwznvkRA=";
  };

  buildInputs = [
    openssl
    libpcap
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Small tool to capture packets from wlan devices";
    homepage = "https://github.com/ZerBea/hcxdumptool";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danielfullmer ];
    platforms = lib.platforms.linux;
    mainProgram = "hcxdumptool";
  };
})
