{
  lib,
  stdenv,
  fetchFromGitHub,
  avahi,
  cmake,
  fetchpatch,
  soapysdr,
}:

let
  version = "0.5.2-unstable-2024-01-24";

in
stdenv.mkDerivation {
  inherit version;
  pname = "soapyremote";

  src = fetchFromGitHub {
    owner = "pothosware";
    repo = "SoapyRemote";
    rev = "54caa5b2af348906607c5516a112057650d0873d";
    sha256 = "sha256-uekElbcbX2P5TEufWEoP6tgUM/4vxgSQZu8qaBCSo18=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-kEx4gge+AQW/LSUyo+aWXlqDzXjoxCfn3pi2mk5xsNI=";
      url = "https://github.com/pothosware/SoapyRemote/commit/40c3ef9053b63885b7444ce7e9ef00d2c7964c9d.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    soapysdr
    avahi
  ];

  cmakeFlags = [ "-DSoapySDR_DIR=${soapysdr}/share/cmake/SoapySDR/" ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [ "-include sys/select.h" ]
  );

  meta = {
    description = "SoapySDR plugin for remote access to SDRs";
    homepage = "https://github.com/pothosware/SoapyRemote";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = lib.platforms.unix;
    mainProgram = "SoapySDRServer";
  };
}
