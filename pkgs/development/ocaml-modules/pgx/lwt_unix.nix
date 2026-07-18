{
  alcotest-lwt,
  base64,
  buildDunePackage,
  pgx,
  pgx_lwt,
}:

buildDunePackage (finalAttrs: {
  inherit (pgx) version src;
  pname = "pgx_lwt_unix";
  propagatedBuildInputs = [ pgx_lwt ];
  doCheck = true;

  checkInputs = [
    alcotest-lwt
    base64
  ];

  meta = pgx.meta // {
    description = "Pgx using Lwt and Unix libraries for IO";
  };
})
