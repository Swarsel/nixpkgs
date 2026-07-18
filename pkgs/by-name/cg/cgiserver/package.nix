{
  lib,
  buildGoModule,
  fetchzip,
  zstd,
}:

buildGoModule (finalAttrs: {
  pname = "cgiserver";
  version = "1.0.0";

  src = fetchzip {
    url = "https://src.anomalous.eu/cgiserver/snapshot/cgiserver-${finalAttrs.version}.tar.zst";
    hash = "sha256-uIrOZbHzxAdUJF12MBOzRUA6mSPvOKJ/K9ZwwLVId5E=";
    nativeBuildInputs = [ zstd ];
  };

  vendorHash = "sha256-mygMtVbNWwtIkxTGxMnuAMUU0mp49NZ50B9d436nWgI=";

  meta = {
    description = "Lightweight web server for sandboxing CGI applications";
    homepage = "https://src.anomalous.eu/cgiserver/about/";
    license = lib.licenses.osl3;
    maintainers = with lib.maintainers; [ qyliss ];
    mainProgram = "cgiserver";
  };
})
