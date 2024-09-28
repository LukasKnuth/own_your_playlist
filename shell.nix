{
  pkgs ? import <nixpkgs>{}
}: pkgs.mkShell {
  packages = with pkgs;
  [
    beam.packages.erlang_25.elixir_1_15
    elixir-ls
  ];
}
