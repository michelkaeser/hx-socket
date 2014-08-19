package hxsocket.unix;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxsocket.IStreamSocket;
import hxsocket.Loader;
import hxsocket.SocketException;
import hxsocket.unix.UnixSocket;
import hxstd.IllegalArgumentException;
import hxstd.IllegalStateException;

/**
 *
 */
class UnixStreamSocket extends UnixSocket implements IStreamSocket
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
     * @{inherit}
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
     */
    public function read(nbytes:Int):Bytes
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        var bytes:Bytes;
        if (nbytes == 0) {
            bytes = Bytes.alloc(0);
        } else {
            try {
                bytes = Bytes.ofData(UnixStreamSocket._recvfrom(this.sfd, nbytes));
            } catch (ex:Dynamic) {
                throw new SocketException(ex);
            }
        }

        return bytes;
    }

    /**
     * @{inherit}
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
     */
    public function write(bytes:Null<Bytes>):Int
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
