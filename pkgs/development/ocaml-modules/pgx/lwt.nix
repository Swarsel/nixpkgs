{
  buildDunePackage,
  logs,
  lwt,
  pgx,
}:

buildDunePackage (finalAttrs: {
  inherit (pgx) version src;
  pname = "pgx_lwt";

  propagatedBuildInputs = [
    logs
    lwt
    pgx
  ];

  doCheck = true;

  meta = pgx.meta // {
    description = "Pgx using Lwt for IO";
  };
})
