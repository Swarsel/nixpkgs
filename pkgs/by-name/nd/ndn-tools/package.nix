{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
  ndn-cxx,
  openssl,
  pkg-config,
  sphinx,
  wafHook,
  boost ? ndn-cxx.boost,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ndn-tools";
  version = "24.07";

  src = fetchFromGitHub {
    owner = "named-data";
    repo = "ndn-tools";
    rev = "ndn-tools-${finalAttrs.version}";
    sha256 = "sha256-rzGd+8SkztrkXRXcEcQm6rOtAGnF7h/Jg8jaBb7FP9w=";
  };

  nativeBuildInputs = [
    pkg-config
    sphinx
    wafHook
  ];

  buildInputs = [
    libpcap
    ndn-cxx
    openssl
  ];

  doCheck = false; # some tests fail because of the sandbox environment

  checkPhase = ''
    runHook preCheck
    build/unit-tests
    runHook postCheck
  '';

  wafConfigureFlags = [
    "--boost-includes=${boost.dev}/include"
    "--boost-libs=${boost.out}/lib"
    "--with-tests"
  ];

  meta = {
    description = "Named Data Networking (NDN) Essential Tools";
    homepage = "https://named-data.net/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bertof ];
    platforms = lib.platforms.unix;
  };
})
