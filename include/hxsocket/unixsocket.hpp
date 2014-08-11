#ifndef __HX_SOCKET_UNIXSOCKET_HPP
#define __HX_SOCKET_UNIXSOCKET_HPP

#ifdef __cplusplus
extern "C" {
#endif

DECLARE_KIND(k_unixsocket);


#define alloc_unixsocket(v)      alloc_abstract(k_unixsocket, v)
#define malloc_unixsocket()      ((int*)alloc_private(sizeof(int)))
#define val_check_unixsocket(v)  val_check_kind(v, k_unixsocket)
#define val_is_unixsocket(v)     val_is_kind(v, k_unixsocket)
#define val_unixsocket(v)        ((int*)val_data(v))


/*
 *
 */
void finalize_unixsocket_abstract(value socket);


/*
 *
 */
value hx_accept_unix_stream_socket(value socket, value flags);


/*
 *
 */
value hx_connect_unix_dgram_socket(value socket, value path);


/*
 *
 */
value hx_create_unix_dgram_socket(value path, value flags);


/*
 *
 */
value hx_create_unix_server_socket(value path, value type, value flags);


/*
 *
 */
value hx_create_unix_stream_socket(value path, value flags);


/*
 *
 */
value hx_destroy_unix_socket(value socket);


/*
 *
 */
value hx_recvfrom_unix_dgram_socket(value socket, value nbytes, value from, value flags);


/*
 *
 */
value hx_sendto_unix_dgram_socket(value socket, value buffer, value size, value path, value flags);


/*
 *
 */
value hx_shutdown_unix_stream_socket(value socket, value method);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* __HX_SOCKET_UNIXSOCKET_HPP */
