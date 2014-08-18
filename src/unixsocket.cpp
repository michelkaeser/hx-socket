#define  IMPLEMENT_API
#define  NEKO_COMPATIBLE
#include <hx/CFFI.h>
#include <unistd.h>

#include "hxsocket/unixsocket.hpp"

extern "C" {

#include <libsocket/libunixsocket.h>


DEFINE_KIND(k_unixsocket);


void finalize_unixsocket_abstract(value socket)
{
    val_check_unixsocket(socket);

    if (socket != NULL) {
        int* sfd = val_unixsocket(socket);
        destroy_unix_socket(*sfd);
        socket = NULL;
    }
}


value hx_accept_unix_stream_socket(value socket, value flags)
{
    val_check_unixsocket(socket);
    val_check(flags, int);

    value val;
    int ret = accept_unix_stream_socket(*val_unixsocket(socket), val_int(flags));
    if (ret > 0) {
        int* sfd = malloc_unixsocket();
        *sfd     = ret;
        val      = alloc_unixsocket(sfd);
        val_gc(val, finalize_unixsocket_abstract);
    } else {
        val_throw(alloc_string("Accepting connections on the Unix stream socket failed"));
        val = alloc_int(ret);
    }

    return val;
}
DEFINE_PRIM(hx_accept_unix_stream_socket, 2);


value hx_connect_unix_dgram_socket(value socket, value path)
{
    val_check_unixsocket(socket);
    val_check(path, string);

    int ret = connect_unix_dgram_socket(*val_unixsocket(socket), val_string(path));
    if (ret != 0) {
        val_throw(alloc_string("Connecting to the Unix dgram socket failed"));
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_connect_unix_dgram_socket, 2);


value hx_create_unix_dgram_socket(value path, value flags)
{
    val_check(path, string);
    val_check(flags, int);

    value val;
    int ret = create_unix_dgram_socket(val_string(path), val_int(flags));
    if (ret > 0) {
        int* sfd = malloc_unixsocket();
        *sfd     = ret;
        val      = alloc_unixsocket(sfd);
        val_gc(val, finalize_unixsocket_abstract);
    } else {
        val_throw(alloc_string("Creating the Unix dgram socket failed"));
        val = alloc_int(ret);
    }

    return val;
}
DEFINE_PRIM(hx_create_unix_dgram_socket, 2);


value hx_create_unix_server_socket(value path, value type, value flags)
{
    val_check(path, string);
    val_check(type, int);
    val_check(flags, int);

    value val;
    int ret = create_unix_server_socket(val_string(path), val_int(type), val_int(flags));
    if (ret > 0) {
        int* sfd = malloc_unixsocket();
        *sfd     = ret;
        val      = alloc_unixsocket(sfd);
        val_gc(val, finalize_unixsocket_abstract);
    } else {
        val_throw(alloc_string("Creating the Unix server socket failed"));
        val = alloc_int(ret);
    }

    return val;
}
DEFINE_PRIM(hx_create_unix_server_socket, 3);


value hx_create_unix_stream_socket(value path, value flags)
{
    val_check(path, string);
    val_check(flags, int);

    value val;
    int ret = create_unix_stream_socket(val_string(path), val_int(flags));
    if (ret > 0) {
        int* sfd = malloc_unixsocket();
        *sfd     = ret;
        val      = alloc_unixsocket(sfd);
        val_gc(val, finalize_unixsocket_abstract);
    } else {
        val_throw(alloc_string("Creating the Unix stream socket failed"));
        val = alloc_int(ret);
    }

    return val;
}
DEFINE_PRIM(hx_create_unix_stream_socket, 2);


value hx_destroy_unix_socket(value socket)
{
    val_check_unixsocket(socket);

    int* sfd = val_unixsocket(socket);
    int ret  = destroy_unix_socket(*sfd);
    if (ret != 0) {
        val_throw(alloc_string("Destroying the Unix socket failed"));
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_destroy_unix_socket, 1);


value hx_recvfrom_unix_dgram_socket(value socket, value nbytes, value flags)
{
    val_check_unixsocket(socket);
    val_check(nbytes, int);
    val_check(flags, int);

    size_t size = val_int(nbytes);
    char inbuf[size];
    char frombuf[FROM_BUFFER_SIZE];

    value val;
    int ret = recvfrom_unix_dgram_socket(*val_unixsocket(socket), inbuf, size, frombuf, FROM_BUFFER_SIZE, val_int(flags));
    if (ret >= 0) {
        value obj  = alloc_empty_object();
        alloc_field(obj, val_id("from"), alloc_string(frombuf));
        buffer buf = alloc_buffer(NULL);
        buffer_append_sub(buf, inbuf, ret);
        alloc_field(obj, val_id("bytes"), buffer_val(buf));
        val = obj;
    } else {
        val_throw(alloc_string("Receiving from the Unix dgram socket failed"));
        val = alloc_int(ret);
    }

    return val;
}
DEFINE_PRIM(hx_recvfrom_unix_dgram_socket, 3);


value hx_recvfrom_unix_stream_socket(value socket, value nbytes)
{
    val_check_unixsocket(socket);
    val_check(nbytes, int);

    size_t size = val_int(nbytes);
    char inbuf[size];

    value val;
    int ret = read(*val_unixsocket(socket), inbuf, size);
    if (ret >= 0) {
        buffer buf = alloc_buffer(NULL);
        buffer_append_sub(buf, inbuf, ret);
        val = buffer_val(buf);
    } else {
        val_throw(alloc_string("Receiving from the Unix stream socket failed"));
        val = alloc_int(ret);
    }

    return val;
}
DEFINE_PRIM(hx_recvfrom_unix_stream_socket, 2);


value hx_sendto_unix_dgram_socket(value socket, value bytes, value size, value path, value flags)
{
    val_check_unixsocket(socket);
    val_check(size, int);
    val_check(path, string);
    val_check(flags, int);

    const char* data;
    if (val_is_string(bytes)) { // Neko
        data = val_string(bytes);
    } else { // C++
        buffer buf = val_to_buffer(bytes);
        data       = buffer_data(buf);
    }

    int ret = sendto_unix_dgram_socket(*val_unixsocket(socket), data, val_int(size), val_string(path), val_int(flags));
    if (ret < 0) {
        val_throw(alloc_string("Sending to the Unix dgram socket failed"));
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_sendto_unix_dgram_socket, 5);


value hx_sendto_unix_stream_socket(value socket, value bytes, value size)
{
    val_check_unixsocket(socket);
    val_check(size, int);

    const char* data;
    if (val_is_string(bytes)) { // Neko
        data = val_string(bytes);
    } else { // C++
        buffer buf = val_to_buffer(bytes);
        data       = buffer_data(buf);
    }

    int ret = write(*val_unixsocket(socket), data, val_int(size));
    if (ret < 0) {
        val_throw(alloc_string("Sending to the Unix stream socket failed"));
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_sendto_unix_stream_socket, 3);


value hx_shutdown_unix_stream_socket(value socket, value method)
{
    val_unixsocket(socket);
    val_check(method, int);

    int* sfd = val_unixsocket(socket);
    int ret  = shutdown_unix_stream_socket(*sfd, val_int(method));
    if (ret != 0) {
        val_throw(alloc_string("Shutting down the Unix stream socket failed"));
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_shutdown_unix_stream_socket, 2);

} // extern "C"
