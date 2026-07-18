{
  kuma,
  ...
}@args:

kuma.override (
  {
    pname = "kumactl";
    components = [ "kumactl" ];
    isFull = false;
  }
  // removeAttrs args [ "kuma" ]
)
