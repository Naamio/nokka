## Nokka

Swift wrapper for the Rust Naamio SDK.

### Building

 - `cd` into `merileva` and run `cargo build` (debug or release) to build the static Rust library.
 - Then, `cd` into `nokka` and run `swift build -Xlinker -L/path/to/merileva/target/[debug|release]/` to create the executable (linked to the library).
