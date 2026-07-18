{
  buildGoModule,
  pname,
  src,
  vendorHash,
  version,
}:

buildGoModule {
  inherit version src vendorHash;
  pname = "${pname}-server";

  patches = [
    ./0001-disable-etc-copy.patch
  ];

  doCheck = false; # requires a running PostgreSQL database

  ldflags = [
    "-s"
    "-w"
  ];
  # preCheck = ''
  #   set -o allexport
  #   source ./.test.env
  #   set +o allexport
  # '';
}
