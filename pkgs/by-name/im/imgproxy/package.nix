{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gobject-introspection,
  libunwind,
  pkg-config,
  vips,
}:

buildGoModule (finalAttrs: {
  pname = "imgproxy";
  version = "3.31.3";

  src = fetchFromGitHub {
    owner = "imgproxy";
    repo = "imgproxy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sfxHtg6vpMuUeMA8/mh+x6Mrn3tzGYBsggAS6IhTpKo=";
  };

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
  ];

  buildInputs = [ vips ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libunwind ];
  vendorHash = "sha256-coHlsBh+ujEU9D/RloONAl+TDaxEJMdvvaNEuWe4SP8=";

  preBuild = ''
    export CGO_LDFLAGS_ALLOW='-(s|w)'
  '';

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Fast and secure on-the-fly image processing server written in Go";
    homepage = "https://imgproxy.net";
    changelog = "https://github.com/imgproxy/imgproxy/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ paluh ];
    mainProgram = "imgproxy";
  };
})
