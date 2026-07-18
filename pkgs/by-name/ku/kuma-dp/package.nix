{
  kuma,
  ...
}@args:

kuma.override (
  {
    pname = "kuma-dp";
    components = [ "kuma-dp" ];
    isFull = false;
  }
  // removeAttrs args [ "kuma" ]
)
