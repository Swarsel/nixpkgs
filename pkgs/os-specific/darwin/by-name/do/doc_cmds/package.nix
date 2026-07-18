{
  lib,
  mkAppleDerivation,
  pkg-config,
  shell_cmds,
  sourceRelease,
  stdenvNoCC,
  zlib,
}:

let
  xnu = sourceRelease "xnu";

  privateHeaders = stdenvNoCC.mkDerivation {
    buildCommand = ''
      install -D -m644 -t "$out/include/System/sys" \
        '${xnu}/bsd/sys/codesign.h'

      install -D -m644 -t "$out/include/kern" \
        '${xnu}/osfmk/kern/cs_blobs.h'
    '';

    name = "doc_cmds-deps-private-headers";
  };
in
mkAppleDerivation {
  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zlib ];
  env.NIX_CFLAGS_COMPILE = "-I${privateHeaders}/include";

  postInstall = ''
    HOST_PATH='${lib.getBin shell_cmds}/bin' patchShebangs --host "$out/libexec"
  '';

  releaseName = "doc_cmds";
  xcodeHash = "sha256-Nt6yHx3K8OkrdSWuX9s+JJIkeA5S6HDBAtTtrEjbk4w=";

  meta = {
    description = "makewhatis commands for Darwin";

    license = [
      lib.licenses.bsd2
      lib.licenses.bsd3
    ];
  };
}
