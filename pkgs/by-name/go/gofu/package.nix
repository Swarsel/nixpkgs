{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gofu";
  version = "2026.2";

  src = fetchFromGitHub {
    owner = "majewsky";
    repo = "gofu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4ssDfWsV1/3iQ7beR+kyqsN+rMe6cxda4OB6f8KkWVY=";
  };

  vendorHash = null;

  postInstall = ''
    ln -s $out/bin/gofu $out/bin/rtree
    ln -s $out/bin/gofu $out/bin/prettyprompt
  '';

  subPackages = [ "." ];

  meta = {
    description = "Multibinary containing several utilities";
    homepage = "https://github.com/majewsky/gofu";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
