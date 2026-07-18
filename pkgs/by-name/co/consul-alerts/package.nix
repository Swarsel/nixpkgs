{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "consul-alerts";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "AcalephStorage";
    repo = "consul-alerts";
    rev = "v${finalAttrs.version}";
    sha256 = "0836zicv76sd6ljhbbii1mrzh65pch10w3gfa128iynaviksbgn5";
  };

  postPatch = ''
    go mod init github.com/AcalephStorage/consul-alerts
  '';

  vendorHash = null;
  doCheck = false;

  meta = {
    description = "Highly available daemon for sending notifications and reminders based on Consul health checks";
    homepage = "https://github.com/AcalephStorage/consul-alerts";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ nh2 ];
    # As per README
    platforms = lib.platforms.linux ++ lib.platforms.freebsd ++ lib.platforms.darwin;
    mainProgram = "consul-alerts";
  };
})
