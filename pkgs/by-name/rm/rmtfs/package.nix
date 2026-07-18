{
  lib,
  stdenv,
  fetchFromGitHub,
  qmic,
  qrtr,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rmtfs";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "rmtfs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ehd8SbKNOpyVoF9oc7e5uYmJOHI+Q6woLyvwO8hhKEc=";
  };

  buildInputs = [
    udev
    qrtr
    qmic
  ];

  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Qualcomm Remote Filesystem Service";
    homepage = "https://github.com/linux-msm/rmtfs";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.aarch64;
    mainProgram = "rmtfs";
  };
})
