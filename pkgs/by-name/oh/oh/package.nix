{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "oh";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "michaelmacinnis";
    repo = "oh";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ryIh6MRIOVZPm2USpJC69Z/upIXGUHgcd17eZBA9Edc=";
  };

  vendorHash = "sha256-Qma5Vk0JO/tTrZanvTCE40LmjeCfBup3U3N7gyhfp44=";

  passthru = {
    shellPath = "/bin/oh";
  };

  meta = {
    description = "New Unix shell";
    homepage = "https://github.com/michaelmacinnis/oh";
    license = lib.licenses.mit;
    mainProgram = "oh";
  };
})
