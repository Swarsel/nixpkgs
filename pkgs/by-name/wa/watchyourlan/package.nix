{
  lib,
  fetchFromGitHub,
  arp-scan,
  buildGoModule,
  makeBinaryWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "watchyourlan";
  version = "2.1.4";

  src = fetchFromGitHub {
    owner = "aceberg";
    repo = "WatchYourLAN";
    tag = finalAttrs.version;
    hash = "sha256-bSjigrnZH4dztx0Ho4w7Mmi20eVysWwYKGT1hsxSAZg=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  vendorHash = "sha256-ywNi0BIGU40kqWa2q3QqR/LCohdlmUThCrdVQhD1wGU=";

  postFixup = ''
    wrapProgram $out/bin/WatchYourLAN \
      --prefix PATH : '${lib.makeBinPath [ arp-scan ]}'
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  sourceRoot = "${finalAttrs.src.name}/backend";

  meta = {
    description = "Lightweight network IP scanner with web GUI";
    homepage = "https://github.com/aceberg/WatchYourLAN";
    changelog = "https://github.com/aceberg/WatchYourLAN/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.iv-nn ];
    mainProgram = "WatchYourLAN";
  };
})
