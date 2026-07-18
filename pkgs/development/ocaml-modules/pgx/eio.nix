{
  alcotest,
  base64,
  buildDunePackage,
  eio,
  eio_main,
  pgx,
}:

buildDunePackage (finalAttrs: {
  inherit (pgx) version src;
  pname = "pgx_eio";

  propagatedBuildInputs = [
    eio
    pgx
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    base64
    eio_main
  ];

  meta = pgx.meta // {
    description = "Pgx using Eio for IO";
  };
})
