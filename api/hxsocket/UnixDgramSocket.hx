package hxsocket;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxsocket.Loader;
import hxsocket.SocketException;
import hxsocket.UnixSocket;
import hxstd.IllegalStateException;

/**
 *
 */
class UnixDgramSocket extends UnixSocket
{
    /**
     * References to native function implementations loaded through Haxe (hxcpp) C FFI.
     */
    private static var _connect:Sfd->String->Int = Loader.load("hx_connect_unix_dgram_socket", 2);
    private static var _create:String->Int->Sfd  = Loader.load("hx_create_unix_dgram_socket", 2);
    private static var _recvfrom:Sfd->Int->Int->{ bytes:BytesData, from:String } = Loader.load("hx_recvfrom_unix_dgram_socket", 3);
    private static var _sendto:Sfd->BytesData->Int->String->Int->Int = Loader.load("hx_sendto_unix_dgram_socket", 5);


    /**
     * Constructor to initialize a new UnixDgramSocket instance.
     *
     * @param hxsocket.Sfd sfd  the socket file descriptor to wrap
     * @param Null<String> path the path where the socket is located
     */
    private function new(sfd:Sfd, ?path:String):Void
    {
        super(sfd, path);
    }

    /**
     * Connects to the UnixDgramSocket located at 'path'.
     *
     * @param String path the location of the socket to connect to
     */
    public function connect(path:String):Void
    {
        if (this.sfd == null) {
            throw new IllegalStateException("Socket file descriptor not available");
        }

        try {
            UnixDgramSocket._connect(this.sfd, path);
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     * Creates a new UnixDgramSocket.
     *
     * @param String path  the path where the socket should be created
     * @param Int    flags the control flags
     *
     * @return hxsocket.UnixDgramSocket
     */
    public static function create(path:String, flags:Int = 0):UnixDgramSocket
    {
        try {
            return new UnixDgramSocket(UnixDgramSocket._create(path, flags), path);
        } catch (ex:Dynamic) {
            throw new SocketException(ex);
        }
    }

    /**
     * @{inherit}
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
                var cret = UnixDgramSocket._recvfrom(this.sfd, nbytes, flags);
                ret = { bytes: Bytes.ofData(cret.bytes), from: cret.from };
            } catch (ex:Dynamic) {
                throw new SocketException(ex);
            }
        }

        return ret;
    }

    /**
     * @{inherit}
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
            if (path == null) {
                path = this.path;
            }

            try {
                sent = UnixDgramSocket._sendto(this.sfd, bytes.getData(), bytes.length, path, flags);
            } catch (ex:Dynamic) {
                throw new SocketException(ex);
            }
        }

        return sent;
    }
}
