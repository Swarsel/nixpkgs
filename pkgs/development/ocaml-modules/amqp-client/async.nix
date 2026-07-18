{
  amqp-client,
  async,
  buildDunePackage,
  ezxmlm,
  uri,
}:

buildDunePackage {
  inherit (amqp-client) version src;
  pname = "amqp-client-async";

  buildInputs = [
    ezxmlm
  ];

  propagatedBuildInputs = [
    amqp-client
    async
    uri
  ];

  doCheck = true;

  meta = amqp-client.meta // {
    description = "Amqp client library, async version";
  };
}
