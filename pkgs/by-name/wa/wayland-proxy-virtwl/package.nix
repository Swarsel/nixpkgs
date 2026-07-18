{
  lib,
  fetchFromGitHub,
  libdrm,
  ocamlPackages,
  pkg-config,
  unstableGitUpdater,
}:

ocamlPackages.buildDunePackage {
  pname = "wayland-proxy-virtwl";
  version = "0-unstable-2026-04-16";

  src = fetchFromGitHub {
    owner = "talex5";
    repo = "wayland-proxy-virtwl";
    rev = "60e759ca3e4e26444c4956fb85e24b7944d4d81a";
    sha256 = "sha256-cqBXINcJJ8yrNzvMHio+6+eO0PFGUWR+sZSvBDxxOvs=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libdrm
  ]
  ++ (with ocamlPackages; [
    dune-configurator
    eio_main
    ppx_cstruct
    wayland
    cmdliner_1
    logs
    ppx_cstruct
  ]);

  doCheck = true;
  minimalOCamlVersion = "5.0";
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Proxy Wayland connections across a VM boundary";
    homepage = "https://github.com/talex5/wayland-virtwl-proxy";
    license = lib.licenses.asl20;

    maintainers = [
      lib.maintainers.qyliss
      lib.maintainers.sternenseemann
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wayland-proxy-virtwl";
  };
}
