#include <stdint.h>
#include <stdlib.h>

// Opaque struct which mimics complex Swift/Rust structs.
struct Opaque;

// Create the Naamio client service.
struct Opaque *create_service(uint8_t threads);

// This can only be called once, and level can only be in 0..6
// (calling more than once, or invalid level has no effect)
void set_log_level(uint8_t level);

// Since it's allocated on the Rust side, it should be deallocated there.
void drop_service(struct Opaque *rust_service);

// C-style struct to represent a String or a slice
struct ByteArray {
    const uint8_t *bytes;
    size_t len;
};

// Has effect only if it's a valid URI (default: "http://localhost:8000")
void set_naamio_host(struct ByteArray addr);

// Foreign type owned by FFI realm (i.e., Swift classes).
// Rust will call the destructor once it's utilized.
struct ForeignObject {
    void *object;
    void (*destructor)(void *object);
};

/* Plugin registration */

struct RegisterRequest {
    struct ByteArray name;
    struct ByteArray rel_url;
    struct ByteArray endpoint;
};

void register_plugin(struct Opaque *rust_service,
                     struct RegisterRequest *req,
                     void (*callback)(struct ByteArray token));
