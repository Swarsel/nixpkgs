{
  lib,
  fetchFromGitHub,
  buildGoModule,
  geoip,
  pkg-config,
  versionCheckHook,
  zlib,
}:

buildGoModule (finalAttrs: {
  pname = "mirrorbits";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "videolabs";
    repo = "mirrorbits";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PqPE/PgIyQylbYoABC/saxLF83XjgRAS0QimragJ8P8=";
  };

  postPatch = ''
    rm -rf vendor
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    zlib
    geoip
  ];

  vendorHash = "sha256-cdD9RvOtgN/SHtgrtrucnUI+nnO/FabUyPRdvgoL44o=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/etix/mirrorbits/core.VERSION=${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Geographical download redirector for distributing files efficiently across a set of mirrors";

    longDescription = ''
      Mirrorbits is a geographical download redirector written in Go for
      distributing files efficiently across a set of mirrors. It offers
      a simple and economic way to create a Content Delivery Network
      layer using a pure software stack. It is primarily designed for
      the distribution of large-scale Open-Source projects with a lot
      of traffic.
    '';

    homepage = "https://github.com/videolabs/mirrorbits";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fpletz ];
    mainProgram = "mirrorbits";
  };
})
