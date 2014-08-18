package hxsocket;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxsocket.Loader;
import hxsocket.Sfd;
import hxsocket.SocketException;
import hxstd.IllegalArgumentException;
import hxstd.IllegalStateException;

/**
 *
 */
class UnixSocket
{
    /**
     * References to native function implementations loaded through Haxe (hxcpp) C FFI.
     */
    private static var _accept_unix_stream_socket:Sfd->Int->Sfd = Loader.load("hx_accept_unix_stream_socket", 2);
    private static var _connect_unix_dgram_socket:Sfd->String->Int = Loader.load("hx_connect_unix_dgram_socket", 2);
    private static var _create_unix_dgram_socket:String->Int->Sfd  = Loader.load("hx_create_unix_dgram_socket", 2);
    private static var _create_unix_server_socket:String->Int->Int->Sfd = Loader.load("hx_create_unix_server_socket", 3);
    private static var _create_unix_stream_socket:String->Int->Sfd = Loader.load("hx_create_unix_stream_socket", 2);
    private static var _destroy_unix_socket:Sfd->Int               = Loader.load("hx_destroy_unix_socket", 1);
    private static var _recvfrom_unix_dgram_socket:Sfd->Int->String->Int->BytesData = Loader.load("hx_recvfrom_unix_dgram_socket", 4);
    private static var _sendto_unix_dgram_socket:Sfd->BytesData->Int->String->Int->Int = Loader.load("hx_sendto_unix_dgram_socket", 5);
    private static var _shutdown_unix_stream_socket:Sfd->Int->Int  = Loader.load("hx_shutdown_unix_stream_socket", 2);

    /**
     * Possible UnixSocket server modes.
     */
    public static inline var STREAM:Int = 1;
    public static inline var DGRAM:Int  = 2;

    /**
     * Stores the socket file descriptor reference.
     *
     * @var hxsocket.Sfd
     */
    private var sfd:Null<Sfd>;

    /**
     * Stores the path on which the socket was created.
     *
     * @var String
     */
    public var path(default, null):Null<String>;


    /**
     * Constructor to initialize a new Unixsocket instance.
     *
     * @param hxsocket.Sfd sfd  the socket file descriptor to wrap
     * @param String       path the path on which the socket listens
     */
    private function new(sfd:Sfd, ?path:String):Void
    {
        this.sfd  = sfd;
        this.path = path;
    }

    /**
     *
     */
    public function accept(flags:Int):UnixSocket
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            return new UnixSocket(UnixSocket._accept_unix_stream_socket(this.sfd, flags));
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

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
    public static function createDgramSocket(path:String, flags:Int):UnixSocket
    {
        try {
            return new UnixSocket(UnixSocket._create_unix_dgram_socket(path, flags), path);
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     *
     */
    public static function createServerSocket(path:String, type:Int, flags:Int):UnixSocket
    {
        if (type != UnixSocket.STREAM && type != UnixSocket.DGRAM) {
            throw new IllegalArgumentException("Invalid socket type argument (must be UnixSocket.STREAM or UnixSocket.DGRAM)");
        }

        try {
            return new UnixSocket(UnixSocket._create_unix_server_socket(path, type, flags), path);
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     *
     */
    public static function createStreamSocket(path:String, flags:Int):UnixSocket
    {
        try {
            return new UnixSocket(UnixSocket._create_unix_stream_socket(path, flags), path);
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
            this.sfd  = null;
            this.path = null;
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     *
     */
    public function read(nbytes:Int, flags:Int, from:Null<String> = null):Bytes
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        var read:Bytes;
        if (nbytes == 0) {
            read = Bytes.alloc(0);
        } else {
            if (from == null) {
                from = this.path;
            }

            try {
                read = Bytes.ofData(UnixSocket._recvfrom_unix_dgram_socket(this.sfd, nbytes, from, flags));
            } catch (ex:Dynamic) {
                throw new SocketException(ex);
            }
        }

        return read;
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

    /**
     *
     */
    public function write(bytes:Null<Bytes>, flags:Int, path:Null<String> = null):Int
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        var sent:Int;
        if (bytes == null || bytes.length == 0) {
            sent = 0;
        } else {
            if (path == null) {
                path = this.path;
            }

            try {
                sent = UnixSocket._sendto_unix_dgram_socket(this.sfd, bytes.getData(), bytes.length, path, flags) /* == 0 */;
            } catch (ex:Dynamic) {
                throw new SocketException(ex);
            }
        }

        return sent;
    }
}
