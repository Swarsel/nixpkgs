{
  lib,
  derivationWithMeta,
  hex0,
  platforms,
  src,
  stage0Arch,
  version,
}:
derivationWithMeta {
  inherit version;
  pname = "kaem-minimal";

  args = [
    "${src}/${stage0Arch}/kaem-minimal.hex0"
    (placeholder "out")
  ];

  builder = hex0;

  meta = {
    inherit platforms;
    description = "First stage minimal scriptable build tool for bootstrapping";
    homepage = "https://github.com/oriansj/stage0-posix";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.minimal-bootstrap ];
  };
}
