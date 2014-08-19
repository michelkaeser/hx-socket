package hxsocket.unix;

import hxsocket.Loader;
import hxsocket.Sfd;
import hxsocket.SocketException;
import hxsocket.unix.UnixDgramSocket;
import hxsocket.unix.UnixStreamSocket;
import hxstd.IllegalArgumentException;
import hxstd.IllegalStateException;

/**
 *
 * @abstract
 */
class UnixSocket
{
    /**
     * References to native function implementations loaded through Haxe (hxcpp) C FFI.
     */
    private static var _create:String->Int->Int->Sfd = Loader.load("hx_create_unix_server_socket", 3);
    private static var _destroy:Sfd->Int             = Loader.load("hx_destroy_unix_socket", 1);

    /**
     * Possible UnixSocket server modes.
     */
    public static inline var STREAM:Int = 1;
    public static inline var DGRAM:Int  = 2;

    /**
     * Stores the socket file descriptor reference.
     *
     * @var Null<hxsocket.Sfd>
     */
    private var sfd:Null<Sfd>;

    /**
     * Stores the path on which the socket was created.
     *
     * @var String
     */
    public var path(default, null):Null<String>;


    /**
     * Constructor to initialize a new UnixSocket instance.
     *
     * @param hxsocket.Sfd sfd  the socket file descriptor to wrap
     * @param Null<String> path the path on which the socket listens
     */
    private function new(sfd:Sfd, ?path:String):Void
    {
        this.sfd  = sfd;
        this.path = path;
    }

    /**
     * Creates a new UnixSocket of the given type.
     *
     * @param String path  the location for the socket to be created
     * @param Int    type  the type of the socket to create
     * @param Int    flags control flags
     *
     * @return hxsocket.UnixSocket
     */
    public static function createServer(path:String, type:Int, flags:Int = 0):UnixSocket
    {
        if (type != UnixSocket.STREAM && type != UnixSocket.DGRAM) {
            throw new IllegalArgumentException("Invalid socket type argument (must be UnixSocket.STREAM or UnixSocket.DGRAM)");
        }

        var sock:UnixSocket;
        try {
            if (type == UnixSocket.STREAM) {
                sock = new UnixStreamSocket(UnixSocket._create(path, type, flags), path);
            } else {
                sock = new UnixDgramSocket(UnixSocket._create(path, type, flags), path);
            }
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }

        return sock;
    }

    /**
     * Destroys the socket.
     *
     * Attn: The socket can no longer be used afterwards.
     */
    public function destroy():Void
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            UnixSocket._destroy(this.sfd);
            this.sfd  = null;
            this.path = null;
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }
}
