{
  description = "A Nix-flake-based Elixir development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

  outputs = inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: inputs.nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.self.overlays.default ];
        };
      });
    in
    {
      overlays.default = final: prev: rec {
        erlang = final.beam.interpreters.erlang_27;
        pkgs-beam = final.beam.packagesWith erlang;
        elixir = pkgs-beam.elixir_1_18;
      };

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            elixir
            elixir-ls
            git
            nodejs_20
          ]
          ++
          # Linux only
          pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
            gigalixir
            inotify-tools
            libnotify
            watchman
          ])
          ++
          # macOS only
          pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            terminal-notifier
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.CoreServices
          ]);
        };
      });
    };
}
