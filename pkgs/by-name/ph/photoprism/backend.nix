{
  lib,
  buildGoModule,
  coreutils,
  pkg-config,
  python3,
  src,
  symlinkJoin,
  version,
  vips,
}:

let
  # we need to copy these, to add the symlinks, so the linker actually finds these libraries
  libtensorflow = symlinkJoin {
    postBuild = ''
      ln -s "$out/libtensorflow_cc.so.2" "$out/libtensorflow.so"
      ln -s "$out/libtensorflow_framework.so.2" "$out/libtensorflow_framework.so"
    '';

    name = "libtensorflow";
    paths = [ "${python3.pkgs.tensorflow-bin}/${python3.sitePackages}/tensorflow" ];
  };
in
buildGoModule {
  inherit src version;
  pname = "photoprism-backend";

  postPatch = ''
    substituteInPlace internal/commands/passwd.go --replace-fail '/bin/stty' "${coreutils}/bin/stty"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    coreutils
    libtensorflow
    vips
  ];

  vendorHash = "sha256-nOytOKceVuRryixDxx791my0JkdLPfyYdK6dAUG4CQc=";
  # https://github.com/mattn/go-sqlite3/issues/822
  CGO_CFLAGS = "-Wno-return-local-addr -I${libtensorflow}/include";
  CGO_LDFLAGS = "-L${libtensorflow} -ltensorflow_framework";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  subPackages = [ "cmd/photoprism" ];

  meta = {
    description = "Photoprism's backend";
    homepage = "https://photoprism.app";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ benesim ];
  };
}
