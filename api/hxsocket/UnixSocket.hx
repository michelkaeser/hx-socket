package hxsocket;

import hxsocket.Loader;
import hxsocket.Sfd;
import hxsocket.SocketException;
import hxstd.IllegalStateException;

/**
 *
 */
class UnixSocket
{
    /**
     * References to native function implementations loaded through Haxe (hxcpp) C FFI.
     */
    private static var _connect_unix_dgram_socket:Sfd->String->Int = Loader.load("hx_connect_unix_dgram_socket", 2);
    private static var _destroy_unix_socket:Sfd->Int               = Loader.load("hx_destroy_unix_socket", 1);
    private static var _shutdown_unix_stream_socket:Sfd->Int->Int  = Loader.load("hx_shutdown_unix_stream_socket", 2);

    /**
     * Stores the socket file descriptor reference.
     *
     * @var hxsocket.Sfd
     */
    private var sfd:Null<Sfd>;


    /**
     *
     */
    public function connect(path:String):Void
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            UnixSocket._connect_unix_dgram_socket(this.sfd, path) /* == 0 */;
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     *
     */
    public function destroy():Void
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            UnixSocket._destroy_unix_socket(this.sfd) /* == 0 */;
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     *
     */
    public function shutdown(method:Int):Void
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            UnixSocket._shutdown_unix_stream_socket(this.sfd, method) /* == 0 */;
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }
}
