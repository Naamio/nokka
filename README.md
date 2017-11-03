## Nokka

Swift wrapper for the Rust Naamio SDK.

### Building

Swift Package Manager has some trouble with system modules, so we rely on `swiftc` for now.

 - `cd` into `merileva` and run `cargo build` to build the static Rust library.
 - Then, `cd` into `nokka` and run `swiftc NaamioClient.swift -I ./Merileva/ -Xlinker -L/path/to/merileva/target/[debug|release]/` to create the executable (linked to the library).
