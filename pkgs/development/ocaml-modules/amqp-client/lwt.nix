{
  amqp-client,
  buildDunePackage,
  ezxmlm,
  lwt,
  lwt_log,
  uri,
}:
buildDunePackage {
  inherit (amqp-client) version src;
  pname = "amqp-client-lwt";
  buildInputs = [ ezxmlm ];

  propagatedBuildInputs = [
    lwt
    lwt_log
    amqp-client
    uri
  ];

  doCheck = true;

  meta = amqp-client.meta // {
    description = "Amqp client library, lwt version";
  };
}
