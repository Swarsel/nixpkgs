{
  kuma,
  ...
}@args:

kuma.override (
  {
    pname = "kuma-experimental";
    enableGateway = true;
    isFull = true;

  }
  // removeAttrs args [ "kuma" ]
)
