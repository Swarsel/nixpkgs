{
  lib,
  fetchFromGitHub,
  python3Packages,
  stdenvNoCC,
  yq,
}:
let
  inherit (python3Packages) mkdocs mkdocs-material pymdown-extensions;
in
stdenvNoCC.mkDerivation {
  pname = "payloadsallthethings";
  version = "2025.1";

  src = fetchFromGitHub {
    owner = "swisskyrepo";
    repo = "PayloadsAllTheThings";
    tag = "4.2";
    hash = "sha256-LBPlGfmIyzgRhUdAJmPxjDB7D8iRHcSA8Tf5teMnFzA=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [ ./mkdocs.patch ];

  nativeBuildInputs = [
    mkdocs
    mkdocs-material
    pymdown-extensions

    yq
  ];

  buildPhase = ''
    yq -yi '.docs_dir = "source"' mkdocs.yml
    mkdir overrides
    mv mkdocs.yml ..
    cd ..
    mkdocs build --theme material
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $doc/share/payloadsallthethings
    cp -r site/* $doc/share/payloadsallthethings

    mkdir -p $out/share/payloadsallthethings
    rm source/CONTRIBUTING.md source/custom.css
    cp -r source/* $out/share/payloadsallthethings
    runHook postInstall
  '';

  meta = {
    description = "List of useful payloads and bypass for Web Application Security and Pentest/CTF";
    homepage = "https://github.com/swisskyrepo/PayloadsAllTheThings";
    license = with lib.licenses; [ mit ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      shard7
      felbinger
    ];

    platforms = lib.platforms.all;
  };
}
