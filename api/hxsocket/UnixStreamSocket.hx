package hxsocket;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxsocket.Loader;
import hxsocket.SocketException;
import hxsocket.UnixSocket;
import hxstd.IllegalArgumentException;
import hxstd.IllegalStateException;

/**
 *
 */
class UnixStreamSocket extends UnixSocket
{
    /**
     * References to native function implementations loaded through Haxe (hxcpp) C FFI.
     */
    private static var _accept:Sfd->Int->Sfd            = Loader.load("hx_accept_unix_stream_socket", 2);
    private static var _create:String->Int->Sfd         = Loader.load("hx_create_unix_stream_socket", 2);
    private static var _recvfrom:Sfd->Int->BytesData    = Loader.load("hx_recvfrom_unix_stream_socket", 2);
    private static var _shutdown:Sfd->Int->Int          = Loader.load("hx_shutdown_unix_stream_socket", 2);
    private static var _sendto:Sfd->BytesData->Int->Int = Loader.load("hx_sendto_unix_stream_socket", 3);

    /**
     * Possible UnixSocket shutdown methods.
     */
    public static inline var READ:Int  = 1;
    public static inline var WRITE:Int = 2;


    /**
     * Constructor to initialize a new UnixStreamSocket instance.
     *
     * @param hxsocket.Sfd sfd  the socket file descriptor to wrap
     * @param Null<String> path the path where the socket is located
     */
    private function new(sfd:Sfd, ?path:String):Void
    {
        super(sfd, path);
    }

    /**
     * Accepts an incoming stream socket connection.
     *
     * @param Int flags the control flags defining how to wait for/accept connections
     *
     * @return hxsocket.UnixStreamSocket
     */
    public function accept(flags:Int = 0):UnixStreamSocket
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            return new UnixStreamSocket(UnixStreamSocket._accept(this.sfd, flags));
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     * Creates a new UnixStreamSocket.
     *
     * @param String path  the path where the socket should be created
     * @param Int    flags the control flags
     *
     * @return hxsocket.UnixStreamSocket
     */
    public static function create(path:String, flags:Int = 0):UnixStreamSocket
    {
        try {
            return new UnixStreamSocket(UnixStreamSocket._create(path, flags), path);
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     * @{inherit}
     *
     * Attn: The 'flags' argument is ignored.
     */
    override public function read(nbytes:Int, flags:Int = 0):{ bytes:Bytes, from:Null<String> }
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        var ret:{ bytes:Bytes, from:Null<String> };
        if (nbytes == 0) {
            ret = { bytes: Bytes.alloc(0), from: null };
        } else {
            try {
                var bytes:BytesData = UnixStreamSocket._recvfrom(this.sfd, nbytes);
                ret = { bytes: Bytes.ofData(bytes), from: null };
            } catch (ex:Dynamic) {
                throw new SocketException(ex);
            }
        }

        return ret;
    }

    /**
     * Shuts the sockets 'method' stream down.
     *
     * @param Int method the stream to shutdown
     */
    public function shutdown(method:Int):Void
    {
        if (method != UnixStreamSocket.READ && method != UnixStreamSocket.WRITE) {
            throw new IllegalArgumentException("Invalid shutdown type argument (must be UnixStreamSocket.READ or UnixStreamSocket.WRITE)");
        }
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            UnixStreamSocket._shutdown(this.sfd, method);
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     * @{inherit}
     *
     * Attn: The 'flags' and 'path' arguments are ignored.
     */
    override public function write(bytes:Null<Bytes>, flags:Int = 0, path:Null<String> = null):Int
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        var sent:Int;
        if (bytes == null || bytes.length == 0) {
            sent = 0;
        } else {
            try {
                sent = UnixStreamSocket._sendto(this.sfd, bytes.getData(), bytes.length);
            } catch (ex:Dynamic) {
                throw new SocketException(ex);
            }
        }

        return sent;
    }
}
